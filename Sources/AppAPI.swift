//
//  AppAPI.swift
//  AVACServer
//
//  Created by Mohammad Porooshani on 2/17/17.
//
//

import Foundation
import Foundation
import PerfectHTTP
import PerfectLib
import MySQL



struct AppRequestSchema {

  struct Headers {
    static let mandatoryField = HTTPRequestHeader.Name.custom(name: "04B31AE8")
    static let mandatoryValue = "AF7941EF4C87"
  }

  struct Last {
    struct Fields {
      static let deviceID = "deviceID"
      static let count = "count"
    }

  }

  struct List {
    struct Fields {
      static let deviceID = "deviceID"
    }
  }


}


class AppAPI {


  struct SensorDataObject {
    let rowID: String
    let deviceID : String
    let temperature: Float
    let humidity: Float
    let pressure: Float
    let uv: Float
    let date: Double
  }

  static func getLast(request: HTTPRequest, response:HTTPResponse) {
    guard validateRequest(request: request) else {
      Log.error(message: "Invalid request!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }

    let params = request.urlParams

    guard var deviceID = params[AppRequestSchema.Last.Fields.deviceID] else {
      Log.error(message: "Device ID not present!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }

    deviceID = deviceID.replacingOccurrences(of: " ", with: "")

    let countStr = params[AppRequestSchema.Last.Fields.count] ?? "1"
    let count = Int(countStr) ?? 1

    print("DeviceID is:'\(deviceID)' count is:\(count)")

    let query = DataBase.DBSchema.SensorDataSchema.selectLastNQuery(deviceID: deviceID, count: count)

    defer {
      dataMysql.close()
    }

    guard dataMysql.performQuery(query: query) else {
      response.completed(status: HTTPResponseStatus.internalServerError)
      return
    }

    let results = dataMysql.storeResults()
    var resultArray = [[String?]]()

    while let row = results?.next() {
      resultArray.append(row)

    }

    var pbfOut = false
    if let acceptPBF = request.header(HTTPRequestHeader.Name.accept) {
      if acceptPBF.lowercased() == "pbf" {
        pbfOut = true
      }
    }

    let sensData = parseRows(rows: resultArray)

    if pbfOut {

      guard let pbf = pbfParseSensorData(rows: sensData) else {
        Log.error(message: "Could not make pbf object")
        response.completed(status: HTTPResponseStatus.internalServerError)
        return
      }

      guard let pbfData = try? pbf.serializeProtobufBytes() else {
        Log.error(message: "Could not export pbf object")
        response.completed(status: HTTPResponseStatus.internalServerError)
        return
      }

      response.setBody(bytes: pbfData)


    } else {

      guard let jsonArray = jsonParseSensorDataRow(rows: sensData) else {
        response.completed(status: HTTPResponseStatus.internalServerError)
        return
      }

      guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonArray, options: []) else {
        Log.error(message: "Could not make josn object")
        response.completed(status: HTTPResponseStatus.internalServerError)
        return
      }
      guard let jsonStr = String(data: jsonData, encoding: .utf8) else {
        Log.error(message: "Could not make josn str")
        response.completed(status: HTTPResponseStatus.internalServerError)
        return
      }
      response.setBody(string: jsonStr)
      //    response.appendBody(string: "<html><title>Mysql Test</title><body>\(resultArray.debugDescription)</body></html>")
    }
    response.completed()

  }

  static func getList(request: HTTPRequest, response:HTTPResponse) {
    guard validateRequest(request: request) else {
      Log.error(message: "Invalid request!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }

  }

  static func validateRequest(request: HTTPRequest) -> Bool {
    guard request.header(AppRequestSchema.Headers.mandatoryField) == AppRequestSchema.Headers.mandatoryValue else {
      Log.error(message: "Invalid headers.")
      return false
    }

    return true
  }



  static func parseRow(row: [String?]) -> SensorDataObject? {
    guard let row_id = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.idField],
      let devID = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.deviceID],
      let tempStr = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.temperature],
      let humStr = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.humidity],
      let pressStr = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.pressure],
      let uvStr = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.uv],
      let dateStr = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.temperature] else {
        Log.error(message: "Could not parse row data.")
        return nil
    }

    guard let temp = Float(tempStr),
      let hum = Float(humStr),
      let press = Float(pressStr),
      let uv = Float(uvStr),
      let dateTicks = Double(dateStr) else {
        Log.error(message: "Could not cast row data.")
        return nil
    }

    return SensorDataObject(rowID: row_id, deviceID: devID, temperature: temp, humidity: hum, pressure: press, uv: uv, date: dateTicks)

  }

  static func parseRows(rows: [[String?]]) -> [SensorDataObject] {
    var result: [SensorDataObject] = []
    for row in rows {
      guard let sensO = parseRow(row: row) else {
        Log.warning(message: "Could not parse row: \(row)")
        continue
      }
      result.append(sensO)
    }
    return result
  }

  static func jsonParseSensorDataRow(rows: [SensorDataObject]) -> JSONArray? {

    var result: JSONArray = []
    for row in rows {
      var jsonRow: JSONDictionary = [:]
      jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.idField] = row.rowID
      jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.deviceID] = row.deviceID
      jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.temperature] = row.temperature
      jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.humidity] = row.humidity
      jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.pressure] = row.pressure
      jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.uv] = row.uv
      jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.date] = row.date
      result.append(jsonRow)

    }
    return result

  }

  static func pbfParseSensorData(rows: [SensorDataObject]) -> SensorDataResult? {
    var res: [SensorDataModel] = []
    for row in rows {

      let mod = SensorDataModel(id: row.rowID, deviceId: row.deviceID, temperature: row.temperature, humidity: row.humidity, pressure: row.pressure, uv: row.uv, date: row.date)
      res.append(mod)

    }
    
    return SensorDataResult(data: res)

  }
  
  
  
  
}

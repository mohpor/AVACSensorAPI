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

typealias dataResponseHandler = ((HTTPResponse, [[String?]]) -> Void)

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
      static let startDate = "startDate"
      static let endDate = "endDate"
    }
  }


}


class AppAPI {


  struct SensorDataObject {
    let deviceID : String
    let temperature: Float
    let humidity: Float
    let pressure: Float
    let uv: Float
    let date: Double?

    init?(row: [String?]) {
      guard
        let devID = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.deviceID],
        let tempStr = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.temperature],
        let humStr = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.humidity],
        let pressStr = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.pressure],
        let uvStr = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.uv]
        else {
          Log.error(message: "Could not parse row data.")
          return nil
      }

      var dateTicks: Double? = nil
      if row.count > DataBase.DBSchema.SensorDataSchema.FieldsOrder.date{
        if let dateStr = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.date] {
          dateTicks = Double(dateStr)
        }
      }

      guard let temp = Float(tempStr),
        let hum = Float(humStr),
        let press = Float(pressStr),
        let uv = Float(uvStr) else {
          Log.error(message: "Could not cast row data.")
          return nil
      }
      self.deviceID = devID
      self.temperature = temp.roundTo(places: 2)
      self.humidity = hum.roundTo(places: 2)
      self.pressure = press.roundTo(places: 2)
      self.uv = uv.roundTo(places: 2)
      self.date = dateTicks
    }

    static func parseRows(rows: [[String?]]) -> [SensorDataObject] {
      var result: [SensorDataObject] = []
      for row in rows {
        guard let sensO = SensorDataObject(row: row) else {
          Log.warning(message: "Could not parse row: \(row)")
          continue
        }
        result.append(sensO)
      }
      return result
    }

    static func jsonParse(rows: [SensorDataObject]) -> JSONArray? {

      var result: JSONArray = []
      for row in rows {
        var jsonRow: JSONDictionary = [:]
        jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.deviceID] = row.deviceID
        jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.temperature] = row.temperature
        jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.humidity] = row.humidity
        jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.pressure] = row.pressure
        jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.uv] = row.uv
        if let d = row.date {
          jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.date] = d
        }
        result.append(jsonRow)

      }
      return result

    }

    static func pbfParse(rows: [SensorDataObject]) -> SensorDataResult? {
      var res: [SensorDataModel] = []
      for row in rows {

        let mod = SensorDataModel(deviceId: row.deviceID, temperature: row.temperature, humidity: row.humidity, pressure: row.pressure, uv: row.uv, date: row.date)
        res.append(mod)
        
      }
      
      return SensorDataResult(data: res)
      
    }
  }

  struct SensorDataHourlyAverageObject {
    let deviceID : String
    let temperature: Float
    let humidity: Float
    let pressure: Float
    let uv: Float
    let date: String?
    let hour: Int32

    init?(row: [String?]) {
      guard

        let devID = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.deviceID],
        let tempStr = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.temperature],
        let humStr = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.humidity],
        let pressStr = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.pressure],
        let uvStr = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.uv],
        let dateStr = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.date],
        let hourStr = row[DataBase.DBSchema.SensorDataSchema.FieldsOrder.hour]

        else {
          Log.error(message: "Could not parse row data.")
          return nil
      }

      guard let temp = Float(tempStr),
        let hum = Float(humStr),
        let press = Float(pressStr),
        let uv = Float(uvStr),
        let hour = Int32(hourStr)
      else {
          Log.error(message: "Could not cast row data.")
          return nil
      }

      self.deviceID = devID
      self.temperature = temp.roundTo(places: 2)
      self.humidity = hum.roundTo(places: 2)
      self.pressure = press.roundTo(places: 2)
      self.uv = uv.roundTo(places: 2)
      self.date = dateStr
      self.hour = hour

    }

    static func parseRows(rows: [[String?]]) -> [SensorDataHourlyAverageObject] {
      var result: [SensorDataHourlyAverageObject] = []
      for row in rows {
        guard let sensO = SensorDataHourlyAverageObject(row: row) else {
          Log.warning(message: "Could not parse row: \(row)")
          continue
        }
        result.append(sensO)
      }
      return result
    }

    static func jsonParse(rows: [SensorDataHourlyAverageObject]) -> JSONArray? {
      var result: JSONArray = []
      for row in rows {
        var jsonRow: JSONDictionary = [:]
        jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.deviceID] = row.deviceID
        jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.temperature] = row.temperature
        jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.humidity] = row.humidity
        jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.pressure] = row.pressure
        jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.uv] = row.uv
        if let d = row.date {
          jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.date_part] = d
        }
        jsonRow[DataBase.DBSchema.SensorDataSchema.Fields.date_hour] = row.hour
        result.append(jsonRow)

      }
      return result
    }

    static func pbfParse(rows: [SensorDataHourlyAverageObject]) -> SensorDataHourlyAverageResult? {
      var res: [SensorDataHourlyAverageModel] = []
      for row in rows {

        let mod = SensorDataHourlyAverageModel(deviceId: row.deviceID, temperature: row.temperature, humidity: row.humidity, pressure: row.pressure, uv: row.uv, date: row.date, hour: row.hour)
        res.append(mod)

      }

      return SensorDataHourlyAverageResult(data: res)
    }

  }

  static func performQuery(query: String, request: HTTPRequest, response: HTTPResponse, jsonHandler: dataResponseHandler, pbfHandler: dataResponseHandler) {
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

    if pbfOut {
      pbfHandler(response, resultArray)
    } else {
      jsonHandler(response, resultArray)
    }

  }

  static func sensorDataJsonItemHandler(response: HTTPResponse, resultArray:[[String?]]) {
    let sensData = SensorDataObject.parseRows(rows: resultArray)
    guard let jsonArray = SensorDataObject.jsonParse(rows: sensData) else {
      response.completed(status: HTTPResponseStatus.internalServerError)
      return
    }

    guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonArray, options: []) else {
      Log.error(message: "Could not make josn object.\n\(jsonArray.debugDescription)")
      response.completed(status: HTTPResponseStatus.internalServerError)
      return
    }
    guard let jsonStr = String(data: jsonData, encoding: .utf8) else {
      Log.error(message: "Could not make josn str")
      response.completed(status: HTTPResponseStatus.internalServerError)
      return
    }
    response.setBody(string: jsonStr)
    response.setMimeTypeJson()
    response.completed()
  }

  static func sensorDataPBFItemHandler(response: HTTPResponse, resultArray:[[String?]]) {
    let sensData = SensorDataObject.parseRows(rows: resultArray)
    guard let pbf = SensorDataObject.pbfParse(rows: sensData) else {
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
    response.setMimeTypePbf()
    response.completed()
  }

  static func sensorDataHourlyAveragePbfHandler(response: HTTPResponse, resultArray:[[String?]]) {

    let sensData = SensorDataHourlyAverageObject.parseRows(rows: resultArray)
    guard let pbf = SensorDataHourlyAverageObject.pbfParse(rows: sensData) else {
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
    response.setMimeTypePbf()
    response.completed()
  }


  static func sensorDataHourlyAverageJsonHandler(response: HTTPResponse, resultArray:[[String?]]) {
    let sensData = SensorDataHourlyAverageObject.parseRows(rows: resultArray)
    guard let jsonArray = SensorDataHourlyAverageObject.jsonParse(rows: sensData) else {
      response.completed(status: HTTPResponseStatus.internalServerError)
      return
    }

    do {
      let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
      guard let jsonStr = String(data: jsonData, encoding: .utf8) else {
        Log.error(message: "Could not make josn str")
        response.completed(status: HTTPResponseStatus.internalServerError)
        return
      }
      response.setBody(string: jsonStr)
      response.setMimeTypeJson()
      response.completed()
    } catch {
      Log.error(message: "Could not make josn object.\n\(jsonArray.debugDescription)")
      response.completed(status: HTTPResponseStatus.internalServerError)
      return
    }

    /*
     guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonArray, options: []) else {
     Log.error(message: "Could not make josn object.\n\(jsonArray.debugDescription)")
     response.completed(status: HTTPResponseStatus.internalServerError)
     return
     }
     guard let jsonStr = String(data: jsonData, encoding: .utf8) else {
     Log.error(message: "Could not make josn str")
     response.completed(status: HTTPResponseStatus.internalServerError)
     return
     }
     response.setBody(string: jsonStr)
     response.setMimeTypeJson()
     response.completed()
     */
  }



  static func getLast(request: HTTPRequest, response:HTTPResponse) {
    guard validateRequest(request: request) else {
      Log.error(message: "Invalid request!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }

    let params = request.urlParams

    guard let deviceID = params[AppRequestSchema.Last.Fields.deviceID] else {
      Log.error(message: "Device ID not present!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }

    let countStr = params[AppRequestSchema.Last.Fields.count] ?? "1"
    let count = Int(countStr) ?? 1

    print("DeviceID is:'\(deviceID)' count is:\(count)")

    let query = DataBase.DBSchema.SensorDataSchema.selectLastNQuery(deviceID: deviceID, count: count)
    performQuery(query: query, request: request, response: response, jsonHandler: sensorDataJsonItemHandler, pbfHandler: sensorDataPBFItemHandler)

  }


  static func getList(request: HTTPRequest, response:HTTPResponse) {
    guard validateRequest(request: request) else {
      Log.error(message: "Invalid request!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }

    let params = request.urlParams

    guard let deviceID = params[AppRequestSchema.Last.Fields.deviceID] else {
      Log.error(message: "Device ID not present!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }

    guard let startDateStr = params[AppRequestSchema.List.Fields.startDate] else {
      Log.error(message: "StartDate Not present!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return

    }

    guard let startDate = Double(startDateStr) else {
      Log.error(message: "StartDate malformed!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }


    var endDate: Double? = nil
    if let endDateStr = params[AppRequestSchema.List.Fields.endDate] {
      endDate = Double(endDateStr)
    }
    print("DeviceID is:'\(deviceID)' start from:\(startDate) end to: \(endDate)")
    let query = DataBase.DBSchema.SensorDataSchema.selectRangeQuery(deviceID: deviceID, startDate: startDate, endDate: endDate)
    performQuery(query: query, request: request, response: response, jsonHandler: sensorDataJsonItemHandler, pbfHandler: sensorDataPBFItemHandler)

  }

  static func getListAverage(request: HTTPRequest, response:HTTPResponse) {
    guard validateRequest(request: request) else {
      Log.error(message: "Invalid request!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }

    let params = request.urlParams

    guard let deviceID = params[AppRequestSchema.Last.Fields.deviceID] else {
      Log.error(message: "Device ID not present!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }

    guard let startDateStr = params[AppRequestSchema.List.Fields.startDate] else {
      Log.error(message: "StartDate Not present!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return

    }

    guard let startDate = Double(startDateStr) else {
      Log.error(message: "StartDate malformed!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }


    var endDate: Double? = nil
    if let endDateStr = params[AppRequestSchema.List.Fields.endDate] {
      endDate = Double(endDateStr)
    }
    print("DeviceID is:'\(deviceID)' start from:\(startDate) end to: \(endDate)")
    let query = DataBase.DBSchema.SensorDataSchema.selectAverageRangeQuery(deviceID: deviceID, startDate: startDate, endDate: endDate)
    performQuery(query: query, request: request, response: response, jsonHandler: sensorDataJsonItemHandler, pbfHandler: sensorDataPBFItemHandler)

  }

  static func getHourlyAverage(request: HTTPRequest, response:HTTPResponse) {

    guard validateRequest(request: request) else {
      Log.error(message: "Invalid request!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }

    let params = request.urlParams

    guard let deviceID = params[AppRequestSchema.Last.Fields.deviceID] else {
      Log.error(message: "Device ID not present!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }

    guard let startDateStr = params[AppRequestSchema.List.Fields.startDate] else {
      Log.error(message: "StartDate Not present!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return

    }

    guard let startDate = Double(startDateStr) else {
      Log.error(message: "StartDate malformed!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }


    var endDate: Double? = nil
    if let endDateStr = params[AppRequestSchema.List.Fields.endDate] {
      endDate = Double(endDateStr)
    }
    print("DeviceID is:'\(deviceID)' start from:\(startDate) end to: \(endDate)")
    let query = DataBase.DBSchema.SensorDataSchema.selectHourlyAverageQuery(deviceID: deviceID, startDate: startDate, endDate: endDate)
    performQuery(query: query, request: request, response: response, jsonHandler: sensorDataHourlyAverageJsonHandler, pbfHandler: sensorDataHourlyAveragePbfHandler)
  }

  static func validateRequest(request: HTTPRequest) -> Bool {
    guard request.header(AppRequestSchema.Headers.mandatoryField) == AppRequestSchema.Headers.mandatoryValue else {
      Log.error(message: "Invalid headers.")
      return false
    }

    return true
  }

}

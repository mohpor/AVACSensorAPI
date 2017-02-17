//
//  SensorAPI.swift
//  AVACServer
//
//  Created by Mohammad Porooshani on 2/16/17.
//
//

import Foundation
import PerfectHTTP
import PerfectLib
import MySQL

struct RequestSchema {

  struct Headers {
    static let mandatoryField = HTTPRequestHeader.Name.custom(name: "5621A0DE")
    static let mandatoryValue = "D699279EC805"
  }

  struct Fields {
    static let deviceID = "d"
    static let temperature = "t"
    static let humidity = "h"
    static let pressure = "p"
    static let uv = "u"
  }


}

struct SensorData {

  let deviceID : String
  let temperature: Float
  let humidity: Float
  let pressure: Float
  let uv: Float

}

struct DataBase {

  struct DBConnection {
    static let host = "127.0.0.1"
    static let user = "root"
    static let password = "Moh.6686"
  }

  struct DBSchema {
    static let schemaName = "Sensor_Data"
    struct SensorDataSchema {
      static let name  = "Sensor_Data"
      struct Fields {

        static let idField = "id"
        static let deviceID = "deviceID"
        static let temperature = "temperature"
        static let humidity = "humidity"
        static let pressure = "pressure"
        static let uv = "uv"

      }
      static func selectQuery(deviceID: String) -> String {
        return "SELECT \(Fields.idField), \(Fields.deviceID), \(Fields.temperature), \(Fields.humidity), \(Fields.pressure), \(Fields.uv) from \(SensorDataSchema.name)"
      }

      static func insertQuery(sensorData: SensorData) -> String {

        var q = ""
        q += "INSERT INTO \(DBSchema.SensorDataSchema.name) "
        q += "(\(DBSchema.SensorDataSchema.Fields.deviceID), \(DBSchema.SensorDataSchema.Fields.temperature), \(DBSchema.SensorDataSchema.Fields.humidity), \(DBSchema.SensorDataSchema.Fields.pressure), \(DBSchema.SensorDataSchema.Fields.uv))"
        q += " VALUES ("
        q += "'\(sensorData.deviceID)', "
        q += "'\(sensorData.temperature)', "
        q += "'\(sensorData.humidity)', "
        q += "'\(sensorData.pressure)', "
        q += "'\(sensorData.uv)'"
        q += ")"
        return q
        
      }
      
    }
  }
  
}

class SensorAPI {

  static let dataMysql = MySQL()

  static func dbHandler(request: HTTPRequest, response:HTTPResponse) {

    guard request.header(RequestSchema.Headers.mandatoryField) == RequestSchema.Headers.mandatoryValue else {
      Log.error(message: "Invalid headers.")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }

    guard let sensorData = parseRequest(request: request) else {
      Log.error(message: "Cannot read sensr data from request!")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }



    print("db got called (\(request.path))")
    guard dataMysql.connect(host: DataBase.DBConnection.host, user: DataBase.DBConnection.user, password: DataBase.DBConnection.password ) else {
      Log.info(message: "Failure connecting to data server \(DataBase.DBConnection.host)")
      return
    }

    defer {
      dataMysql.close()
    }

    let query = DataBase.DBSchema.SensorDataSchema.insertQuery(sensorData: sensorData)
    guard dataMysql.selectDatabase(named: DataBase.DBSchema.schemaName) && dataMysql.query(statement: query) else {
      Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
      response.completed(status: HTTPResponseStatus.internalServerError)
      return
    }

    response.appendBody(string: "<html><title>Insert Successfull</title><body><h2>Insert Successful</h2></body></html>")
    response.completed()

  }

  static func parseRequest(request: HTTPRequest) -> SensorData? {

    var params = [String:String]()
    for t in request.postParams {
      params[t.0] = t.1
    }

    guard let devID = params[RequestSchema.Fields.deviceID] else {
      Log.error(message: "DeviceID not present")
      return nil
    }

    guard let tempStr = params[RequestSchema.Fields.temperature] else {
      Log.error(message: "Temperature not present")
      return nil
    }

    guard let temp = Float(tempStr) else {
      Log.error(message: "Temperature is invalid")
      return nil
    }

    guard let humStr = params[RequestSchema.Fields.humidity] else {
      Log.error(message: "Humidity not present")
      return nil
    }

    guard let hum = Float(humStr) else {
      Log.error(message: "Humidity is invalid")
      return nil
    }

    guard let pressStr = params[RequestSchema.Fields.pressure] else {
      Log.error(message: "Pressure not present")
      return nil
    }

    guard let press = Float(pressStr) else {
      Log.error(message: "Pressure is invalid")
      return nil
    }

    guard let uvStr = params[RequestSchema.Fields.uv] else {
      Log.error(message: "UV not present")
      return nil
    }
    
    guard let uv = Float(uvStr) else {
      Log.error(message: "UV is invalid")
      return nil
    }
    
    return SensorData(deviceID: devID, temperature: temp, humidity: hum, pressure: press, uv: uv)
    
    
  }

}

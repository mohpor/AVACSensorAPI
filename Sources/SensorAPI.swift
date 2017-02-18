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

struct SensorRequestSchema {

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



class SensorAPI {


  static func addSensorData(request: HTTPRequest, response:HTTPResponse) {

    guard request.header(SensorRequestSchema.Headers.mandatoryField) == SensorRequestSchema.Headers.mandatoryValue else {
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
    let query = DataBase.DBSchema.SensorDataSchema.insertQuery(sensorData: sensorData)
    defer {
      dataMysql.close()
    }
    guard dataMysql.performQuery(query: query) else {
      response.completed(status: HTTPResponseStatus.internalServerError)
      return
    }

    response.appendBody(string: "<html><title>Insert Successfull</title><body><h2>Insert Successful</h2></body></html>")
    response.completed()

  }

  static func parseRequest(request: HTTPRequest) -> SensorData? {

    var params = request.bodyParams

    guard let devID = params[SensorRequestSchema.Fields.deviceID] else {
      Log.error(message: "DeviceID not present")
      return nil
    }

    guard let tempStr = params[SensorRequestSchema.Fields.temperature] else {
      Log.error(message: "Temperature not present")
      return nil
    }

    guard let temp = Float(tempStr) else {
      Log.error(message: "Temperature is invalid")
      return nil
    }

    guard let humStr = params[SensorRequestSchema.Fields.humidity] else {
      Log.error(message: "Humidity not present")
      return nil
    }

    guard let hum = Float(humStr) else {
      Log.error(message: "Humidity is invalid")
      return nil
    }

    guard let pressStr = params[SensorRequestSchema.Fields.pressure] else {
      Log.error(message: "Pressure not present")
      return nil
    }

    guard let press = Float(pressStr) else {
      Log.error(message: "Pressure is invalid")
      return nil
    }

    guard let uvStr = params[SensorRequestSchema.Fields.uv] else {
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

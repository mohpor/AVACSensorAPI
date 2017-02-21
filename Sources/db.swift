//
//  db.swift
//  AVACServer
//
//  Created by Mohammad Porooshani on 2/17/17.
//
//

import Foundation
import MySQL
import PerfectLib

let dataMysql = MySQL()

struct DataBase {

  struct DBConnection {
    static let host = "127.0.0.1"
    static let user = "mohpor"
    static let password = "Moh.6686"
  }

  struct DBSchema {
    static let schemaName = "Sensor_Data"
    struct SensorDataSchema {
      static let name  = "sensor_data"
      struct Fields {

        static let deviceID = "deviceID"
        static let temperature = "temperature"
        static let humidity = "humidity"
        static let pressure = "pressure"
        static let date = "date"
        static let date_part = "_date"
        static let date_hour = "hour"
        static let uv = "uv"

      }

      struct FieldsOrder {
        static let deviceID = 0
        static let temperature = 1
        static let humidity = 2
        static let pressure = 3
        static let uv = 4
        static let date = 5
        static let hour = 6

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

extension MySQL {

  func performQuery(query: String) -> Bool {    
    guard dataMysql.connect(host: DataBase.DBConnection.host, user: DataBase.DBConnection.user, password: DataBase.DBConnection.password ) else {
      Log.info(message: "Failure connecting to data server(\(DataBase.DBConnection.host)):\n \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
      //Log.info(message: "Failure connecting to data server \(DataBase.DBConnection.host)")
      return false
    }
    
    guard dataMysql.selectDatabase(named: DataBase.DBSchema.schemaName) && dataMysql.query(statement: query) else {
      Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
      return false
    }

    return true
    
  }
  
}

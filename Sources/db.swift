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
        static let date = "date"
        static let uv = "uv"

      }

      struct FieldsOrder {
        static let idField = 0
        static let deviceID = 1
        static let temperature = 2
        static let humidity = 3
        static let pressure = 4
        static let uv = 5
        static let date = 6

      }

//      static func selectQuery(deviceID: String) -> String {
//        return "SELECT \(Fields.idField), \(Fields.deviceID), \(Fields.temperature), \(Fields.humidity), \(Fields.pressure), \(Fields.uv) from \(SensorDataSchema.name)"
//      }

      static func selectLastNQuery(deviceID: String, count: Int = 1) -> String {
        return "SELECT \(Fields.idField), \(Fields.deviceID), \(Fields.temperature), \(Fields.humidity), \(Fields.pressure), \(Fields.uv), UNIX_TIMESTAMP(\(Fields.date)) as \(Fields.date) from \(SensorDataSchema.name) WHERE \(Fields.deviceID) = '\(deviceID)' ORDER BY date desc Limit \(count)"
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
      Log.info(message: "Failure connecting to data server \(DataBase.DBConnection.host)")
      return false
    }
    
    guard dataMysql.selectDatabase(named: DataBase.DBSchema.schemaName) && dataMysql.query(statement: query) else {
      Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
      return false
    }

    return true
    
  }
  
}

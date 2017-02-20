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

      static func selectBaseQuery(unixTime: Bool = true) -> String {

        let dateStr = unixTime ? "UNIX_TIMESTAMP(\(Fields.date)) as \(Fields.date)" : "\(Fields.date)"
        return "SELECT \(Fields.deviceID), \(Fields.temperature), \(Fields.humidity), \(Fields.pressure), \(Fields.uv), \(dateStr) from \(SensorDataSchema.name) "

      }

      static func selectAverageBaseQuery() -> String {

        return "SELECT \(Fields.deviceID), AVG(\(Fields.temperature)) as \(Fields.temperature), AVG(\(Fields.humidity)) as \(Fields.humidity), AVG(\(Fields.pressure)) as \(Fields.pressure), AVG(\(Fields.uv)) as \(Fields.uv) from \(SensorDataSchema.name) "
        
      }


      static func selectLastNQuery(deviceID: String, count: Int = 1) -> String {
        var result = selectBaseQuery()
        result += "WHERE \(Fields.deviceID) = '\(deviceID)' ORDER BY date desc Limit \(count)"
        return result
      }


      static func selectRangeQuery(deviceID: String, startDate: Double, endDate: Double?, unixTime: Bool = true) -> String {

        var result = selectBaseQuery(unixTime: unixTime)

        result += "WHERE \(Fields.deviceID) = '\(deviceID)' "
        result += "and \(Fields.date) >= \(startDate) "
        if let ed = endDate {
          result += "and \(Fields.date) <= \(ed) "
        }
        result += "ORDER BY date desc"

        return result

      }

      static func selectHourlyAverageQuery(deviceID: String, startDate: Double, endDate: Double?) -> String {
        var result = "Select t.\(Fields.deviceID), AVG(t.\(Fields.temperature)) as \(Fields.temperature), AVG(t.\(Fields.humidity)) as \(Fields.humidity), AVG(t.\(Fields.pressure)) as \(Fields.pressure), AVG(t.\(Fields.uv)) as \(Fields.uv), DATE_FORMAT(t.\(Fields.date), '%Y-%m-%d') as \(Fields.date_part), HOUR(t.\(Fields.date)) as \(Fields.date_hour) from"

        result += "(\(selectRangeQuery(deviceID: deviceID, startDate: startDate, endDate: endDate, unixTime: false))) "
        result += "t GROUP BY \(Fields.date_part),\(Fields.date_hour)"
        return result
      }

      static func selectAverageRangeQuery(deviceID: String, startDate: Double, endDate: Double?) -> String {

        var result = selectAverageBaseQuery()

        result += "WHERE \(Fields.deviceID) = '\(deviceID)' "
        result += "and UNIX_TIMESTAMP(\(Fields.date)) >= \(startDate) "
        if let ed = endDate {
          result += "and UNIX_TIMESTAMP(\(Fields.date)) <= \(ed) "
        }
        result += "ORDER BY date desc"

        return result
        
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
    Log.info(message: "Connecting to DB...")
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

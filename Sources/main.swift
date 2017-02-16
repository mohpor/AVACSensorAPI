//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation
import MySQL

// An example request handler.
// This 'handler' function can be referenced directly in the configuration below.
func handler(data: [String:Any]) throws -> RequestHandler {
	return {
		request, response in
		// Respond with a simple message.
		response.setHeader(.contentType, value: "text/html")
		response.appendBody(string: "<html><title>Hello, Mohammad!</title><body>Hello, Mohamamd!</body></html>")
		// Ensure that response.completed() is called when your processing is done.
		response.completed()
	}
}

func postHandler(data: [String:Any]) throws -> RequestHandler {
  return {
    request, response in
    //print("request is:\n\(request.params())")
    // Respond with a simple message.
    if let body_bytes = request.postBodyBytes {
      do {
        let dat = Data(bytes: body_bytes)
        let json = try JSONSerialization.jsonObject(with: dat, options: [])
        print(json)
      } catch {
        print("Error converting json!\n\(error)")
      }
    }

    response.setHeader(.contentType, value: "text/html")
    var bdy = "<html><title>Hello, Mohammad!</title><body>"
    bdy += "Hello Moahammad,<br /><h3>Here it is your list:</h3><br />"
    bdy += "Request: \(request.postParams)"
    bdy += "<table border='1' cellpadding = '10'>"
    bdy += "<tr><th>Param Name</th><th>Value</th></tr>"
    for param in request.params() {
      bdy += "<tr>"
      bdy += "<td><b>\(param.0)</b></td>"
      bdy += "<td>\(param.1)</td>"
      bdy += "</tr>"
    }
    bdy += "</table>"
    bdy += "</body></html>"
    response.appendBody(string: bdy)
    // Ensure that response.completed() is called when your processing is done.
    response.completed()
  }
}

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
let dataMysql = MySQL()

func dbHandler(data: [String:Any]) throws -> RequestHandler {
  return {
    request, response in

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
      dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }

//    guard dataMysql.selectDatabase(named: DataBase.DBSchema.SensorDataSchema.name) && dataMysql.query(statement: DataBase.DBSchema.SensorDataSchema.Fields.selectQuery(deviceID: "")) else {
//      Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
//      return
//    }

    let query = DataBase.DBSchema.SensorDataSchema.insertQuery(sensorData: sensorData)
    guard dataMysql.selectDatabase(named: DataBase.DBSchema.SensorDataSchema.name) && dataMysql.query(statement: query) else {
      Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
      response.completed(status: HTTPResponseStatus.internalServerError)
      return
    }

//    let results = dataMysql.storeResults()
//
//    var resultArray = [[String?]]()
//    while let row = results?.next() {
//      resultArray.append(row)
//
//    }

    response.appendBody(string: "<html><title>Insert Successfull</title><body><h2>Insert Successful</h2></body></html>")
    response.completed()

  }
}

func parseRequest(request: HTTPRequest) -> SensorData? {

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


// Configuration data for two example servers.
// This example configuration shows how to launch one or more servers 
// using a configuration dictionary.

let port1 = 8080, port2 = 8181

let confData = [
	"servers": [
		// Configuration data for one server which:
		//	* Serves the hello world message at <host>:<port>/
		//	* Serves static files out of the "./webroot"
		//		directory (which must be located in the current working directory).
		//	* Performs content compression on outgoing data when appropriate.
		[
			"name":"localhost",
			"port":port1,
			"routes":[
				["method":"get", "uri":"/", "handler":handler],
				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
				 "documentRoot":"./webroot",
				 "allowResponseFilters":true],
        ["method":"post", "uri":"/", "handler":postHandler],
        ["method":"post", "uri":"/db", "handler":dbHandler]
			],
			"filters":[
				[
				"type":"response",
				"priority":"high",
				"name":PerfectHTTPServer.HTTPFilter.contentCompression,
				]
			]
		],
		// Configuration data for another server which:
		//	* Redirects all traffic back to the first server.
		[
			"name":"localhost",
			"port":port2,
			"routes":[
				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.redirect,
				 "base":"http://localhost:\(port1)"]
			]
		]
	]
]

do {
	// Launch the servers based on the configuration data.
	try HTTPServer.launch(configurationData: confData)
} catch {
	fatalError("\(error)") // fatal error launching one of the servers
}


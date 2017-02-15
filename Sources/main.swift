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

let testHost = "127.0.0.1"
let testUser = "root"
// PLEASE change to whatever your actual password is before running these tests
let testPassword = "Moh.6686"
let testSchema = "Testdb"
let dataMysql = MySQL()

func dbHandler(data: [String:Any]) throws -> RequestHandler {
  return {
    request, response in

    guard request.header(HTTPRequestHeader.Name.custom(name: "5621A0DE")) == "D699279EC805" else {
      Log.error(message: "Invalid headers.")
      response.completed(status: HTTPResponseStatus.badRequest)
      return
    }

    print("db got called (\(request.path))")
    guard dataMysql.connect(host: testHost, user: testUser, password: testPassword ) else {
      Log.info(message: "Failure connecting to data server \(testHost)")
      return
    }

    defer {
      dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }

    guard dataMysql.selectDatabase(named: testSchema) && dataMysql.query(statement: "select * from t") else {
      Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
      return
    }

    let results = dataMysql.storeResults()

    var resultArray = [[String?]]()
    while let row = results?.next() {
      resultArray.append(row)

    }

    response.appendBody(string: "<html><title>Mysql Test</title><body>\(resultArray.debugDescription)</body></html>")
    response.completed()

//    var bdy = "db called"
//    response.appendBody(string: bdy)
//    // Ensure that response.completed() is called when your processing is done.
//    response.completed()
  }
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


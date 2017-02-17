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


func handler(request: HTTPRequest, response:HTTPResponse){
		response.setHeader(.contentType, value: "text/html")
		response.appendBody(string: "<html><title>Nada.</title><body>Nothing to see here.</body></html>")
		response.completed()
}



let server = HTTPServer()
var routes = Routes()

routes.add(method: .get, uri: "/", handler: handler)
routes.add(method: .post, uri: "/", handler: handler)
routes.add(method: .post, uri: "/sensor", handler: SensorAPI.dbHandler)

server.addRoutes(routes)

server.serverPort = 8765
server.documentRoot = "./webroot"


configureServer(server)

do {
  // Launch the HTTP server.
  try server.start()

} catch PerfectError.networkError(let err, let msg) {
  print("Network error thrown: \(err) \(msg)")
}

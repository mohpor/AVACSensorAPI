//
//  extensions.swift
//  AVACServer
//
//  Created by Mohammad Porooshani on 2/17/17.
//
//

import Foundation
import PerfectHTTP
import PerfectLib
import MySQL

typealias JSONDictionary = [String: Any]
typealias JSONArray = [JSONDictionary]


extension HTTPRequest {

  var bodyParams: [String: String] {
    var params = [String:String]()
    for t in self.postParams {
      params[t.0] = t.1
    }
    return params

  }

  var urlParams: [String: String] {
    var params = [String:String]()
    for t in self.params() {
      params[t.0] = t.1
    }
    return params

  }

}

extension HTTPResponse {

  func setMimeTypeJson() {
    self.addHeader(HTTPResponseHeader.Name.contentType, value: "application/json")
  }

  func setMimeTypePbf() {
    self.addHeader(HTTPResponseHeader.Name.contentType, value: "application/octet-stream")
  }

}



extension Double {
  /// Rounds the double to decimal places value
  func roundTo(places:Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}

extension Float {
  /// Rounds the double to decimal places value
  func roundTo(places:Int) -> Float {
    let divisor = pow(10.0, Float(places))
    return (self * divisor).rounded() / divisor
  }
}
 

/*
 * DO NOT EDIT.
 *
 * Generated by the protocol buffer compiler.
 * Source: SensorData.proto
 *
 */

import Foundation
import SwiftProtobuf


public struct SensorDataModel: ProtobufGeneratedMessage {
  public var swiftClassName: String {return "SensorDataModel"}
  public var protoMessageName: String {return "SensorDataModel"}
  public var protoPackageName: String {return ""}
  public var jsonFieldNames: [String: Int] {return [
    "id": 1,
    "deviceID": 2,
    "temperature": 3,
    "humidity": 4,
    "pressure": 5,
    "uv": 6,
    "date": 7,
  ]}
  public var protoFieldNames: [String: Int] {return [
    "id": 1,
    "deviceID": 2,
    "temperature": 3,
    "humidity": 4,
    "pressure": 5,
    "uv": 6,
    "date": 7,
  ]}

  public var id: String = ""

  public var deviceId: String = ""

  public var temperature: Float = 0

  public var humidity: Float = 0

  public var pressure: Float = 0

  public var uv: Float = 0

  public var date: Double = 0

  public init() {}

  public init(id: String? = nil,
    deviceId: String? = nil,
    temperature: Float? = nil,
    humidity: Float? = nil,
    pressure: Float? = nil,
    uv: Float? = nil,
    date: Double? = nil)
  {
    if let v = id {
      self.id = v
    }
    if let v = deviceId {
      self.deviceId = v
    }
    if let v = temperature {
      self.temperature = v
    }
    if let v = humidity {
      self.humidity = v
    }
    if let v = pressure {
      self.pressure = v
    }
    if let v = uv {
      self.uv = v
    }
    if let v = date {
      self.date = v
    }
  }

  public mutating func _protoc_generated_decodeField(setter: inout ProtobufFieldDecoder, protoFieldNumber: Int) throws -> Bool {
    let handled: Bool
    switch protoFieldNumber {
    case 1: handled = try setter.decodeSingularField(fieldType: ProtobufString.self, value: &id)
    case 2: handled = try setter.decodeSingularField(fieldType: ProtobufString.self, value: &deviceId)
    case 3: handled = try setter.decodeSingularField(fieldType: ProtobufFloat.self, value: &temperature)
    case 4: handled = try setter.decodeSingularField(fieldType: ProtobufFloat.self, value: &humidity)
    case 5: handled = try setter.decodeSingularField(fieldType: ProtobufFloat.self, value: &pressure)
    case 6: handled = try setter.decodeSingularField(fieldType: ProtobufFloat.self, value: &uv)
    case 7: handled = try setter.decodeSingularField(fieldType: ProtobufDouble.self, value: &date)
    default:
      handled = false
    }
    return handled
  }

  public func _protoc_generated_traverse(visitor: inout ProtobufVisitor) throws {
    if id != "" {
      try visitor.visitSingularField(fieldType: ProtobufString.self, value: id, protoFieldNumber: 1, protoFieldName: "id", jsonFieldName: "id", swiftFieldName: "id")
    }
    if deviceId != "" {
      try visitor.visitSingularField(fieldType: ProtobufString.self, value: deviceId, protoFieldNumber: 2, protoFieldName: "deviceID", jsonFieldName: "deviceID", swiftFieldName: "deviceId")
    }
    if temperature != 0 {
      try visitor.visitSingularField(fieldType: ProtobufFloat.self, value: temperature, protoFieldNumber: 3, protoFieldName: "temperature", jsonFieldName: "temperature", swiftFieldName: "temperature")
    }
    if humidity != 0 {
      try visitor.visitSingularField(fieldType: ProtobufFloat.self, value: humidity, protoFieldNumber: 4, protoFieldName: "humidity", jsonFieldName: "humidity", swiftFieldName: "humidity")
    }
    if pressure != 0 {
      try visitor.visitSingularField(fieldType: ProtobufFloat.self, value: pressure, protoFieldNumber: 5, protoFieldName: "pressure", jsonFieldName: "pressure", swiftFieldName: "pressure")
    }
    if uv != 0 {
      try visitor.visitSingularField(fieldType: ProtobufFloat.self, value: uv, protoFieldNumber: 6, protoFieldName: "uv", jsonFieldName: "uv", swiftFieldName: "uv")
    }
    if date != 0 {
      try visitor.visitSingularField(fieldType: ProtobufDouble.self, value: date, protoFieldNumber: 7, protoFieldName: "date", jsonFieldName: "date", swiftFieldName: "date")
    }
  }

  public func _protoc_generated_isEqualTo(other: SensorDataModel) -> Bool {
    if id != other.id {return false}
    if deviceId != other.deviceId {return false}
    if temperature != other.temperature {return false}
    if humidity != other.humidity {return false}
    if pressure != other.pressure {return false}
    if uv != other.uv {return false}
    if date != other.date {return false}
    return true
  }
}

public struct SensorDataResult: ProtobufGeneratedMessage {
  public var swiftClassName: String {return "SensorDataResult"}
  public var protoMessageName: String {return "SensorDataResult"}
  public var protoPackageName: String {return ""}
  public var jsonFieldNames: [String: Int] {return [
    "data": 1,
  ]}
  public var protoFieldNames: [String: Int] {return [
    "data": 1,
  ]}

  public var data: [SensorDataModel] = []

  public init() {}

  public init(data: [SensorDataModel] = [])
  {
    if !data.isEmpty {
      self.data = data
    }
  }

  public mutating func _protoc_generated_decodeField(setter: inout ProtobufFieldDecoder, protoFieldNumber: Int) throws -> Bool {
    let handled: Bool
    switch protoFieldNumber {
    case 1: handled = try setter.decodeRepeatedMessageField(fieldType: SensorDataModel.self, value: &data)
    default:
      handled = false
    }
    return handled
  }

  public func _protoc_generated_traverse(visitor: inout ProtobufVisitor) throws {
    if !data.isEmpty {
      try visitor.visitRepeatedMessageField(value: data, protoFieldNumber: 1, protoFieldName: "data", jsonFieldName: "data", swiftFieldName: "data")
    }
  }

  public func _protoc_generated_isEqualTo(other: SensorDataResult) -> Bool {
    if data != other.data {return false}
    return true
  }
}
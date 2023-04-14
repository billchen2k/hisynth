//
//  ParameterManagable.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/14.
//

import Foundation

protocol ParameterManagable: Equatable {
    associatedtype Controller

    /// dump() and parse() are implemented by default.
    func dump() -> String
    mutating func parse(_ str: String) throws

    /// Requires implemtation. Read values from the dictionary. Return nils if fails. Will be used by parse() function.
    mutating func inject(from values: [String: Any])
    /// Requires implementation. Extract the parameters with current value in the parameter.
    mutating func extract(controller: Controller)
    /// Requires implementation. Apply the value to the controller.
    func apply(controller: Controller)
}

/// Shortcut for MemoryLayout.size
func sizeof<T>(_ value: T) -> Int{
    return MemoryLayout.size(ofValue: value)
}


/// Managable Parameter.
///     Supported parameter types: Bool, Float, HSWaveform, [Bool], [Float], [HSWaveform], HSReverbType
///     Float and [Float] will be converted to Float16 and [Float16] to reduce output size.
extension ParameterManagable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.dump() == rhs.dump()
    }

    /// Assign value with optional value.
    func assign<T>(_ value: T?, to: inout T) {
        if let v = value {
            to = v
        }
    }

    func getData() -> Data {
        var data = Data()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let v = child.value as? Float {
                var float16v = Float16(v)
                data.append(Data(bytes: &float16v, count: sizeof(float16v)))
            } else if var v = child.value as? Bool {
                data.append(Data(bytes: &v, count: sizeof(v)))
            } else if var v = child.value as? HSEnum {
                var rawValue = v.rawValue
                data.append(Data(bytes: &rawValue, count: sizeof(rawValue)))
            } else if let v = child.value as? [Float] {
                var size: Int8 = Int8(v.count)
                data.append(Data(bytes: &size, count: sizeof(size)))
                for i in 0..<v.count {
                    var float16v = Float16(v[i])
                    data.append(Data(bytes: &float16v, count: sizeof(float16v)))
                }
            } else if var v = child.value as? [Bool] {
                var size: Int8 = Int8(v.count)
                data.append(Data(bytes: &size, count: sizeof(size)))
                for i in 0..<v.count {
                    data.append(Data(bytes: &v[i], count: sizeof(v[i])))
                }
            } else if var v = child.value as? [HSWaveform] {
                var size: Int8 = Int8(v.count)
                data.append(Data(bytes: &size, count: sizeof(size)))
                for i in 0..<v.count {
                    data.append(Data(bytes: &v[i], count: sizeof(v[i])))
                }
            } else {
                print("[Dump] Unknown data type for \(child.label ?? "UNKNOWN"). Will ignore.")
            }
        }
        return data
    }

    private func safeSubData(_ data: Data, in range: Range<Data.Index>) throws -> Data {
        guard range.lowerBound >= 0 && range.upperBound <= data.count else {
            throw PresetError.outOfIndex
        }
        return data.subdata(in: range)
    }

    func loadDataMap(_ data: Data) throws -> [String: Any] {

        var values: [String: Any] = [:]
        let mirror = Mirror(reflecting: self)
        var offset = 0
        let len16 = 2
        let len8 = 1

        for child in mirror.children {
            if offset >= data.count {
                throw PresetError.outOfIndex
            }
            var len = 0
            if type(of: child.value) is Float?.Type {
                len = len16
                let v = try safeSubData(data, in: offset..<offset + len).withUnsafeBytes{ $0.load(as: Float16.self)}
                values[child.label!] = Float(v)
            } else if type(of: child.value) is Bool?.Type {
                len = len8
                let v = try safeSubData(data, in: offset..<offset + len).withUnsafeBytes{ $0.load(as: Bool.self)}
                values[child.label!] = v
            } else if type(of: child.value) is HSWaveform?.Type {
                len = len8
                let v = try safeSubData(data, in: offset..<offset + len).withUnsafeBytes{ $0.load(as: Int8.self)}
                values[child.label!] = HSWaveform(rawValue: v)!
            } else if type(of: child.value) is HSReverbType?.Type {
                len = len8
                let v = try safeSubData(data, in: offset..<offset + len).withUnsafeBytes{ $0.load(as: Int8.self)}
                values[child.label!] = HSReverbType(rawValue: v)!
            } else if type(of: child.value) is [Float]?.Type {
                let size = try safeSubData(data, in: offset..<offset + len8).withUnsafeBytes{ $0.load(as: Int8.self)}
                offset += len8
                var v: [Float] = []
                for _ in 0..<size {
                    let float16v = try safeSubData(data, in: offset..<offset + len16).withUnsafeBytes{ $0.load(as: Float16.self)}
                    v.append(Float(float16v))
                    offset += len16
                }
                len = 0
                values[child.label!] = v
            } else if type(of: child.value) is [Bool]?.Type {
                let size = try safeSubData(data, in: offset..<offset + len8).withUnsafeBytes{ $0.load(as: Int8.self)}
                offset += len8
                var v: [Bool] = []
                for _ in 0..<size {
                    let boolv = try safeSubData(data, in: offset..<offset + len8).withUnsafeBytes{ $0.load(as: Bool.self)}
                    v.append(boolv)
                    offset += len8
                }
                len = 0
                values[child.label!] = v
            } else if type(of: child.value) is [HSWaveform]?.Type {
                let size = try safeSubData(data, in: offset..<offset + len8).withUnsafeBytes{ $0.load(as: Int8.self)}
                offset += len8
                var v: [HSWaveform] = []
                for _ in 0..<size {
                    len = 1
                    let waveformv = try safeSubData(data, in: offset..<offset + len).withUnsafeBytes{ $0.load(as: Int8.self)}
                    v.append(HSWaveform(rawValue: waveformv)!)
                    offset += len8
                }
                len = 0
                values[child.label!] = v
            } else {
                print("[Parsing] Unknown data type for \(child.label ?? "UNKNOWN"). Will ignore.")
            }
            print("[Parsing] offset \(offset): \(child.label ?? "UNKNOWN") = \(values[child.label!] ?? "UNKNOWN")")
            offset += len
        }
        return values
    }

    func dump() -> String {
        do {
            let data = self.getData()
            let nsData = NSData(data: data)
            let dumped = try nsData.compressed(using: .zlib).base64EncodedString()
            return dumped
        } catch {
            print("Error: failed to encode and compress parameters.")
            return ""
        }
    }

    mutating func parse(_ str: String) throws {
        guard let nsData = NSData(base64Encoded: str) else {
            print("Error: invalid base64 string.")
            throw PresetError.corrupted
        }
        guard let decompressed = try? nsData.decompressed(using: .zlib) else {
            print("Error: failed to decompress data.")
            throw PresetError.corrupted
        }
        let data = Data(decompressed)
        let dataMap = try loadDataMap(data)
        self.inject(from: dataMap)
    }
}

//
//  HSWaveform.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/7.
//

import Foundation


enum HSWaveform {
    case sine
    case square
    case saw
    case triangle
    case pulse

    private func pulseWave(pulseSize: Float = 0.25) -> [Table.Element] {
        var table = [Table.Element](zeros: 4096)
        for i in 0..<4096 {
            table[i] = i < Int(4096.0 * (pulseSize)) ? Float(1): Float(-1)
        }
        return table
    }

    func getTable() -> Table {
        switch self {
        case .sine:
            return Table(.sine)
        case .square:
            return Table(.square)
        case .saw:
            return Table(.sawtooth)
        case .triangle:
            return Table(.triangle)
        case .pulse:
            return Table(pulseWave())
        }
    }

    func getSymbolImageName() -> String {
        let names: [HSWaveform: String] = [
            .sine: "wave-sine",
            .square: "wave-square",
            .saw: "wave-saw",
            .triangle: "wave-triangle",
            .pulse: "wave-pulse"
        ]
        return names[self]!
    }

    func getReadableName() -> String {
        let names: [HSWaveform: String] = [
            .sine: "Sine",
            .square: "Square",
            .saw: "Saw",
            .triangle: "Triangle",
            .pulse: "Pulse"
        ]
        return names[self]!
    }
}

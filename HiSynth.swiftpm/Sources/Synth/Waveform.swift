//
//  HSWaveform.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/7.
//

import Foundation


/// Waveforms used in HSOscillator (for generating sound) and LowFreqOscillator (for modulating parameters).
enum HSWaveform: Int8, HSEnum {
    case sine = 0
    case square = 1
    case saw = 2
    case triangle = 3
    case pulse = 4
    case rsaw = 5// Only used in LFOs

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
        case .rsaw:
            return Table(.reverseSawtooth)
        }
    }

    func getSymbolImageName() -> String {
        let names: [HSWaveform: String] = [
            .sine: "wave-sine",
            .square: "wave-square",
            .saw: "wave-saw",
            .triangle: "wave-triangle",
            .pulse: "wave-pulse",
            .rsaw: "wave-rsaw",
        ]
        return names[self]!
    }

    func getReadableName() -> String {
        let names: [HSWaveform: String] = [
            .sine: "Sine",
            .square: "Square",
            .saw: "Saw",
            .triangle: "Triangle",
            .pulse: "Pulse",
            .rsaw: "Reversed Saw"
        ]
        return names[self]!
    }
}

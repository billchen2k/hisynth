//
//  LFOController.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/11.
//

import Foundation

class LFOController: ObservableObject {
    static let lfoCount: Int = 3

    var lfos: [LowFreqOscillator]

    @Published var managing: Int = 0

    @Published var waveforms: [HSWaveform] {
        didSet {
            lfos.enumerated().forEach { $1.waveform = waveforms[$0] }
        }
    }

    @Published var depths: [AUValue] {
        didSet {
            lfos.enumerated().forEach { $1.depth = depths[$0] }
        }
    }

    @Published var speeds: [AUValue] {
        didSet {
            lfos.enumerated().forEach { $1.speed = speeds[$0] }
        }
    }

    @Published var phases: [AUValue] {
        didSet {
            lfos.enumerated().forEach { $1.phaseOffset = phases[$0] }
        }
    }

    @Published var modPitch: [Bool] {
        didSet {
            pitchMod?.ifModulate = modPitch
        }
    }


    @Published var modAmplitude: [Bool] {
        didSet {
            amplitudeMod?.ifModulate = modAmplitude
        }
    }

    @Published var modFilterLow: [Bool] {
        didSet {
            filterLowMod?.ifModulate = modFilterLow
        }
    }

    @Published var modFilterHigh: [Bool] {
        didSet {
            filterHighMod?.ifModulate = modFilterHigh
        }
    }

    var connectors: [HasModulatorConnector]

    var pitchMod: Modulator?
    var amplitudeMod: Modulator?
    var filterLowMod: Modulator?
    var filterHighMod: Modulator?

    init(connectors: [HasModulatorConnector]) {
        var lfos: [LowFreqOscillator] = []
        for _ in 0..<LFOController.lfoCount {
            lfos.append(LowFreqOscillator(waveform: .sine, phaseOffset: 0.0, depth: 0.0, speed: 2.0))
        }
        waveforms = lfos.map { $0.waveform }
        depths = lfos.map { $0.depth }
        speeds = lfos.map { $0.speed }
        phases = lfos.map { $0.phaseOffset }
        modPitch = Array(repeating: false, count: LFOController.lfoCount)
        modAmplitude = Array(repeating: false, count: LFOController.lfoCount)
        modFilterLow = Array(repeating: false, count: LFOController.lfoCount)
        modFilterHigh = Array(repeating: false, count: LFOController.lfoCount)

        lfos.forEach { $0.start() }
        connectors.forEach { $0.connectModulator(lfos: lfos)}

        self.connectors = connectors
        self.lfos = lfos
    }

    public func sync() {
        lfos.forEach { lfo in
            lfo.sync()
        }
    }
}


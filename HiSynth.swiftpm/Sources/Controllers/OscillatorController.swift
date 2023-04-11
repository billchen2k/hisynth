//
//  OscillatorController.swift
//
//
//  Created by Bill Chen on 2023/4/6.
//

import Foundation
import AVFoundation

class OscillatorController: ObservableObject, HasKeyHandlar, HasModulatorConnector {

    @Published var waveform1: HSWaveform = .sine {
        didSet {
            if osc1.waveform == waveform1 { return }
            print("Set osc1 waveform to \(waveform1.getReadableName())")
            osc1.waveform = waveform1
        }
    }
    @Published var waveform2: HSWaveform = .sine {
        didSet {
            if osc2.waveform == waveform2 { return }
            osc2.waveform = waveform2
        }
    }

    @Published var level1: Float = 0.75 {
        didSet {
            osc1.level = level1
        }
    }

    @Published var level2: Float = 0.75 {
        didSet {
            osc2.level = level2
        }
    }

    @Published var pitch1: Float = 0 {
        didSet {
            osc1.pitchOffset = Int8(pitch1)
        }
    }
    @Published var pitch2: Float = 0 {
        didSet {
            osc2.pitchOffset = Int8(pitch2)
        }
    }

    var pitchModulator: Modulator?

    var osc1: PolyOscillator
    var osc2: PolyOscillator

    init(oscs: [PolyOscillator]) {
        guard oscs.count == 2 else {
            fatalError("Expecting 2 poly oscillators in the controller.")
        }
        self.osc1 = oscs[0]
        self.osc2 = oscs[1]
    }

    func noteOn(_ pitch: Pitch) {
        osc1.noteOn(pitch)
        osc2.noteOn(pitch)
    }

    func noteOff(_ pitch: Pitch) {
        osc1.noteOff(pitch)
        osc2.noteOff(pitch)
    }

    func connectModulator(lfos: [LowFreqOscillator]) {
        let oscillatorPitch = ModulatableCustomParam(440.0) { v in
            (0..<PolyOscillator.oscCount).forEach( {
                self.osc1.oscPool[$0].frequency = self.osc1.frequencies[$0] + v
                self.osc2.oscPool[$0].frequency = self.osc2.frequencies[$0] + v
            })
        }
        let pitchMod = Modulator(target: oscillatorPitch, range: -0.1...0.1, log: true, lfos: lfos)
        pitchMod.start()
        self.pitchModulator = pitchMod
    }
}

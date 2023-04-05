//
//  HiSynthCore.swift
//
//
//  Created by Bill Chen on 2023/4/3.
//
import AVFoundation
import Foundation
import AudioKit
import SoundpipeAudioKit
import Keyboard
import SporthAudioKit

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

class OscillatorController: ObservableObject {
    @Published var waveform = HSWaveform.sine
    @Published var level: Float = 0.5

    var mixer = Mixer()
    var oscPool: [DynamicOscillator] = []
    var envPool: [AmplitudeEnvelope] = []
    var generators: [OperationEffect] = []
    var oscCount = 8

    /// MIDINotenumber -> oscNumber or nil for not playing. Used for voice allocation
    var allocated: [Int8: Int] = [:]

    /// MIDINoteNumber stack for tracking voice stealing
    var voices: [Int8] = []

    init(waveform: HSWaveform = HSWaveform.saw, level: Float = 0.8) {
        self.waveform = waveform
        self.level = level
        // Load oscillators
        for _ in 0..<oscCount {
            let osc = DynamicOscillator()
            osc.setWaveform(waveform.getTable())
            osc.amplitude = 0.0
            osc.start()
            let env = AmplitudeEnvelope(osc)
            env.attackDuration = 0.5
            env.releaseDuration = 0.5
            env.start()
            oscPool.append(osc)
            envPool.append(env)


            // AM LFO
            let lfo = OperationEffect(env) { osc, parameters in
                parameters.forEach{ print($0.description) }
                let oscillator = Operation.sineWave(frequency: 1.5).scale(minimum: 0, maximum: 1)

                let amped = osc
                return amped.lowPassFilter(halfPowerPoint: oscillator * parameters[0])
            }
            generators.append(lfo)

            lfo.parameter1 = 5000

            mixer.addInput(lfo)
        }
    }

    func noteOn(_ pitch: Pitch) {
        // Find the first not playing osc for voice allocation
        let oscIndex = (0..<oscCount).first{ !Set(allocated.values).contains($0) }
        if let oscIndex = oscIndex {
            let osc = oscPool[oscIndex]
            osc.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
            generators[oscIndex].start()
            envPool[oscIndex].openGate()
            osc.amplitude = level
            allocated[pitch.midiNoteNumber] = oscIndex
            voices.append(pitch.midiNoteNumber)
        } else {
            // No enough oscillators. Perform voice stealing
            let toStealNote = voices.first
            if let toStealNote = toStealNote {
                guard let toStealOscIndex = allocated[toStealNote] else {
                    print("Error: Voice stealing error, can not find the oscillator to stop. toStealNote: \(toStealNote).")
                    return
                }
                print("Info: Maximum polyphony reached. Stealing note \(toStealNote).")
                oscPool[toStealOscIndex].frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
                allocated[toStealNote] = toStealOscIndex
                envPool[toStealOscIndex].openGate()
                voices.removeFirst()
                voices.append(pitch.midiNoteNumber)
            } else {
                print("Warning: no voices to steal.")
            }
        }
    }

    func noteOff(_ pitch: Pitch) {
        let oscIndex = allocated[pitch.midiNoteNumber]
        if let oscIndex = oscIndex {
            //            oscPool[oscIndex].amplitude = 0.0
            generators[oscIndex].stop()
            envPool[oscIndex].closeGate()
            // Asynchrolly set to nil after 0.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + 0.1) {
                self.allocated[pitch.midiNoteNumber] = nil
            }
//          allocated[pitch.midiNoteNumber] = nil
        } else {
            print("Warning: noteOff called on a note that is not playing.")
        }
        voices.removeAll { $0 == pitch.midiNoteNumber }
    }

}

class LFOController: ObservableObject {

}

class EnvelopeController: ObservableObject {

}

class FilterController: ObservableObject {

}

class SFXController: ObservableObject {

}

class HiSynthCore: ObservableObject, HasAudioEngine {
    var engine = AudioEngine()
    @Published var oscillatorController = OscillatorController()
    @Published var lfoController = LFOController()
    @Published var envelopeController = EnvelopeController()
    @Published var filterController = FilterController()
    @Published var sfxController = SFXController()

    init() {
        engine.output = oscillatorController.mixer
        do {
            try engine.start()
        } catch {
            print("Error: engine start failed.")
        }
    }
    func noteOn(pitch: Pitch, point: CGPoint) {
        print("Note on:", pitch.midiNoteNumber)
        oscillatorController.noteOn(pitch)
    }

    func noteOff(pitch: Pitch) {
        print("Pitch off:", pitch.midiNoteNumber)
        oscillatorController.noteOff(pitch)
    }
}

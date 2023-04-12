//
//  HiSynthCore.swift
//
//
//  Created by Bill Chen on 2023/4/3.
//
import AVFoundation
import Foundation
//
//class OscillatorControllerTest: ObservableObject {
//    @Published var waveform = HSWaveform.sine
//    @Published var level: Float = 0.5
//
//    var mixer = Mixer()
//    var oscMixer = Mixer()
//    var oscPool: [DynamicOscillator] = []
//    var envPool: [AmplitudeEnvelope] = []
//    var lfos: [OperationEffect] = []
//    var oscCount = 8
//
//    /// MIDINotenumber -> oscNumber or nil for not playing. Used for voice allocation
//    var allocated: [Int8: Int] = [:]
//
//    /// MIDINoteNumber stack for tracking voice stealing
//    var voices: [Int8] = []
//
//    /// Track noteOff tasks controlling releaseing oscillators that can be cancelled.
//    var noteTasks: [Int8: DispatchWorkItem] = [:]
//
//    var oscillatorQueue = DispatchQueue(label: "io.billc.hisynth.oscillator", qos: .userInteractive)
//
//    init(waveform: HSWaveform = HSWaveform.saw, level: Float = 0.8) {
//        self.waveform = waveform
//        self.level = level
//        // Load oscillators
//        for _ in 0..<oscCount {
//            let osc = DynamicOscillator()
//            osc.setWaveform(waveform.getTable())
//            osc.amplitude = 0.0
//            osc.start()
//            let env = AmplitudeEnvelope(osc)
//            env.attackDuration = 0.5
//            env.releaseDuration = 0.5
//            env.start()
//            oscPool.append(osc)
//            envPool.append(env)
//
//            oscMixer.addInput(env)
//        }
//        // AM LFO
//        let lfo = OperationEffect(oscMixer) { osc, parameters in
//            parameters.forEach{ print($0.description) }
//            let oscillator = Operation.sineWave(frequency: 3).scale(minimum: 0, maximum: 1)
//
//            let amped = osc
//            return amped.lowPassFilter(halfPowerPoint: oscillator * parameters[0])
//        }
//        lfo.start()
//        lfos.append(lfo)
//
//        lfo.parameter1 = 5000
//
//        let reverbed = Reverb(lfo)
//        mixer.addInput(reverbed)
//    }
//
//    func noteOn(_ pitch: Pitch) {
//        // Cancel previous release task
//        if let previousTask = noteTasks[pitch.midiNoteNumber] {
//            previousTask.cancel()
//        }
//
//        // Find the first not playing osc for voice allocation
//        let oscIndex = (0..<oscCount).first{ !Set(allocated.values).contains($0) }
//        if let oscIndex = oscIndex {
//            let osc = oscPool[oscIndex]
//            osc.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
//            envPool[oscIndex].openGate()
//            osc.amplitude = level
//            allocated[pitch.midiNoteNumber] = oscIndex
//            voices.append(pitch.midiNoteNumber)
//            // Start lfo for syncing if it is the first note of the gruop
//            if voices.count == 1 {
//                lfos[0].start()
//            }
//        } else {
//            // No enough oscillators. Perform voice stealing
//            let toStealNote = voices.first
//            if let toStealNote = toStealNote {
//                guard let toStealOscIndex = allocated[toStealNote] else {
//                    print("Error: Voice stealing error, can not find the oscillator to stop. toStealNote: \(toStealNote).")
//                    return
//                }
//                print("Info: Maximum polyphony reached. Stealing note \(toStealNote).")
//                oscPool[toStealOscIndex].frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
//                allocated[toStealNote] = toStealOscIndex
//                envPool[toStealOscIndex].openGate()
////                lfos[toStealOscIndex].start()
//                voices.removeFirst()
//                voices.append(pitch.midiNoteNumber)
//            } else {
//                print("Warning: no voices to steal.")
//            }
//        }
//    }
//
//    func noteOff(_ pitch: Pitch) {
//        print(allocated)
//        print(voices)
//        let oscIndex = allocated[pitch.midiNoteNumber]
//        if let oscIndex = oscIndex {
//            //            oscPool[oscIndex].amplitude = 0.0
////            lfos[oscIndex].stop()
//            envPool[oscIndex].closeGate()
//            // Asynchrolly set allocated voice to nil after sustain finishes.
//            let task = DispatchWorkItem {
//                self.allocated[pitch.midiNoteNumber] = nil
//            }
//            oscillatorQueue.asyncAfter(deadline: .now() + Double(envPool[oscIndex].releaseDuration) + 0.1, execute: task)
//            noteTasks[pitch.midiNoteNumber] = task
//        } else {
//            print("Warning: noteOff called on a note that is not playing.")
//        }
//        self.voices.removeAll { $0 == pitch.midiNoteNumber }
//    }
//
//

class HiSynthCore: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var polyOscillators: [PolyOscillator]

    @Published var oscillatorController: OscillatorController
    @Published var envelopeController: EnvelopeController
    @Published var filterController: FilterController
    @Published var lfoController: LFOController
    @Published var sfxController = SFXController()

    init() {
        polyOscillators = [PolyOscillator(), PolyOscillator()]
        let oscillatorController = OscillatorController(oscs: polyOscillators)
        let envelopeController = EnvelopeController(oscs: polyOscillators)
        let filterController = FilterController(envelopeController.outputNode)

        self.oscillatorController = oscillatorController
        self.envelopeController = envelopeController
        self.filterController = filterController
        engine.output = filterController.outputNode

        let lfoController = LFOController(connectors: [oscillatorController, filterController])
        lfoController.amplitudeMod = filterController.amplitudeModulator
        lfoController.filterLowMod = filterController.lowPassModulator
        lfoController.filterHighMod = filterController.highPassModulator
        lfoController.pitchMod = oscillatorController.pitchModulator
        self.lfoController = lfoController
    }

    func noteOn(pitch: Pitch, point: CGPoint) {
        print("Note on:", pitch.midiNoteNumber)
        // If it is the first note, sync the lfo.
        if oscillatorController.osc1.voices.count == 0 || oscillatorController.osc2.voices.count == 0 {
            lfoController.sync()
        }
        oscillatorController.noteOn(pitch)
    }

    func noteOff(pitch: Pitch) {
        print("Note off:", pitch.midiNoteNumber)
        oscillatorController.noteOff(pitch)
    }

    func start() {
        do {
            try engine.start()
        } catch {
            print("Error: engine start failed.")
        }
        envelopeController.setup()
        filterController.setup()
    }
}

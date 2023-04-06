//
//  PolyOscillator.swift
//  
//
//  Created by Bill Chen on 2023/4/4.
//

import AudioKit
import Tonic
import AVFoundation
import SoundpipeAudioKit
import Foundation

class PolyOscillator: HasKeyHandlar {

    var outputNode: Mixer = Mixer()

    var waveform = HSWaveform.sine {
        didSet {
            oscPool.forEach { $0.setWaveform(waveform.getTable()) }
        }
    }
    var level: Float = 0.75 {
        didSet {
            oscPool.forEach { $0.amplitude = level }
        }
    }
    var pitchOffset: Int8 = 0

    var attackDuration: AUValue = 0.005 {
        didSet {
            envPool.forEach { $0.attackDuration = attackDuration }
        }
    }
    var decayDuration: AUValue = 0.0 {
        didSet {
            envPool.forEach { $0.decayDuration = decayDuration }
        }
    }

    var sustainLevel: AUValue = 1.0 {
        didSet {
            envPool.forEach { $0.sustainLevel = sustainLevel }
        }
    }
    var releaseDuration: AUValue = 0.005 {
        didSet {
            envPool.forEach { $0.releaseDuration = releaseDuration }
        }
    }

    var oscPool: [DynamicOscillator] = []
    var envPool: [AmplitudeEnvelope] = []

    var oscCount: Int = 8

    /// MIDINotenumber -> oscNumber or nil for not playing. Used for voice allocation
    var allocated: [Int8: Int] = [:]

    /// MIDINoteNumber stack for tracking note order. Used for voice stealing
    var voices: [Int8] = []

    /// Track noteOff tasks controlling releaseing oscillators that can be cancelled.
    var noteTasks: [Int8: DispatchWorkItem] = [:]

    /// userInteractive qos queue for handling note release tasks.
    var taskQueue = DispatchQueue(label: "io.billc.hisynth.oscillator", qos: .userInteractive)

    init() {
        for _ in 0..<oscCount {
            let osc = DynamicOscillator()
            osc.setWaveform(waveform.getTable())
            osc.amplitude = level
            let env = AmplitudeEnvelope(osc)
            env.attackDuration = attackDuration
            env.decayDuration = decayDuration
            env.sustainLevel = sustainLevel
            env.releaseDuration = releaseDuration
            oscPool.append(osc)
            envPool.append(env)
            osc.start()
            env.start()
            outputNode.addInput(env)
        }
    }

    func noteOn(_ pitch: Pitch) {
        // Cancel previous noteOff task for unsetting `allocated`
        if let previousTask = noteTasks[pitch.midiNoteNumber] {
            previousTask.cancel()
        }

        var idx = (0..<oscCount).first{ !Set(allocated.values).contains($0) }
        // Find the first not playing osc for voice allocation
        if idx == nil {
            // Perform voice stealing.
            guard let toStealNote = voices.first else {
                print("Warning: no voice to steal.")
                return
            }
            print("Info: Maximum polyphony reached. Stealing note \(toStealNote).")
            guard let toStealIdx = allocated[toStealNote] else {
                print("Error: Voice stealing error, can not find the oscillator to stop. toStealNote: \(toStealNote).")
                return
            }
            idx = toStealIdx
            voices.removeFirst()
        }

        // Voice allocation
        oscPool[idx!].frequency = AUValue(pitch.midiNoteNumber + pitchOffset).midiNoteToFrequency()
        envPool[idx!].openGate()
        voices.append(pitch.midiNoteNumber)
        allocated[pitch.midiNoteNumber] = idx!
    }

    func noteOff(_ pitch: Pitch) {
        print(allocated)
        print(voices)
        let idx = allocated[pitch.midiNoteNumber]
        if let idx = idx {
            envPool[idx].closeGate()
            let task = DispatchWorkItem {
                self.allocated[pitch.midiNoteNumber] = nil
            }
            taskQueue.asyncAfter(deadline: .now() + Double(envPool[idx].releaseDuration) + 0.1, execute: task)
            noteTasks[pitch.midiNoteNumber] = task
        } else {
            print("Warning: noteOff called on a note that is not playing.")
        }
        self.voices.removeAll { $0 == pitch.midiNoteNumber }
    }
}

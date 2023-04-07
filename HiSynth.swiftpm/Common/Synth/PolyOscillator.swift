//
//  PolyOscillator.swift
//  
//
//  Created by Bill Chen on 2023/4/4.
//

import AVFoundation
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

    var oscPool: [HSOscillator] = []
    var envPool: [AmplitudeEnvelope] = []

    var oscCount: Int = 12

    /// MIDINotenumber -> oscNumber or nil for not playing. Used for voice allocation
    var allocated: [Int8: Int] = [:]

    /// MIDINoteNumber stack for tracking note order. Used for voice stealing
    var voices: [Int8] = []

    /// Track noteOff tasks controlling releaseing oscillators that can be cancelled.
    var noteTasks: [Int8: DispatchWorkItem] = [:]

    /// userInteractive qos queue for handling note release tasks.
    var taskQueue = DispatchQueue(label: "io.billc.hisynth.oscillator", qos: .userInteractive)

    var taskLock = NSLock()

//    let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
//    var phase: Int = 0


    init() {
        for _ in 0..<oscCount {
            let osc = HSOscillator()
            osc.setWaveform(waveform.getTable())
            osc.amplitude = level
            let env = AmplitudeEnvelope(osc)
            env.attackDuration = attackDuration
            env.decayDuration = decayDuration
            env.sustainLevel = sustainLevel
            env.releaseDuration = releaseDuration
            oscPool.append(osc)
            envPool.append(env)
            env.start()
            osc.start()
            outputNode.addInput(env)
        }
//        timer.schedule(deadline: .now(), repeating: .milliseconds(1))
//
//        let waveform = AudioKit.Table(.sine)
//
//        timer.setEventHandler {
//            self.phase += 1
//            self.outputNode.volume = waveform.content[self.phase % waveform.content.count] * 0.5 + 0.5
//        }
//        timer.resume()
    }

    func noteOn(_ pitch: Pitch) {
        // Cancel previous noteOff task for unsetting `allocated`
        if let previousTask = noteTasks[pitch.midiNoteNumber] {
            previousTask.cancel()
            if let previousIdx = allocated[pitch.midiNoteNumber] {
                envPool[previousIdx].hardCloseGate()
            }
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

        print("Info: Playing note \(pitch.midiNoteNumber) on osc \(idx!)")
        // Voice allocation
        oscPool[idx!].frequency = AUValue(pitch.midiNoteNumber + pitchOffset).midiNoteToFrequency()
        envPool[idx!].openGate()
        voices.append(pitch.midiNoteNumber)
        allocated[pitch.midiNoteNumber] = idx!
    }

    func noteOff(_ pitch: Pitch) {
        print("Info: allocated: ", allocated, "voices: ", voices)
        let idx = allocated[pitch.midiNoteNumber]
        if let idx = idx {
            envPool[idx].closeGate()
            let task = DispatchWorkItem {
                self.taskLock.lock()
                self.allocated[pitch.midiNoteNumber] = nil
                self.taskLock.unlock()
            }
            // Release the oscillator after 0.3 seconds.
            taskQueue.asyncAfter(deadline: .now() + Double(envPool[idx].releaseDuration) + 0.3, execute: task)
            noteTasks[pitch.midiNoteNumber] = task
        } else {
            print("Warning: noteOff called on a note that is not playing.")
        }
        self.voices.removeAll { $0 == pitch.midiNoteNumber }
    }
}

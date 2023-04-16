//
//  LowFreqOscillator.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/6.
//

import Foundation
import AVFoundation

typealias LFOHandler =  ((Float) -> Void)

/// Low Frequency Oscillator used for molulating the parameters including pitch, amplitude, and filters' cut off frequency.
class LowFreqOscillator {
    var waveform: HSWaveform

    /// Phase offset of the LFO waveform, ranging from 0 to 1
    var phaseOffset: Float

    /// Depth multiplier, ranging from 0 - 1.0
    var depth: Float {
        didSet {
            if depth == 0 {
                stop()
            } else {
                start()
            }
        }
    }

    /// Frequency of the LFO in Hertz.
    var speed: Float

    /// LFO Callbacks. A value ranging from -1.0 to 1.0 will be passed for modulating other parameters.
    var callbacks: [LFOHandler] = []

    /// Sample rate of the LFO (Call back frequecny). Can only be updated during initialization.
    let sampleRate: Float

    public var currentPhase: Float = 0.0
    public var isStarted: Bool = false
    
    private var timer: DispatchSourceTimer?
    private var timerQueue = DispatchQueue(label: "io.billc.hisynth.lfo")
    private let timerSource: DispatchSourceTimer

    init(waveform: HSWaveform = .sine,
         phaseOffset: Float = 0.0,
         depth: Float = 1.0,
         speed: Float = 1.0,
         sampleRate: Float = 60.0,
         callback: ((Float) -> Void)? = nil) {
        guard speed > 0 else {
            fatalError("LFO speed must be greater than 0")
        }
        guard depth >= 0 else {
            fatalError("LFO depth must be greater than or equal to 0")
        }
        guard phaseOffset >= 0 && phaseOffset <= 1 else {
            fatalError("LFO phase offset must be between 0 and 1")
        }
        guard sampleRate > 0 else {
            fatalError("LFO sample rate must be greater than 0")
        }
        self.waveform = waveform
        self.phaseOffset = phaseOffset
        self.depth = depth
        self.speed = speed
        self.sampleRate = sampleRate
        self.timerSource = DispatchSource.makeTimerSource(flags: [.strict], queue: self.timerQueue)
        setupTimer()
    }

    private func setupTimer() {
        timerSource.schedule(deadline: .now(), repeating: .milliseconds(Int(1000 / sampleRate)))
        timerSource.setEventHandler { [weak self] in
            self?.update()
        }
        timerSource.resume()
    }

    private func update() {
        if !isStarted {
            for callback in callbacks {
                callback(0.0)
            }
            return
        }
        let content = waveform.getTable().content
        var phase = currentPhase + speed / sampleRate
        phase = phase - floor(phase)
        var offsetPhase = phase + phaseOffset
        offsetPhase = offsetPhase - floor(offsetPhase)
        let index = Int(offsetPhase * Float(content.count))
        let value = content[index]
        for callback in callbacks {
            callback(Float(value) * self.depth)
        }
        currentPhase = phase
    }

    public func start() {
//        if depth == 0 {
//            return
//        }
        isStarted = true
    }

    public func stop() {
        isStarted = false
    }

    /// Reset the phase of the LFO.
    public func sync() {
        currentPhase = 0
    }
}

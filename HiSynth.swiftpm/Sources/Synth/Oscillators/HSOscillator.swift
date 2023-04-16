//
//  HSOscillator.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/7.
//

import Foundation
import CoreAudio
import AVFoundation

/// This Oscillator is used as HiSynth's sound source.
/// It is adapted from AudioKit's `PlaygroundOscillator`.
///     Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
///
/// Modifications:
///
///     1. Added the ability to update waveforms.
///     2. Fixed bugs that will cause the oscillator to freeze when running on Mac `Catalyst`.
///     3. Guard the frequency to be within 10Hz to 22kHz.
public class HSOscillator: Node {
    fileprivate lazy var sourceNode = AVAudioSourceNode { [self] _, _, frameCount, audioBufferList in
        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

        let phaseIncrement = (twoPi / Float(Settings.sampleRate)) * self.frequency
        for frame in 0 ..< Int(frameCount) {
            // Get signal value for this frame at time.
            let index = Int(self.currentPhase / twoPi * Float(self.waveform!.count))
            let value = self.waveform![index] * self.amplitude

            // Advance the phase for the next frame.
            self.currentPhase += phaseIncrement
            if self.currentPhase >= twoPi { self.currentPhase -= twoPi }
            if self.currentPhase < 0.0 { self.currentPhase += twoPi }
            // Set the same value on all channels (due to the inputFormat we have only 1 channel though).
            for buffer in ablPointer {
                let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                buf[frame] = value
            }
        }
        return noErr
    }

    /// Connected nodes
    public var connections: [Node] { [] }

    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode { sourceNode }

    private var currentPhase: Float = 0

    fileprivate var waveform: Table?

    /// Pitch in Hz
    private var _frequency: Float = 440

    public var frequency: Float {
        get { _frequency }
        set {
            _frequency = max(10, min(newValue, 22_000))
        }
    }

    /// Volume usually 0-1
    public var amplitude: AUValue = 1

    /// Initialize the pure Swift oscillator, suitable for Playgrounds
    /// - Parameters:
    ///   - waveform: Shape of the oscillator waveform
    ///   - frequency: Pitch in Hz
    ///   - amplitude: Volume, usually 0-1
    public init(waveform: Table = Table(.sine), frequency: AUValue = 440, amplitude: AUValue = 1) {
        self.waveform = waveform
        self.frequency = frequency
        self.amplitude = amplitude
        stop()
    }

    /// Sets the wavetable of the oscillator node
    /// - Parameter waveform: The waveform of oscillation
    public func setWaveform(_ waveform: Table) {
        self.waveform = waveform
    }
}

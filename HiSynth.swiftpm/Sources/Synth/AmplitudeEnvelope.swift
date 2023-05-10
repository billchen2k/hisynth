//
//  AmplitudeEnvelope.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/6.
//

import Foundation
import AVFoundation
import SpriteKit
import AudioKit

public class AmplitudeEnvelope: Node, Gated {

    fileprivate let au = AVAudioMixerNode()
    let input: Node

    public var connections: [Node] { [input] }

    public var avAudioNode: AVAudioNode

    var attackDuration: AUValue = 0.005
    var decayDuration: AUValue = 0.1
    var sustainLevel: AUValue = 1.0
    var releaseDuration: AUValue = 0.1

    private let taskQueue = DispatchQueue(label: "io.billc.hisynth.envelope", qos: .userInteractive)
    private var taskId: UInt8 = 0

    public init(
        _ input: Node,
        attackDuration: AUValue = 0.1,
        decayDuration: AUValue = 0.1,
        sustainLevel: AUValue = 1.0,
        releaseDuration: AUValue = 0.1
    ) {
        self.input = input
        self.attackDuration = attackDuration
        self.decayDuration = decayDuration
        self.sustainLevel = sustainLevel
        self.releaseDuration = releaseDuration
        self.avAudioNode = au
        self.au.volume = 0.0
    }

    public func openGate() {
        taskId &+= 1
        // Activate envelope when gate opened for the first time
        if au.volume == 0.0 {
            au.volume = 1.0
        }
        // Immediate Attack
        if attackDuration + decayDuration <= 1e-3 {
            au.outputVolume = 1.0
            return
        }
        let currentTaskId = taskId
        taskQueue.async {
            let attackStep = 1.0 / (self.attackDuration * 1000)
            let decayStep = (1.0 - self.sustainLevel) / (self.decayDuration * 1000)

            var currentLevel: AUValue = 0.0

            // Attack phase
            while currentLevel < 1.0 {
                if self.taskId != currentTaskId {
                    return
                }
                currentLevel = min(currentLevel + attackStep, 1.0)
                self.au.outputVolume = currentLevel
                usleep(1000) // 1 millisecond
            }

            // Decay phase
            while currentLevel > self.sustainLevel {
                if self.taskId != currentTaskId {
                    return
                }
                currentLevel = max(currentLevel - decayStep, self.sustainLevel)
                self.au.outputVolume = currentLevel
                usleep(1000)
            }
        }
    }

    public func closeGate() {
        taskId &+= 1
        // Immediate Release
        if releaseDuration <= 0.05 || sustainLevel <= 0.05 {
            au.outputVolume = 0.0
            return
        }
        let currentTaskId = taskId
        taskQueue.async {
            let releaseStep = self.sustainLevel / (self.releaseDuration * 1000)
            var currentLevel: AUValue = self.au.outputVolume
            if currentLevel > self.sustainLevel {
                currentLevel = self.sustainLevel
            }
            // Release phase
            while currentLevel > 0.0 {
                if self.taskId != currentTaskId {
                    return
                }
                currentLevel = max(currentLevel - releaseStep, 0.0)
                self.au.outputVolume = currentLevel
                usleep(1000)
            }
        }
    }

    public func hardCloseGate() {
        au.outputVolume = 0.0
    }

    public func hardOpenGate () {
        au.outputVolume = 1.0
    }
}

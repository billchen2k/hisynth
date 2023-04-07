//
//  File.swift
//
//
//  Created by Bill Chen on 2023/4/6.
//

import Foundation
import AVFoundation
import SpriteKit

class ADSRScene: SKScene {
    var attackDuration: CGFloat = 0.1
    var decayDuration: CGFloat = 0.1
    var sustainLevel: CGFloat = 1.0
    var releaseDuration: CGFloat = 0.1

    var env: AmplitudeEnvelope?
    private var curvePath: CGMutablePath!
    private var curveNode: SKShapeNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        size = view.frame.size
        view.allowsTransparency = true
        createCurve()
    }

    override func update(_ currentTime: TimeInterval) {
        removeChildren(in: [curveNode])
        createCurve()
    }

    func createCurve() {
        guard let env = env else {
            return
        }
        curvePath = CGMutablePath()
        let a = CGFloat(env.attackDuration)
        let d = CGFloat(env.decayDuration)
        let s = CGFloat(env.sustainLevel)
        let r = CGFloat(env.releaseDuration)
        

        let attackPoint = CGPoint(x: CGFloat(env.attackDuration) * size.width, y: size.height)
        let decayPoint = CGPoint(x: (CGFloat(env.attackDuration) + CGFloat(env.decayDuration)) * size.width, y: CGFloat(env.sustainLevel) * size.height)
        let releasePoint = CGPoint(x: (CGFloat(env.attackDuration) + CGFloat(env.decayDuration) + CGFloat(env.releaseDuration)) * size.width, y: 0)
        
        curvePath.move(to: .zero)
        curvePath.addLine(to: attackPoint)
        curvePath.addLine(to: decayPoint)
        curvePath.addLine(to: releasePoint)

        curveNode = SKShapeNode(path: curvePath)
        curveNode.strokeColor = Theme.colorHighlight.uiColor
        curveNode.lineWidth = 3.0
        addChild(curveNode)
    }

    func noteOn() {
        // Add the gradient animation here
    }
}
//
//
//public class AmplitudeEnvelope: Mixer, Gated {
//
//    var attackDuration: AUValue = 0.005
//    var decayDuration: AUValue = 0.1
//    var sustainLevel: AUValue = 1.0
//    var releaseDuration: AUValue = 0.1
//
//    var au: AVAudioMixerNode {
//        avAudioNode as! AVAudioMixerNode
//    }
//
//    private let taskQueue = DispatchQueue(label: "io.billc.hisynth.envelope", qos: .userInteractive)
//    private var taskId: UInt8 = 0
//
//    public func openGate() {
//        // Activate envelope when gate opened for the first time
//        if au.volume == 0.0 {
//            au.volume = 1.0
//        }
//        // Immediate Attack
//        if attackDuration <= 1e-3 {
//            au.outputVolume = 1.0
//            return
//        }
//        taskId += 1
//        let currentTaskId = taskId
//        taskQueue.async {
//            let attackStep = 1.0 / (self.attackDuration * 1000)
//            let decayStep = (1.0 - self.sustainLevel) / (self.decayDuration * 1000)
//
//            var currentLevel: AUValue = 0.0
//
//            // Attack phase
//            while currentLevel < 1.0 {
//                if self.taskId != currentTaskId {
//                    return
//                }
//                currentLevel = min(currentLevel + attackStep, 1.0)
//                self.au.outputVolume = currentLevel
//                usleep(1000) // 1 millisecond
//            }
//
//            // Decay phase
//            while currentLevel > self.sustainLevel {
//                if self.taskId != currentTaskId {
//                    return
//                }
//                currentLevel = max(currentLevel - decayStep, self.sustainLevel)
//                print(self.au.outputVolume)
//                usleep(1000)
//            }
//        }
//    }
//
//    public func closeGate() {
//        // Immediate Release
//        if releaseDuration <= 1e-3 {
//            au.outputVolume = 0.0
//            return
//        }
//        taskId += 1
//        let currentTaskId = taskId
//        taskQueue.async {
//            let releaseStep = self.sustainLevel / (self.releaseDuration * 1000)
//            var currentLevel: AUValue = self.au.outputVolume
//
//            // Release phase
//            while currentLevel > 0.0 {
//                if self.taskId != currentTaskId {
//                    return
//                }
//                currentLevel = max(currentLevel - releaseStep, 0.0)
//                self.au.outputVolume = currentLevel
//                usleep(1000)
//            }
//        }
//    }
//}


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
        // Activate envelope when gate opened for the first time
        if au.volume == 0.0 {
            au.volume = 1.0
        }
        // Immediate Attack
        if attackDuration <= 1e-3 {
            au.outputVolume = 1.0
            return
        }
        taskId &+= 1
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
                print(self.au.outputVolume)
                usleep(1000)
            }
        }
    }

    public func closeGate() {
        // Immediate Release
        if releaseDuration <= 1e-3 {
            au.outputVolume = 0.0
            return
        }
        taskId &+= 1
        let currentTaskId = taskId
        taskQueue.async {
            let releaseStep = self.sustainLevel / (self.releaseDuration * 1000)
            var currentLevel: AUValue = self.au.outputVolume

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
}

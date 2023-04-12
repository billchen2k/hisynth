//
//  LFOScene.swift
//  HiSynth
//  
//
//  Created by Bill Chen on 2023/4/12.
//

import Foundation
import SpriteKit

class LFOScene: SKScene {

    var lfo: LowFreqOscillator? {
        didSet {
            createCurve()
            createPhasePos()
        }
    }

    var curveNode: SKShapeNode?
    var grayCurveNode: SKShapeNode?
    var phasePosNode: SKShapeNode?

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        size = view.frame.size
        createCurve()
        createPhasePos()
    }
    
    override func update(_ currentTime: TimeInterval) {
        createCurve()
        updatePhasePos()
    }

    private func getCurvePath(color: UIColor, depth: Float) -> CGPath {
        let content = lfo!.waveform.getTable()
        let path = CGMutablePath()
        path.move(to: CGPoint(0.0, CGFloat((content[0] * 0.95 * depth + 1.0)) / 2.0 * size.height))
        for i in stride(from: 0, to: content.count, by: 100) {
            let x = CGFloat(i) / CGFloat(content.count) * size.width
            let y = CGFloat((content[i] * 0.95 * depth + 1.0)) / 2.0 * size.height
            path.addLine(to: CGPoint(x, y))
        }
        // Repeat for phase offset
        for i in stride(from: 0, to: content.count, by: 100) {
            let x = CGFloat(i) / CGFloat(content.count) * size.width + size.width
            let y = CGFloat((content[i] * 0.95 * depth + 1.0)) / 2.0 * size.height
            path.addLine(to: CGPoint(x, y))
        }
        return path
    }

    func createCurve() {
        guard let lfo = lfo else {
            return
        }
        curveNode?.removeFromParent()
        grayCurveNode?.removeFromParent()

        // lineWidth
        let w: CGFloat = 2.0

        let grayCurvePath = getCurvePath(color: .darkGray, depth: 1.0)
        let grayCurveNode = SKShapeNode(path: grayCurvePath)
        grayCurveNode.lineWidth = w
        grayCurveNode.strokeColor = .darkGray
        grayCurveNode.position = CGPoint(-CGFloat(lfo.phaseOffset) * size.width, 0.0)
        self.grayCurveNode = grayCurveNode
        addChild(grayCurveNode)

        let curvePath = getCurvePath(color: lfo.depth <= 0.01 ? .lightGray : Theme.colorHighlight.uiColor,
                                     depth: lfo.depth)
        let curveNode = SKShapeNode(path: curvePath)
        curveNode.lineWidth = w
        curveNode.strokeColor = Theme.colorHighlight.uiColor
        curveNode.position = CGPoint(-CGFloat(lfo.phaseOffset) * size.width, 0.0)
        self.curveNode = curveNode
        addChild(curveNode)
    }

    func createPhasePos() {
        guard let lfo = lfo else {
            return
        }
        phasePosNode?.removeFromParent()
        let phasePosNode = SKShapeNode(rect: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height + 20.0))
        phasePosNode.fillShader = SKShader(fileNamed: "HorizontalGradient.fsh")
        phasePosNode.strokeColor = Theme.colorHighlight.uiColor
        self.phasePosNode = phasePosNode
        addChild(phasePosNode)
    }

    func updatePhasePos() {
        guard let lfo = lfo else {
            return
        }
        if lfo.isStarted {
            phasePosNode!.position = CGPoint(CGFloat(lfo.currentPhase) * size.width - phasePosNode!.frame.width, -10.0)
        } else {
            phasePosNode!.position = CGPoint(-phasePosNode!.frame.width, -10.0)
        }

    }
}

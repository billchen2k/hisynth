//
//  ADSRScene.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/7.
//

import Foundation
import SpriteKit

/// An ADSR scene to render envelope curve
class ADSRScene: SKScene {

    var env: AmplitudeEnvelope?
    private var curvePath: CGMutablePath!
    private var curveNode: SKShapeNode!
    private var tickNodes: [SKShapeNode]!

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        size = view.frame.size
        view.allowsTransparency = true
        createCurve()
    }

    override func update(_ currentTime: TimeInterval) {
        removeAllChildren()
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

        let maxLen = 6.0
        let scale = pow((a + d + r), 0.5) * maxLen / pow(maxLen, 0.5) / size.width

        // lineWidth
        let w: CGFloat = 2.0

        let attackPoint = CGPoint(x: a / scale + w, y: size.height - w)
        let decayPoint = CGPoint(x: (a + d) / scale + w, y: s * size.height - w)
        let releasePoint = CGPoint(x: (a + d + r) / scale + w, y: w)

        curvePath.move(to: CGPoint(x: w, y: w))
        curvePath.addLine(to: attackPoint)
        curvePath.addLine(to: decayPoint)
        curvePath.addLine(to: releasePoint)

        curveNode = SKShapeNode(path: curvePath)
        curveNode.strokeColor = Theme.colorHighlight.uiColor
        curveNode.lineWidth = w


        let fillPath = curvePath.mutableCopy()!
        fillPath.addLine(to: CGPoint(x: w, y: w))
        let fillNode = SKShapeNode(path: fillPath)
        let gradient = SKShader(fileNamed: "ScreenCurveGradient.fsh")
        fillNode.fillShader = gradient
        fillNode.fillColor = .clear
        fillNode.strokeColor = .clear

        addChild(fillNode)
        addChild(curveNode)


        // Create Ticks
        let tickSpacing = 0.1 / scale
        for x in stride(from: 0, to: size.width, by: tickSpacing) {
            let tickNode = SKSpriteNode(color: .darkGray, size: CGSize(width: 1, height: 5))
            tickNode.anchorPoint = CGPoint(x: 0.5, y: 0)
            tickNode.position = CGPoint(x: x, y: 0)
            addChild(tickNode)
        }
        for x in stride(from: 0, to: size.width, by: tickSpacing * 10) {
            let tickNode = SKSpriteNode(color: .gray, size: CGSize(width: 1, height: 10))
            tickNode.anchorPoint = CGPoint(x: 0.5, y: 0)
            tickNode.position = CGPoint(x: x, y: 0)
            addChild(tickNode)
        }

        // Create Gradient

        // Create Texts
        let textNode = SKLabelNode(text: "A \(Int(a * 1000))ms D \(Int(d * 1000))ms S \(Double(s).levelToDb().round(1))dB R \(Int(r * 1000))ms")
        textNode.fontSize = 9
        textNode.fontName = "Menlo"
        textNode.fontColor = .lightGray
        textNode.horizontalAlignmentMode = .right
        textNode.verticalAlignmentMode = .top
        textNode.position = CGPoint(x: size.width - 5, y: size.height - 5)
        addChild(textNode)
    }

    func noteOn() {
        // Add the gradient animation here
    }
}

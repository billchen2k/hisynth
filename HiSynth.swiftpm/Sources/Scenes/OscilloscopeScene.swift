//
//  OscilloscopeScene.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/16.
//

import Foundation
import SpriteKit
import AudioKit

class OscilloscopeScene: SKScene {
    var controller: RackController!

    private var input: Node {
        controller.inputNode
    }
    private var tap: RawDataTap!

    private var curveNode: SKShapeNode?
    private var taskQueue = DispatchQueue(label: "io.billc.hisynth.oscilloscope")

    private var precision = 10 // Maximum precision = 1

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        size = view.frame.size
        self.tap = RawDataTap(input, bufferSize: UInt32(1024), callbackQueue: taskQueue)
        self.tap.start()
    }

    override func update(_ currentTime: TimeInterval) {
        if let curve = curveNode {
            curve.removeFromParent()
        }
        let path = CGMutablePath()
        path.move(to: CGPoint(0, size.height / 2.0))
        for i in stride(from: 0, to: tap.data.count - 1, by: precision) {
            let x: CGFloat = CGFloat(i) / CGFloat(tap.data.count) * size.width
            let y: CGFloat = CGFloat(tap.data[i]) * size.height / 2.0 + size.height / 2.0
            path.addLine(to: CGPoint(x, y))
        }
        let node = SKShapeNode(path: path)
        node.strokeColor = Theme.colorHighlight.uiColor
        node.lineWidth = 1.0
        addChild(node)
        self.curveNode = node
    }
}

//
//  KeyboardView.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/2.
//

import SwiftUI
import Keyboard



//import SpriteKit
//
//struct KeyboardView: UIViewRepresentable {
//    func makeUIView(context: Context) -> SKView {
//        // Create an SKView to display the SpriteKit scene
//        let view = SKView()
//        view.showsFPS = true
//        view.showsNodeCount = true
//
//        // Create the SpriteKit scene and add it to the view
//        let scene = KeyboardScene(size: view.frame.size)
//        scene.scaleMode = .resizeFill
//        view.presentScene(scene)
//
//        return view
//    }
//
//    func updateUIView(_ view: SKView, context: Context) {
//        // Update the view as needed
//    }
//}
//
//class KeyboardScene: SKScene {
//    let numberOfKeys = 88
//    let whiteKeyWidth: CGFloat = 30.0
//    let blackKeyWidth: CGFloat = 20.0
//
//    override func didMove(to view: SKView) {
//        // Add the white and black keys to the scene
//        for keyIndex in 0..<numberOfKeys {
//            let isWhiteKey = isWhiteKeyAtIndex(index: keyIndex)
//            let key = SKShapeNode(rectOf: CGSize(width: isWhiteKey ? whiteKeyWidth : blackKeyWidth, height: 100))
//            key.fillColor = isWhiteKey ? SKColor.white : SKColor.black
//            key.strokeColor = SKColor.clear
//            key.position = CGPoint(x: CGFloat(keyIndex) * whiteKeyWidth, y: 0)
//            addChild(key)
//        }
//    }
//
//    func isWhiteKeyAtIndex(index: Int) -> Bool {
//        let whiteKeyIndices = [0, 2, 4, 5, 7, 9, 11]
//        _ = (index / 12) + 1
//        let keyIndexInOctave = index % 12
//        return whiteKeyIndices.contains(keyIndexInOctave)
//    }
//}

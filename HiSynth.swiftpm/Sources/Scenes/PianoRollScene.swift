//
//  PianoRollScene.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/17.
//

import Foundation
import SpriteKit

class PianoRollScene: SKScene {

    var manager: NoteHistoryManager!

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        size = view.frame.size
    }

    override func update(_ currentTime: TimeInterval) {
        createBars()
    }

    private func time2X(time: TimeInterval) -> CGFloat {
        return size.width - CGFloat(Date().timeIntervalSince1970 - time) / NoteHistoryManager.intervalLimit * size.width
    }

    private func pitch2Y(pitch: Pitch) -> CGFloat {
        let minPitch = Pitch(33)
        let maxPitch = Pitch(105)
        return CGFloat(pitch.midiNoteNumber - minPitch.midiNoteNumber) / CGFloat(maxPitch.midiNoteNumber - minPitch.midiNoteNumber) * size.height
    }

    private func createBars() {
        removeAllChildren()
        for note in manager.noteHistory {
            let offTime = note.offTime == 0 ? Date().timeIntervalSince1970 : note.offTime
            let bar = SKShapeNode(rect: CGRect(x: time2X(time: note.onTime),
                                               y: pitch2Y(pitch: note.pitch),
                                               width: time2X(time: offTime) - time2X(time: note.onTime),
                                               height: 2.0))
            bar.fillColor = Theme.colorHighlight.uiColor
            bar.strokeColor = .clear
            addChild(bar)
        }
    }
}

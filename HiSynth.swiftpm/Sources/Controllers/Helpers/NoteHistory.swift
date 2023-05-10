//
//  NoteHistory.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/16.
//

import Foundation
import Tonic

struct NoteHistory {
    var pitch: Pitch = Pitch(0)
    var onTime: TimeInterval = 0.0
    var offTime: TimeInterval = 0.0

    init(pitch: Pitch) {
        self.pitch = pitch
        self.onTime = Date().timeIntervalSince1970
    }

    mutating public func off() {
        self.offTime = Date().timeIntervalSince1970
    }
}

class NoteHistoryManager {

    static let lengthLimit = 64
    static let intervalLimit = 4.0 // seconds

    var noteHistory: [NoteHistory] = []

    func on(_ pitch: Pitch) {
        noteHistory.append(NoteHistory(pitch: pitch))

        if noteHistory.count > NoteHistoryManager.lengthLimit {
            noteHistory.removeFirst()
        }
    }

    func off(_ pitch: Pitch) {
        guard let index = noteHistory.lastIndex(where: { $0.pitch.midiNoteNumber == pitch.midiNoteNumber }) else {
            return
        }
        noteHistory[index].off()
    }
}

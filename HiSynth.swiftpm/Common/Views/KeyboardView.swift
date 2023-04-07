//
//  KeyboardView.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/2.
//

import SwiftUI

struct KeyboardView: View {

    @ObservedObject var core: HiSynthCore

    var body: some View {
        Keyboard(layout: KeyboardLayout.piano(pitchRange: Pitch(48)...Pitch(72)),
                 noteOn: core.noteOn, noteOff: core.noteOff) { (pitch, on) in
            KeyboardKey(pitch: pitch, isActivated: on, pressedColor: Theme.colorHighlight, flatTop: true)
        }
    }
}

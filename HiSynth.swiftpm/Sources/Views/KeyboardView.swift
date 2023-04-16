//
//  KeyboardView.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/2.
//

import SwiftUI

struct KeyboardView: View {

    @ObservedObject var core: HiSynthCore
    @ObservedObject var rackController: RackController

    var pitchRange: ClosedRange<Pitch> {
        Pitch(12 * rackController.octave)...Pitch(12 * (rackController.octave + 2))
    }

    var controller: RackController {
        core.rackController
    }

    var body: some View {
        Keyboard(layout: KeyboardLayout.piano(pitchRange: pitchRange),
                 noteOn: core.noteOn, noteOff: core.noteOff) { (pitch, on) in
            KeyboardKey(pitch: pitch,
                        isActivated: on,
                        pressedColor: Theme.colorHighlight,
                        flatTop: true,
                        isActivatedExternally: rackController.externalActivatedNotes.contains(pitch))
        }
    }
}

//
//  AudioEffects.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/12.
//

import Foundation

class AudioEffects {

    var inputNode: Node
    var outputNode: Node

    /// Audio Effects chain: Decimator -> Drive -> Delay -> Reverb
    var decimator: Decimator
    var drive: Distortion
    var delay: Delay
    /// Factory presets supported in HiSynth: small/medium/largeRoom + Plate
    var reverb: Reverb

    init(_ input: Node) {
        self.inputNode = input
        let decimator = Decimator(input)
        let drive = Distortion(decimator)
        let delay = Delay(drive)
        let reverb = Reverb(delay)
        self.decimator = decimator
        self.drive = drive
        self.delay = delay
        self.reverb = reverb
        self.outputNode = reverb
    }
}

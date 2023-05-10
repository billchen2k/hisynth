//
//  EnvelopeController.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/6.
//

import Foundation
import AVFoundation
import AudioKit

class EnvelopeController: ObservableObject {

    @Published var attackDuration: AUValue = 0.0 {
        didSet {
            osc1.attackDuration = attackDuration
            osc2.attackDuration = attackDuration
        }
    }
    @Published var decayDuration: AUValue = 0.5 {
        didSet {
            osc1.decayDuration = decayDuration
            osc2.decayDuration = decayDuration
        }
    }
    @Published var sustainLevel: AUValue = 1.0 {
        didSet {
            osc1.sustainLevel = sustainLevel
            osc2.sustainLevel = sustainLevel
        }
    }
    @Published var releaseDuration: AUValue = 0.1 {
        didSet {
            osc1.releaseDuration = releaseDuration
            osc2.releaseDuration = releaseDuration
        }
    }

    var outputNode: Mixer = Mixer()

    var osc1: PolyOscillator
    var osc2: PolyOscillator

    init(oscs: [PolyOscillator]) {
        guard oscs.count == 2 else {
            fatalError("Expecting 2 poly oscillators in the controller.")
        }
        osc1 = oscs[0]
        osc2 = oscs[1]
        outputNode.addInput(osc1.outputNode)
        outputNode.addInput(osc2.outputNode)
    }

    public func setup() {
        attackDuration = 0.0
        decayDuration = 0.5
        sustainLevel = 1.0
        releaseDuration = 0.05
    }
}

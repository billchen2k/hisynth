//
//  SFXController.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/12.
//

import Foundation
import AVFoundation

enum HSReverbType: Int8, HSEnum {
    case plate = 0
    case room = 1
    case hall = 2

    func getReadableName() -> String {
        switch self {
        case .plate:
            return "Plate"
        case .room:
            return "Room"
        case .hall:
            return "Hall"
        }
    }
}

class AFXController: ObservableObject {

    /// **Decimator Controls**

    @Published var decimatorOn: Bool = false {
        didSet {
            afx.decimator.bypassed = !decimatorOn
        }
    }
    // Percent, 0 - 100
    @Published var decimatorRate: Float = 50 {
        didSet {
            afx.decimator.decimation = decimatorRate
        }
    }
    @Published var decimatorMix: Float = 20.0 {
        didSet {
            afx.decimator.finalMix = decimatorMix
        }
    }

    /// **Reverb Controls**

    @Published var reverbOn: Bool = false {
        didSet {
            if reverbOn {
                afx.reverb.play()
            } else {
                afx.reverb.bypass()
            }
        }
    }
    @Published var reverbType: HSReverbType = .room {
        didSet {
            updateReverbType()
        }
    }
    // 1 for small, 2 for medium 3 for large
    @Published var reverbSize: Float = 2.0 {
        didSet {
            updateReverbType()
        }
    }
    @Published var reverbMix: Float = 0.5 {
        didSet {
            afx.reverb.dryWetMix = reverbMix
        }
    }

    /// **Drive Controls**

    @Published var driveOn: Bool = false {
        didSet {
            afx.drive.bypassed = !driveOn
        }
    }
    @Published var driveGain: Float = 0.0 {
        didSet {
            afx.drive.softClipGain = driveGain
        }
    }
    @Published var driveMix: Float = 50.0 {
        didSet {
            afx.drive.polynomialMix = driveMix
        }
    }

    /// **Delay Controls**

    @Published var delayOn: Bool = false {
        didSet {
            afx.delay.bypassed = !delayOn
        }
    }
    // Seconds
    @Published var delayTime: Float = 0.5 {
        didSet {
            afx.delay.time = delayTime
        }
    }
    // Percent, -100 - 100
    @Published var delayFeedback: Float = 10.0 {
        didSet {
            afx.delay.feedback = delayFeedback
        }
    }
    @Published var delayMix: Float = 50.0 {
        didSet {
            afx.delay.dryWetMix = delayMix
        }
    }

    var afx: AudioEffects
    var outputNode: Node

    init(_ input: Node) {
        self.afx = AudioEffects(input)
        self.outputNode = self.afx.outputNode
    }

    private func updateReverbType() {
        switch self.reverbType {
        case .room:
            if reverbSize == 1.0 {
                afx.reverb.loadFactoryPreset(.smallRoom)
            } else if reverbSize == 2.0 {
                afx.reverb.loadFactoryPreset(.mediumRoom)
            } else {
                afx.reverb.loadFactoryPreset(.largeRoom)
            }
        case .hall:
            if reverbSize == 1.0 {
                afx.reverb.loadFactoryPreset(.mediumHall)
            } else if reverbSize == 2.0 {
                afx.reverb.loadFactoryPreset(.largeHall)
            } else if reverbSize == 3.0 {
                afx.reverb.loadFactoryPreset(.largeHall2)
            }
        case .plate:
            afx.reverb.loadFactoryPreset(.plate)
        }
    }

    public func setup() {
        reverbSize = 2.0
        reverbType = .room
        reverbMix = 50.0
        reverbOn = false

        delayFeedback = 50
        delayTime = 0.5
        delayMix = 50.0
        delayOn = false

        decimatorRate = 20.0
        decimatorMix = 50.0
        decimatorOn = false

        driveGain = 10.0
        driveMix = 50.0
        driveOn = false
    }
}


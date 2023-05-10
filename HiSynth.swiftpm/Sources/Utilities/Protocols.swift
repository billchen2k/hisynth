//
//  Protocols.swift
//  
//
//  Created by Bill Chen on 2023/4/6.
//

import Foundation
import AudioKit
import Keyboard

protocol HasKeyHandlar {
    func noteOn(_ pitch: Pitch)
    func noteOff(_ pitch: Pitch)
}

protocol HasModulatorConnector {
    func connectModulator(lfos: [LowFreqOscillator])
}

protocol Modulatable {
    var baseValue: AUValue { get set }
    var modulatedValue: AUValue { get }
    mutating func modulate(_ value: Float)
}

protocol HSEnum {
    var rawValue: Int8 { get }
    func getReadableName() -> String
}

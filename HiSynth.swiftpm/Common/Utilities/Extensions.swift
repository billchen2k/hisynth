//
//  Extensions.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/3.
//

import Foundation
import SwiftUI

extension Color {

    /// Initiate SwiftUI colors with hex code.
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }

    var uiColor: UIColor {
        return UIColor(self)
    }
}

/// To allow nodes to be gated
public protocol Gated {
    /// Start the gate
    func openGate()
    /// Stop the gate
    func closeGate()
}

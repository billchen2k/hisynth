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

extension CGPoint {
    init(_ x: CGFloat, _ y: CGFloat) {
        self.init(x: x, y: y)
    }
}

extension Double {

    /// Round to decimal
    func round(_ places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    // 0 - 1 level to -60dB ~ 0dB
    func levelToDb () -> Double {
        if self <= 0.001 {
            return -60
        }
        return 20 * log10(self)
    }
}

extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}

extension Comparable {

    @inlinable func clamp(to: ClosedRange<Self>) -> Self {
        return min(max(self, to.lowerBound), to.upperBound)
    }
}

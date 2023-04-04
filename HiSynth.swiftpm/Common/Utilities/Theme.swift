//
//  Theme.swift
//
//
//  Created by Bill Chen on 2023/4/3.
//

import Foundation
import SwiftUI

struct Theme {
    static let colorHighlight = Color(hex: 0x4fbcd4)
    static let colorGray1 = Color(hex: 0x222222)
    static let colorGray2 = Color(hex: 0x333333)
    static let colorGray3 = Color(hex: 0x4a4a4a)
    static let colorGray4 = Color(hex: 0x666666)
    static let colorText = Color(hex: 0xcccccc)
    static let gradientKnob = LinearGradient(gradient: Gradient(
        colors: [Color(hex: 0x151515), Color(hex: 0x131313)]), startPoint: .top, endPoint: .bottom)
}



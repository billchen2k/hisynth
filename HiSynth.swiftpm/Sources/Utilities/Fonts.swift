//
//  Fonts.swift
//  
//
//  Created by Bill Chen on 2023/4/5.
//

import Foundation
import SwiftUI

class Fonts {

    /// Register custom fonts inside Swift Packages without Info.plist.
    ///     Reference: https://jacobzivandesign.com/technology/custom-fonts-from-swift-package/
    /// - Parameters:
    ///   - bundle: Bundle to look up for the resource.
    ///   - fontName: Font **file** name.
    ///   - fontExtension: Font file extension.
    public static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) {
        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension),
              let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider) else {
            fatalError("Couldn't create font from filename: \(fontName) with extension \(fontExtension)")
        }
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(font, &error)
    }


    /// Register all fonts required by HiSynth.
    public static func registerAllFonts() {
        Fonts.registerFont(bundle: .main, fontName: "Michroma-Regular", fontExtension: ".ttf")
    }
}


enum HSFontType {

    /// Main text fonts.
    case body1

    /// Small text fonts.
    case body2

    /// Mono fonts to display on the knob
    case bodyMono

    /// Small fonts to display on the knob
    case body3

    /// Title for walkthrough panels.
    case title1

    /// Title for large text on the display screen.
    case title2

    /// Title for small text on the display screen.
    case title3

    /// Title for HiSynth Logo (gradient)
    case artTitle0

    /// Title to use together with large text title (walkthrough panels, no gradient).
    case artTitle1

    /// Title for control panel titles (gradient, light).
    case artTitle2
}

struct HSFont: ViewModifier {

    var fontType: HSFontType

    init(_ fontType: HSFontType) {
        self.fontType = fontType
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        switch fontType {
        case .body1:
            content
                .font(.system(size: 13.0, weight: .regular))
                .foregroundColor(Theme.colorBodyText)
        case .body2:
            content.font(.system(size: 11.0, weight: .regular))
                .foregroundColor(Theme.colorBodyText)
        case .body3:
            content.font(.system(size: 9.0, weight: .regular))
                .foregroundColor(Theme.colorBodyText)
        case .bodyMono:
            content.font(.system(size: 9.0, weight: .regular, design: .monospaced))
                .foregroundColor(Theme.colorBodyText)
        case .title1:
            content.font(.system(size: 24.0, weight: .regular))
                .foregroundColor(Theme.colorTitleText)
        case .title2:
            content.font(.system(size: 20.0, weight: .bold))
                .foregroundColor(Theme.colorTitleText)
        case .title3:
            content.font(.system(size: 14.0, weight: .regular))
                .foregroundColor(Theme.colorTitleText)
        case .artTitle0:
            content.font(.custom("Michroma", size: 30.0))
                .foregroundStyle(Theme.gradientArtTitle())
                .opacity(0.8)
        case .artTitle1:
            content.font(.custom("Michroma", size: 24.0))
                .foregroundColor(Theme.colorTitleText)
        case .artTitle2:
            content.font(.custom("Michroma", size: 16.0))
                .foregroundStyle(Theme.gradientArtTitle())
                .opacity(0.7)
        }
    }
}

struct HSFont_Previews: PreviewProvider {

    static var previews: some View {
        VStack{
            Text("Low Frequency Oscillator")
                .modifier(HSFont(.artTitle2))
        }.background(.black)

    }
}

/// To allow nodes to be gated
public protocol Gated {
    /// Start the gate
    func openGate()
    /// Stop the gate
    func closeGate()
}

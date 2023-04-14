//
//  HSKnob.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/4.
//

import Foundation
import SwiftUI

struct HSKnob: View {
    @Binding var value: Float
    @State private var isDragging = false
    @State private var oldValue: Float = 0

    var range: ClosedRange<Float> = 0...1
    var size: CGFloat = 80.0

    /// Set how many steps should the knob have.
    var stepSize: Float = 0.01

    /// Set if when value = 0, the signal light will be turned gray.
    var allowPoweroff = true

    /// If show value on the know
    var ifShowValue = false

    /// Set the sensitivity of the dragging gesture.
    var sensitivity: Float = 0.3

    var valueFormatter: ((Float) -> String) = { String(format: "%.2f", $0) }

    var onChanged: ((Float) -> Void)?

    let startingAngle: Angle = .radians(.pi / 6)

    var normalizedValue: Float {
        Float((value - range.lowerBound) / (range.upperBound - range.lowerBound))
    }

    var body: some View {
        return ZStack{
            Circle()
                .shadow(color: Color(hex: 0x000000, alpha: 0.6), radius: 8.0, x: 0, y: 6.0)
                .foregroundStyle(Theme.gradientKnob)
                .frame(width: size, height: size)
                .overlay {
                    Circle()
                        .stroke(.white, lineWidth: 3.0)
                        .blur(radius: 2.0)
                        .offset(x: 0.0, y: 2.0)
                        .opacity(0.25)
                        .frame(width: size + 2.0, height: size + 2.0)
                        .mask(Circle().frame(width: size, height: size))
                }

            if ifShowValue {
                ScreenBox(isOn: false, blankStyle: true, width: 25, height: 16) {
                    Text(valueFormatter(value))
                        .modifier(HSFont(.bodyMono))
                }
            }
            if allowPoweroff && normalizedValue == 0.0 {
                Circle()
                    .fill(Theme.colorGray4)
                    .frame(width: size / 12, height: size / 12.0)
                    .offset(y: size / 2.0 * 0.7)
                    .rotationEffect(startingAngle)
                    .rotationEffect((.radians(2 * .pi) - startingAngle * 2) * Double(normalizedValue))
            } else {
                Circle()
                    .fill(Theme.colorHighlight)
                    .shadow(color: Theme.colorHighlight, radius: 5.0)
                    .shadow(color: Theme.colorHighlight, radius: 10.0)
                    .frame(width: size / 12, height: size / 12.0)
                    .offset(y: size / 2.0 * 0.7)
                    .rotationEffect(startingAngle)
                    .rotationEffect((.radians(2 * .pi) - startingAngle * 2) * Double(normalizedValue))
            }
        }.gesture(DragGesture(minimumDistance: 0)
            .onChanged { value in
                updateValue(from: value)
            }
            .onEnded { _ in
                isDragging = false
            }
        )
    }

    private func updateValue(from value: DragGesture.Value) {
        if !isDragging {
            oldValue = self.value
            isDragging = true
        }
        let x = value.translation.width
        let y = -value.translation.height
        var offset: Float = 0.0
        offset += Float(x / size) * (range.upperBound - range.lowerBound) * sensitivity
        offset += Float(y / size) * (range.upperBound - range.lowerBound) * sensitivity
        let clippedValue = max(range.lowerBound, min(range.upperBound, self.oldValue + offset))
        let steppedValue = (clippedValue / stepSize).rounded() * stepSize
        self.value = steppedValue
        if oldValue != steppedValue {
            print(steppedValue)
            self.onChanged?(steppedValue)
        }
    }
}


struct HSKnob_Container: View {
    @State var value: Float = 0.5
    var body: some View {
        HSKnob(value: $value)
    }
}

struct HSKnob_Previews: PreviewProvider {
    static var previews: some View {
        HSKnob_Container()
    }
}

//
//  HSSlider.swift
//
//
//  Created by Bill Chen on 2023/4/5.
//

import Foundation
import SwiftUI

struct HSSlider: View {

    @Binding var value: Float
    @State var isDragging = false
    @State var oldValue: Float = 0.0

    var range: ClosedRange<Float> = 1.0...100.0

    /// Step size of the range.
    var stepSize: Float = 0.01

    var width: CGFloat = 45.0
    var height: CGFloat = 180.0

    /// Set if when value = 0, the signal light will be turned gray.
    var allowPoweroff = true

    /// Set the sensitivity of the dragging gesture.
    var sensitivity: Float = 1.0

    var onChanged: ((Float) -> Void)?

    var normalizedValue: Float {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    var steps: Int {
        Int((range.upperBound - range.lowerBound) / stepSize) + 1
    }

    var body: some View {

        let numberOfTicks = steps >= 10 ? 10 : steps
        let thumbImageName =  allowPoweroff && normalizedValue == 0.0 ? "slider-thumb-off" : "slider-thumb-on"

        return ZStack {
            // Ticks
            VStack {
                ForEach(0..<numberOfTicks) {index in
                    Rectangle().fill(Theme.colorGray4)
                        .cornerRadius(4.0)
                        .frame(width: width, height: 2.0)
                    if index < numberOfTicks - 1 {
                        Spacer()
                    }
                }
            }.frame(height: height * 0.9)
            // Track
            HStack{
                Spacer()
                Rectangle()
                    .fill(Theme.colorGray1)
                    .frame(width: 4.0, height: height)
                    .cornerRadius(4.0)
                    .overlay {
                        RoundedRectangle(cornerRadius: 4.0)
                            .stroke(Theme.colorGray3, lineWidth: 1.0)
                    }
                Spacer()
            }
            // Thumb
            VStack {
                Spacer()
                Image(thumbImageName)
                    .resizable()
                    .shadow(color: .black.opacity(0.8), radius: 4.0, x: 0.0, y: 4.0)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width)
                    .offset(y: -CGFloat(normalizedValue) * (height * 0.9))
                    .gesture(DragGesture(minimumDistance: 0.0)
                        .onChanged { v in
                            updateValue(from: v)
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                    )
            }
        }.frame(width: width, height: height)
    }

    private func updateValue(from value: DragGesture.Value) {
        if !isDragging {
            oldValue = self.value
            isDragging = true
        }
        let y = -value.translation.height
        var offset: Float = 0.0
        offset = Float(y / height) * (range.upperBound - range.lowerBound) * sensitivity
        let UnsteppedValue = max(range.lowerBound, min(range.upperBound, self.oldValue + offset))
        let steppedValue = (UnsteppedValue / stepSize).rounded() * stepSize
        self.value = steppedValue
        if oldValue != steppedValue {
            self.onChanged?(steppedValue)
        }
    }
}

struct HSSlider_Container: View {

    @State var value: Float = 1.0

    var body: some View {
        HSSlider(value: $value)
    }
}


struct Slider_Previews: PreviewProvider {
    static var previews: some View {
        HSSlider_Container()
    }
}

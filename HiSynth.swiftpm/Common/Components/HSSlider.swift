//
//  HSSlider.swift
//  HiSynth
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

    /// Step size of the range. If it is a log scale, the output value won't be stepped. This size will only be used for rendering ticks.
    var stepSize: Float = 0.01

    var width: CGFloat = 45.0
    var height: CGFloat = 180.0

    /// Set if when value = 0, the signal light will be turned gray.
    var allowPoweroff = true

    /// If the scale is logarithm
    var log: Bool = false

    /// Set the sensitivity of the dragging gesture.
    var sensitivity: Float = 1.0

    var onChanged: ((Float) -> Void)?

    /// Normalized value of the slider between 0.0 - 1.0
    var normalizedValue: Float {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    var steps: Int {
        Int((range.upperBound - range.lowerBound) / stepSize) + 1
    }

    private var thumbOffset: CGFloat {
        if log {
            if value > 0.0 {
                let logValue = log10(CGFloat(value / range.lowerBound))
                let logRange = log10(CGFloat(range.upperBound / range.lowerBound))
                return logValue / logRange * (height * 0.9)
            } else {
//                print("Warning: trying to set negative value with a log slider: \(value)")
                return 0.0
            }
        } else {
            return CGFloat(normalizedValue) * (height * 0.9)
        }
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
                    .offset(y: -thumbOffset)
                    .gesture(DragGesture(minimumDistance: 1.0)
                        .onChanged { v in
                            updateValue(from: -v.translation.height)
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                    )
            }
        }.frame(width: width, height: height)
        // Allow click @TODO
//            .gesture(
//                DragGesture(minimumDistance: 0)
//                    .onEnded { v in
//                        isDragging = false
//                        print("TAP", v.translation)
//                        print("START", v.startLocation)
//                        if v.translation.height <= 0.1 {
//                            updateValue(from: v.startLocation.y + thumbOffset)
//                        }
//                    }
//            )
    }

    /// Update value with offset.
    private func updateValue(from y: CGFloat) {
        if !isDragging {
            oldValue = self.value
            isDragging = true
        }
        var newValue: Float
        if log {
            let ratio = Float(y / (height * 0.9)) * sensitivity
            newValue = pow(10, log10(self.oldValue) + ratio * log10(range.upperBound / range.lowerBound))
            newValue = max(range.lowerBound, min(range.upperBound, newValue))
        } else {
            let offset = Float(y / height) * (range.upperBound - range.lowerBound) * sensitivity
            let unsteppedValue = max(range.lowerBound, min(range.upperBound, self.oldValue + offset))
            newValue = (unsteppedValue / stepSize).rounded() * stepSize
        }
        self.value = newValue
        print(newValue)
        self.onChanged?(newValue)
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


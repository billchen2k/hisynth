//
//  File.swift
//
//
//  Created by Bill Chen on 2023/4/7.
//

import Foundation
import SpriteKit
import AVFoundation

class FilterScene: SKScene {
    var controller: FilterController!
    var tap: FFTTap!
    var mixer: Mixer {
        controller.outputNode
    }

    var maxAmplitude: Float = 0.0
    var minAmplitude: Float = -70.0
    var referenceValueForFFT: Float = 12.0
    var amplitudes: [Float?] = Array(repeating: 0.0, count: 1024)

    let numberOfBars: Int = 128
    var barNodes: [SKSpriteNode] = []

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        size = view.frame.size
        self.tap = FFTTap(mixer, callbackQueue: .main) { fftData in
            // fftData is an array of size 2048
            self.updateAmplitudes(fftData)
        }
        tap.isNormalized = false
        tap.start()
        createBars()
    }

    override func update(_ currentTime: TimeInterval) {
        updateBars()
    }

    private func updateAmplitudes(_ fftData: [Float]) {
        let fftSize = fftData.count
        // loop by two through all the fft data
        for i in stride(from: 0, to: fftSize - 1, by: 2) {
            // get the real and imaginary parts of the complex number
            let real = fftData[i]
            let imaginary = fftData[i + 1]

            let normalizedBinMagnitude = 2.0 * sqrt(real * real + imaginary * imaginary) / Float(fftSize)
            let amplitude = (20.0 * log10(normalizedBinMagnitude))

            // scale the resulting data
            var scaledAmplitude = (amplitude + 250) / 229.8
            scaledAmplitude = scaledAmplitude.clamped(to: 0...1)

            scaledAmplitude = (scaledAmplitude - 0.3) / 0.6

            DispatchQueue.main.async {
                if i / 2 < self.amplitudes.count {
                    self.amplitudes[i / 2] = scaledAmplitude
                }
            }
        }
//        var fftData = fftFloats
//        for index in 0 ..< fftData.count {
//            if fftData[index].isNaN { fftData[index] = 0.0 }
//        }
//        var one = Float(1.0)
//        var zero = Float(0.0)
//        var decibelNormalizationFactor = Float(1.0 / (maxAmplitude - minAmplitude))
//        var decibelNormalizationOffset = Float(-minAmplitude / (maxAmplitude - minAmplitude))
//
//        var decibels = [Float](repeating: 0, count: fftData.count)
//        vDSP_vdbcon(fftData, 1, &referenceValueForFFT, &decibels, 1, vDSP_Length(fftData.count), 0)
//
//        vDSP_vsmsa(decibels,
//                   1,
//                   &decibelNormalizationFactor,
//                   &decibelNormalizationOffset,
//                   &decibels,
//                   1,
//                   vDSP_Length(decibels.count))
//
//        vDSP_vclip(decibels, 1, &zero, &one, &decibels, 1, vDSP_Length(decibels.count))
//
//        DispatchQueue.main.async {
//            self.amplitudes = decibels
//        }
    }

    private func createBars() {
        let barWidth = size.width / CGFloat(numberOfBars)
        for index in 0..<numberOfBars {
            let bar = SKSpriteNode(color: .darkGray, size: CGSize(width: barWidth * 0.8, height: 1))
            bar.position = CGPoint(x: barWidth * CGFloat(index) + barWidth / 2, y: 0)
            bar.anchorPoint = CGPoint(x: 0.5, y: 0)
            addChild(bar)
            barNodes.append(bar)
        }
    }

    private func updateBars() {
        guard amplitudes.count >= numberOfBars else { return }
        let minLogFrequency = Float(log10(20.0))
        let maxLogFrequency = Float(log10(20_000.0))
        let logFrequencyStep = (maxLogFrequency - minLogFrequency) / Float(numberOfBars)

        for (index, bar) in barNodes.enumerated() {
            let lowerLogFrequency = minLogFrequency + Float(index) * logFrequencyStep
            let upperLogFrequency = lowerLogFrequency + logFrequencyStep

            let lowerFrequency = pow(10, lowerLogFrequency)
            let upperFrequency = pow(10, upperLogFrequency)

            let lowerIndex = Int(lowerFrequency * Float(amplitudes.count) / 20_000.0)
            let upperIndex = Int(upperFrequency * Float(amplitudes.count) / 20_000.0)

            let subArray = Array(amplitudes[lowerIndex..<upperIndex])
            let averageAmplitude = subArray.reduce(0, { $0 + ($1 ?? 0) }) / Float(subArray.count)

            let barHeight = CGFloat(averageAmplitude) * size.height
            bar.size = CGSize(width: bar.size.width, height: barHeight)

            let resizeAction = SKAction.resize(toWidth: bar.size.width, height: barHeight, duration: 0.05)

            bar.run(resizeAction)
//
//            // Create a sequence of actions to animate the size change and restore the width
//            let sequence = SKAction.sequence([resizeAction, restoreWidthAction])
//
//            // Run the sequence of actions on the bar node
//            bar.run(sequence)
        }
    }

}


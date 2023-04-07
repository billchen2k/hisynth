//
//  File.swift
//
//
//  Created by Bill Chen on 2023/4/7.
//

import Foundation
import SpriteKit
import AVFoundation
import Accelerate

class FilterScene: SKScene {
    var controller: FilterController!
    var tap: FFTTap!
    var mixer: Mixer {
        controller.outputNode
    }

    var maxAmplitude: Float = 0.0
    var minAmplitude: Float = -70.0
    var referenceValueForFFT: Float = 12.0
    var amplitudes: [Float?] = []

    let numberOfBars: Int = 128
    var barNodes: [SKSpriteNode] = []

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        size = view.frame.size
        view.allowsTransparency = true
        self.tap = FFTTap(mixer, callbackQueue: .main) { fftData in
            self.updateAmplitudes(fftData)
        }
        tap.isNormalized = false
        tap.start()

        createBars()
    }

    override func update(_ currentTime: TimeInterval) {
        updateBars()
    }

    /// This function is adapted from AudioKitUI's FFT View.
    //       Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKitUI/
    private func updateAmplitudes(_ fftFloats: [Float]) {
        var fftData = fftFloats
        for index in 0 ..< fftData.count {
            if fftData[index].isNaN { fftData[index] = 0.0 }
        }
        var one = Float(1.0)
        var zero = Float(0.0)
        var decibelNormalizationFactor = Float(1.0 / (maxAmplitude - minAmplitude))
        var decibelNormalizationOffset = Float(-minAmplitude / (maxAmplitude - minAmplitude))

        var decibels = [Float](repeating: 0, count: fftData.count)
        vDSP_vdbcon(fftData, 1, &referenceValueForFFT, &decibels, 1, vDSP_Length(fftData.count), 0)

        vDSP_vsmsa(decibels,
                   1,
                   &decibelNormalizationFactor,
                   &decibelNormalizationOffset,
                   &decibels,
                   1,
                   vDSP_Length(decibels.count))

        vDSP_vclip(decibels, 1, &zero, &one, &decibels, 1, vDSP_Length(decibels.count))

        DispatchQueue.main.async {
            self.amplitudes = decibels
        }
    }

    private func createBars() {
        let barWidth = size.width / CGFloat(numberOfBars) * 0.9
        for index in 0..<numberOfBars {

            let bar = SKSpriteNode(color: .darkGray, size: CGSize(width: barWidth, height: 1))
            bar.position = CGPoint(x: barWidth * CGFloat(index) + barWidth / 2, y: 0)
            bar.anchorPoint = CGPoint(x: 0.5, y: 0)
            addChild(bar)
            barNodes.append(bar)
        }
    }

    private func updateBars() {
        guard amplitudes.count >= numberOfBars else { return }

//        let strideLength = amplitudes.count / numberOfBars
//        for (index, bar) in barNodes.enumerated() {
//            let startIndex = index * strideLength
//            let endIndex = startIndex + strideLength
//            let subArray = Array(amplitudes[startIndex..<endIndex])
//            let averageAmplitude = subArray.reduce(0, { $0 + ($1 ?? 0) }) / Float(subArray.count)
//
//            let barHeight = CGFloat(averageAmplitude) * size.height
//            bar.size = CGSize(width: bar.size.width, height: barHeight)
//        }
        let strideLength = amplitudes.count / numberOfBars
        for (index, bar) in barNodes.enumerated() {
            let startIndex = index * strideLength
            let endIndex = startIndex + strideLength
            let subArray = Array(amplitudes[startIndex..<endIndex])
            let averageAmplitude = subArray.reduce(0, { $0 + ($1 ?? 0) }) / Float(subArray.count)

            let barHeight = CGFloat(amplitudes[index] ?? 0) * size.height
            bar.size = CGSize(width: bar.size.width, height: barHeight)
        }
    }

}


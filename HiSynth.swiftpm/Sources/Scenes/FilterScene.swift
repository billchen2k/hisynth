//
//  FilterScene.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/7.
//

import Foundation
import SpriteKit
import AVFoundation
import AudioKit

class FilterScene: SKScene {
    var controller: FilterController!
    var tap: FFTTap!
    var mixer: Mixer {
        controller.outputNode
    }

    var fftData: [Float]!
    var amplitudes: [Float?] = Array(repeating: 0.0, count: 1024)

    let minLogFrequency = Float(log10(20.0))
    let maxLogFrequency = Float(log10(22_000.0))

    /// EQ Parameters for rendering the curve
    var lowCut: Float {
        controller.filters.highPassFilter.$cutoffFrequency.value
    }
    var lowRes: Float {
        controller.filters.highPassFilter.$resonance.value
    }
    var highCut: Float {
        controller.filters.lowPassFilter.$cutoffFrequency.value
    }
    var highRes: Float {
        controller.filters.lowPassFilter.$resonance.value
    }

    let numberOfBars: Int = 100
    var barNodes: [SKSpriteNode] = []
    var eqNode: SKShapeNode!

    private var taskQueue = DispatchQueue(label: "io.billc.hisynth.fft", qos: .default)

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        size = view.frame.size
        self.tap = FFTTap(mixer, callbackQueue: taskQueue) { fftData in
            // fftData is an array of size 2048
            self.fftData = fftData
        }
        // Update amplitudes (Very CPU comsuming)
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            if let fftData = self.fftData {
                self.updateAmplitudes(fftData)
            }
        }

        tap.isNormalized = false
        tap.start()
        createTicks()
        createBars()
        createEQ()
    }

    override func update(_ currentTime: TimeInterval) {
        updateBars()
        updateEQ()
    }

    private func updateAmplitudes(_ fftData: [Float]) {
        let fftSize = fftData.count
        // Loop by two through all the fft data
        for i in stride(from: 0, to: fftSize - 1, by: 2) {
            // Get the real and imaginary parts of the complex number
            let real = fftData[i]
            let imaginary = fftData[i + 1]

            let normalizedBinMagnitude = 2.0 * sqrt(real * real + imaginary * imaginary) / Float(fftSize)
            let amplitude = (20.0 * log10(normalizedBinMagnitude))

            // Scale the resulting data
            var scaledAmplitude = (amplitude + 250) / 229.8
            scaledAmplitude = scaledAmplitude.clamp(to: 0...1)
            scaledAmplitude = (scaledAmplitude - 0.3) / 0.6

            DispatchQueue.main.async {
                if i / 2 < self.amplitudes.count {
                    self.amplitudes[i / 2] = scaledAmplitude
                }
            }
        }
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

    /// Get the x coordinate for a given frequency
    private func freqX(_ freq: Float) -> CGFloat {
        let logFrequency = log10(freq)
        let x = CGFloat((logFrequency - minLogFrequency) / (maxLogFrequency - minLogFrequency)) * size.width
        return x
    }

    private func createTicks() {
        let freqs = [50, 100, 200, 500, 1_000, 2_000, 5_000, 10_000, 20_000]
        let labels = ["50", "100", "200", "500", "1k", "2k", "5k", "10k", "20k"]
        for (freq, label) in zip(freqs, labels) {
            let tick = SKSpriteNode(color: .darkGray, size: CGSize(width: 1, height: size.height))
            tick.position = CGPoint(x: freqX(Float(freq)), y: size.height / 2)
            let label = SKLabelNode(text: label)
            label.fontName = "Menlo"
            label.fontColor = .darkGray
            label.fontSize = 10
            label.position = CGPoint(x: tick.position.x - 10, y: size.height - 15)
            addChild(tick)
            addChild(label)
        }
    }

    private func getEQPath() -> CGPath {
        // slopeWidth
        let slope: CGFloat = 20.0
        // Half height (Center of y)
        let cy: CGFloat = size.height / 2
        // Center width of high pass & low pass
        let cx = (freqX(highCut) + freqX(lowCut)) / 2

        let resY: (AUValue) -> CGFloat = { CGFloat($0) * 2.0 }

        let path = CGMutablePath()
        if freqX(highCut) - freqX(lowCut) < slope {
            // Draw a straight line at the bottom of the scene
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: 0))
        } else {
            path.move(to: CGPoint(freqX(lowCut) - slope * 2, 0.0))
            if lowRes >= 0 {
                let lowControl = CGPoint(freqX(lowCut), cy)
                path.addQuadCurve(to: CGPoint(freqX(lowCut), cy + resY(lowRes)), control: lowControl)
                path.addQuadCurve(to: CGPoint(cx, cy), control: lowControl)
            } else {
                path.addCurve(to: CGPoint(cx, cy),
                              control1: CGPoint(freqX(lowCut), cy + 1.5 * resY(lowRes)),
                              control2: CGPoint(freqX(lowCut) + slope, cy))
            }
            if highRes >= 0 {
                let highControl = CGPoint(freqX(highCut), cy)
                path.addQuadCurve(to: CGPoint(freqX(highCut), cy + resY(highRes)), control: highControl)
                path.addQuadCurve(to: CGPoint(freqX(highCut) + slope * 2, 0.0), control: highControl)
            } else {
                path.addCurve(to: CGPoint(freqX(highCut) + slope * 2, 0.0),
                              control1: CGPoint(freqX(highCut) - slope, cy),
                              control2: CGPoint(freqX(highCut), cy + 1.5 * resY(highRes)))
            }
        }
        return path
    }

    private func createEQ() {
        // lineWidth
        let w: CGFloat = 2.0

        eqNode = SKShapeNode(path: getEQPath())
        eqNode.strokeColor = Theme.colorHighlight.uiColor
        eqNode.lineWidth = w
        eqNode.fillShader = SKShader(fileNamed: "VerticalGradient.fsh")
        addChild(eqNode)
    }

    private func updateBars() {
        guard amplitudes.count >= numberOfBars else { return }
        let logFrequencyStep = (maxLogFrequency - minLogFrequency) / Float(numberOfBars)

        for (index, bar) in barNodes.enumerated() {
            let lowerLogFrequency = minLogFrequency + Float(index) * logFrequencyStep
            let upperLogFrequency = lowerLogFrequency + logFrequencyStep

            let lowerFrequency = pow(10, lowerLogFrequency)
            let upperFrequency = pow(10, upperLogFrequency)

            let lowerIndex = Int(lowerFrequency * Float(amplitudes.count) / 22_000.0)
            let upperIndex = Int(upperFrequency * Float(amplitudes.count) / 22_000.0)

            let subArray = Array(amplitudes[lowerIndex..<upperIndex])
            let averageAmplitude = subArray.reduce(0, { $0 + ($1 ?? 0) }) / Float(subArray.count)

            let barHeight = CGFloat(averageAmplitude) * size.height
            bar.size = CGSize(width: bar.size.width, height: barHeight)
            //            let resizeAction = SKAction.resize(toWidth: bar.size.width, height: barHeight, duration: 0.05)
            //            bar.run(resizeAction)
        }
    }

    private func updateEQ() {
        eqNode.path = getEQPath()
    }
}


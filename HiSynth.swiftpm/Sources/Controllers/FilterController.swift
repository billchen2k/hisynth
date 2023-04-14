//
//  FilterController.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/6.
//

import Foundation
import AVFoundation


class FilterController: ObservableObject, HasModulatorConnector {

    @ModulatableNodeParam var lowPassCutoff: AUValue = 0.0 {
        didSet {
            filters.lowPassFilter.cutoffFrequency = $lowPassCutoff.baseValue
        }
    }

    @Published var lowPassRes: AUValue = 0 {
        didSet {
            filters.lowPassFilter.resonance = lowPassRes
        }
    }

    @ModulatableNodeParam var highPassCutoff: AUValue = 2000 {
        didSet {
            filters.highPassFilter.cutoffFrequency = $highPassCutoff.baseValue
        }
    }

    @Published var highPassRes: AUValue = 0 {
        didSet {
            filters.highPassFilter.resonance = highPassRes
        }
    }

    var inputNode: Node
    var outputNode: Mixer

    var filters: Filters

    var highPassModulator: Modulator?
    var lowPassModulator: Modulator?
    var amplitudeModulator: Modulator?

    init(_ inputNode: Node) {
        self.inputNode = inputNode
        let filters = Filters(inputNode: inputNode)
        self.filters = filters
        self.outputNode = filters.outputNode
        self.outputNode.volume = 0.5
    }

    public func setup() {
        lowPassCutoff = 22000
        lowPassRes = 0
        highPassCutoff = 0
        highPassRes = 0
        $lowPassCutoff.objectWillChange = objectWillChange
        $lowPassCutoff.nodeParam = filters.lowPassFilter.$cutoffFrequency
        $highPassCutoff.objectWillChange = objectWillChange
        $highPassCutoff.nodeParam = filters.highPassFilter.$cutoffFrequency
    }

    func connectModulator(lfos: [LowFreqOscillator]) {
        let amplitude = ModulatableCustomParam(0.5) { v in
            self.outputNode.volume = (0.5 + v).clamped(to: 0.0...1.0)
        }
        let amplitudeMod = Modulator(target: amplitude, range: -0.5...0.5, lfos: lfos)
        let lowMod = Modulator(target: $lowPassCutoff,
                               range: -1.0...1.0,
                               log: true,
                               lfos: lfos)
        let highMod = Modulator(target: $highPassCutoff,
                                range: -1.0...1.0,
                                log: true,
                                lfos: lfos)
        lowMod.start()
        highMod.start()
        amplitudeMod.start()
        lowPassModulator = lowMod
        highPassModulator = highMod
        amplitudeModulator = amplitudeMod
    }
}

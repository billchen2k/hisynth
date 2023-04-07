//
//  FilterController.swift
//  
//
//  Created by Bill Chen on 2023/4/6.
//

import Foundation
import AVFoundation


class FilterController: ObservableObject {

    @Published var lowPassCutoff: AUValue = 0 {
        didSet {
            filters.lowPassFilter.cutoffFrequency = lowPassCutoff
        }
    }

    @Published var lowPassRes: AUValue = 0 {
        didSet {
            filters.lowPassFilter.resonance = lowPassRes
        }
    }

    @Published var highPassCutoff: AUValue = 2000 {
        didSet {
            filters.highPassFilter.cutoffFrequency = highPassCutoff
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

    init(_ inputNode: Node) {
        self.inputNode = inputNode
        let filters = Filters(inputNode: inputNode)
        self.filters = filters
        self.outputNode = filters.outputNode
    }

    public func loadDefaults() {
        lowPassCutoff = 20000
        lowPassRes = 0
        highPassCutoff = 0
        highPassRes = 0
    }
}

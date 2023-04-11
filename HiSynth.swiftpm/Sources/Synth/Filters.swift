//
//  Filters.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/7.
//

import Foundation

class Filters {
    var inputNode: Node
    var outputNode: Mixer = Mixer()

    /// Using Apple Audio Unit's filters.
    var lowPassFilter: LowPassFilter
    var highPassFilter: HighPassFilter

    init(inputNode: Node) {
        self.inputNode = inputNode
        let lp = LowPassFilter(inputNode)
        let hp = HighPassFilter(lp)
        outputNode.addInput(hp)
        self.lowPassFilter = lp
        self.highPassFilter = hp
    }
}

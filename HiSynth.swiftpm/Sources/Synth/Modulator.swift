//
//  Modulator.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/10.
//

import Foundation
import AVFoundation
import Combine

class Modulator {
    /// Allow multiple LFOs
    var lfos: [LowFreqOscillator]

    /// Speficy which lfo to modulate
    var ifModulate: [Bool]

    /// The modulatable target, can be updated after initialization.
    var target: Modulatable

    var range: ClosedRange<AUValue>

    /// If the modulator performs with logarithm. If set to true, the given range will be treated as log10() values.
    ///     Used for modulating cut off frequencies for filters.
    var log: Bool = false

    var isStarted: Bool = false


    /// Modulation offsets. Will be summed before applying to the modulate target.
    private var modOffsets: [Float] = []
    private var lfoHandlers: [LFOHandler] = []
    private var modLock = NSLock()

    init(target: Modulatable,
         range: ClosedRange<Float> = 0...1,
         log: Bool = false,
         lfos: [LowFreqOscillator] = []) {
        self.target = target
        self.lfos = lfos
        self.ifModulate = Array(repeating: false, count: lfos.count)
        self.range = range
        self.log = log
        self.modOffsets = Array(repeating: 0.0, count: lfos.count)
        setupHandlers()
    }

    private func setupHandlers() {
        /// Handler is a value rangingfrom -1 ~ 1
        for (i, lfo) in lfos.enumerated() {
            let handler: LFOHandler = { [self] v in
                if !self.isStarted {
                    return
                }
                var modOffset: Float
                modOffset = self.range.lowerBound + (v + 1.0) / 2.0 * (self.range.upperBound - self.range.lowerBound)
                if log {
                    modOffset = pow(10, log10(target.baseValue) + modOffset) - target.baseValue
                }
                modLock.lock()
                modOffsets[i] = modOffset
                modLock.unlock()
                var offset: Float = 0
                for i in 0..<self.lfos.count {
                    if ifModulate[i] {
                        offset += modOffsets[i]
                    }
                }
                target.modulate(offset)
            }
            lfo.callbacks.append(handler)
            lfoHandlers.append(handler)
        }
    }

    public func start() {
        isStarted = true
        for lfo in lfos {
            lfo.start()
        }
    }

    public func stop() {
        isStarted = false
    }
}

@propertyWrapper
class ModulatableNodeParam: Modulatable {
    
    var baseValue: AUValue

    var modulatedValue: AUValue

    /// The AudioKit's node parameter for modulation.
    var nodeParam: NodeParameter?

    /// Use this to notify the UI to update (Like @Published)
    weak var objectWillChange: ObservableObjectPublisher?

    var wrappedValue: AUValue {
        get { baseValue }
        set {
            baseValue = newValue
            modulatedValue = newValue
            objectWillChange?.send()
        }
    }

    /// Accessing the parameter object using $
    var projectedValue: ModulatableNodeParam {
        get { self }
    }

    init(wrappedValue: AUValue) {
        self.baseValue = wrappedValue
        self.modulatedValue = wrappedValue
    }

    func modulate(_ value: Float) {
        modulatedValue = baseValue + value
        if let nodeParam = nodeParam {
            nodeParam.value = modulatedValue
        }
    }
}

struct ModulatableCustomParam: Modulatable {
    var baseValue: AUValue

    var modulatedValue: AUValue {
        print("Warning: trying to access modulated value for ModulatableCustomParam. Returning base value instead.")
        return baseValue
    }

    var modulateHandler: LFOHandler?

    func modulate(_ value: Float) {
        if let modulateHandler = modulateHandler {
            modulateHandler(value)
        }
    }

    init(_ value: AUValue, handler: LFOHandler? = nil) {
        self.baseValue = value
        self.modulateHandler = handler
    }
}

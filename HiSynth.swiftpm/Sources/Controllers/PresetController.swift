//
//  PresetController.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/13.
//

import Foundation
import SwiftUI

class PresetController: ObservableObject {

    /// If it is nil, then no preset is loaded
    @Published var currentPreset: Preset? {
        didSet {
            if let preset = currentPreset {
                loadPreset(preset)
            }
        }
    }

    @Published var presets: [Preset] = []

    weak private var core: HiSynthCore?
    private var oscC: OscillatorController
    private var envC: EnvelopeController
    private var filterC: FilterController
    private var lfoC: LFOController
    private var afxC: AFXController

    init(core: HiSynthCore) {
        self.core = core
        self.oscC = core.oscillatorController
        self.envC = core.envelopeController
        self.filterC = core.filterController
        self.lfoC = core.lfoController
        self.afxC = core.afxController
    }

    func loadPreset(_ preset: Preset) {
        preset.oscParams.apply(controller: oscC)
        preset.afxParams.apply(controller: afxC)
        preset.envParams.apply(controller: envC)
        preset.filterParams.apply(controller: filterC)
        preset.lfoParams.apply(controller: lfoC)
    }

    func parsePreset(_ presetStr: String,
                     onCompletion: @escaping ((String) -> Void),
                     onError: @escaping ((String) -> Void)) {
        if presetStr.isEmpty {
            onError("Empty preset.")
            return
        }
        var preset = Preset(name: "")
        do {
            try preset.parse(presetStr)
            self.loadPreset(preset)
            self.presets.append(preset)
            onCompletion(preset.name)
        } catch let error as PresetError {
            switch error {
            case .corrupted:
                onError("Unable to read valid data from preset string.")
            case .outOfIndex:
                onError("Data is corrupted")
            case .custom(let msg):
                onError(msg)
            }
        } catch {
            onError("Unknown error.")
        }
    }

    func dumpCurrent(name: String = "My Sound") -> String {
        var preset = Preset(name: name)
        preset.afxParams.extract(controller: afxC)
        preset.envParams.extract(controller: envC)
        preset.filterParams.extract(controller: filterC)
        preset.lfoParams.extract(controller: lfoC)
        preset.oscParams.extract(controller: oscC)
        return preset.dump()
    }

    private func loadDefaults() {
        presets.append(Preset(name: "Init"))
        presets.append(Preset(name: "Test 0"))
        presets.append(Preset(name: "Test 1"))
        presets[1].oscParams.level2 = 0.0
        presets[2].lfoParams.depths = [1.0, 0.5, 0.0]
    }

    func setup() {
        loadDefaults()
    }
}

enum PresetError: Error {
    case corrupted
    case outOfIndex
    case custom(String)
}

struct Preset: Equatable {

    var name: String

    var oscParams = OscillatorParameters()
    var envParams = EnvelopeParameters()
    var filterParams = FilterParameters()
    var lfoParams = LFOParameters()
    var afxParams = AFXParameters()

    func dump() -> String {
        var presetStr: [String] = []
        let params: [any ParameterManagable] = [oscParams, envParams, filterParams, lfoParams, afxParams]
        params.forEach {
            presetStr.append($0.dump())
        }
        return "\(name.toBase64()):" + presetStr.joined(separator: "|")
    }

    mutating func parse(_ presetStr: String) throws {
        self.name = presetStr.components(separatedBy: ":")[0].fromBase64() ?? "Untitled"
        let paramPayload = presetStr.components(separatedBy: ":")[1]
        let paramStrs = paramPayload.components(separatedBy: "|")
        try oscParams.parse(paramStrs[0])
        try envParams.parse(paramStrs[1])
        try filterParams.parse(paramStrs[2])
        try lfoParams.parse(paramStrs[3])
        try afxParams.parse(paramStrs[4])
    }

    // Equatable
    static func ==(lhs: Preset, rhs: Preset) -> Bool {
        return lhs.name == rhs.name
    }
}


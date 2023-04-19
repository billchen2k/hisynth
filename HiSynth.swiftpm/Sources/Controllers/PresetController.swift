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

    static let factoryPresetsStrings: [String] = [
        /// HiSynth Key:
        "SGlTeW50aCBLZXk=:Y2JgsBIxYmBgOAUA|Y2BgsGCwYbAAAA==|Y8hmAAMA|Y2ZgYGBep84Aon47MAAhMwMYMMMwI4QGAA==|Y7Bh4tJndAhisABiBl8Q4QkkAA==",
        /// Sweetheart Key
        "U3dlZXRoZWFydCBLZXk=:Y2S0NeMyZ2Bg8AIA|Y2AQMWKweWIDAA==|syo4f4TBU94ZAA==|Y2ZgYGBO02MAUfIuDA4MDswMYACimBmhNBADAA==|Y7Bh5NJnZPBlMGnwZWDwdQhiYPAEEgA=",
        /// Mario Key
        "TWFyaW8gS2V5:Y2RYYhFkxcDA4AUA|Y2BgsGCw0TIDAA==|25HJAAYA|Y2ZgYGBep80AoljdGRwYHJgZwICZEYgZEBgA|Y3BgXKfP6BDEYAHEDA4NwYwMnkAWAA==",
        /// Subway Lead
        "U3Vid2F5IExlYWQ=:Y2KstrK1YGBg8AIA|Y2BgsGCwYTEBAA==|08h6dpABCAA=|Y2ZlZGA+bHrWgEuf+ZL7N2dGD2YGBgYLBgYgxcjMAJRkBLMZAA==|Y3BgLDRkdAhisABiBl8Q4QkkAA==",
        /// Helicopter Lead
        "SGVsaWNvcHRlciBMZWFk:Y2JaYhVkwcDA4AIA|Y2BgsGCwSdMCAA==|218QY8wABAA=|Y2ZkYGBOM6vWKTRkvuW1x9vDk5kBDJgZGBmYQZIMEAwA|Y7BhWmLC6BDEYAHEDL4gwhNIAAA=",
        /// Rocket Lead
        "Um9ja2V0IExlYWQ=:Y2S6bilvyMDAcAoA|Y2BgsGCwSdMCAA==|iy9lYGDwvG4NAA==|Y2ZgYGCu1mEAUQzuDA4MDswMYMDMCBJBYAA=|Y3BiKjRldAhisADiNl+HIEaH8wz+jAA=",
        /// Rewind Pad
        "UmV3aW5kIFBhZA==:Y2AKstI0YQACAA==|Y2BgsGCwUXQAAA==|u5F27iRXBAMDAA==|Y2ZiYGAuNF2nDaQ+Omq6MjgwM4ABMwMjAzMjAwQD+QA=|Y3BgSjNjTAhgsGnwYWDwdQhiYPAEEgA=",
        /// Dream Pad
        "RHJlYW0gUGFk:Y2BmsOm3YGBg8AIA|W2fKYMFgY+YAAA==|i8t5cowBCAA=|Y2ZgYGBO02MAUUtcuBwYHJgZwABEMTNCaSAGAA==|Y3BgZLBgdAhisFAIYDS2Z3BlULvA4MkAAA==",
        /// Fifth Pad
        "RmlmdGggUGFk:Y2IJsjK2ZGBgOA4A|izFmsJC3MrMDAA==|W5bKAAYA|Y2ZgYGCWN5RXBFJBzgwODA7MDGDAzMDIwMwIoiEYAA==|Y3BiCrJiTAhgsGnwYWTwdQhiYPAEEgA=",
        /// Spring Pluck
        "U3ByaW5nIFBsdWNr:Y2BisFliwsDA0AAA|Y2BI01qnnaYFAA==|CykVMZrmtcQGAA==|Y2ZgYGBmAANmeRcGBwYHGA+EGaE0EAMA|Y3Bi4tJnZPBlMGnwYJjl1ODLwODpEMQAAA==",
        /// Summer Pluck
        "U3VtbWVyIFBsdWNr:Y2RhsFliwsDA4AUA|Y2DoN2JgSNMCAA==|+56213ma1xIbAA==|Y2ZlYGCWt2QAAuYuRwYHBgdmBjBghmFGCA0A|Y3BgOmvAyOA7y7TBk3GWU4MvA4OnQxADAA==",
        /// Siren FX
        "U2lyZW4gRlg=:Y2Y0tu63YGBg8AIA|Y2BgsGCwOesMAA==|W53HAAYA|Y2ZiYGDeYcYABMzf7BkcGByYGcCAmRGIGRAYAA==|Y3Bg9DBldAhisABiBl8Q4QkkAA==",
        /// Telephone FX
        "VGVsZXBob25lIEZY:Y2SQt15iwcDA4AQA|Y2BgsGCw0bQAAA==|W5/JAAYA|Y2ZkYGB+aMYABMzf3BkcGByYGSzAPJAEAwIDAA==|Y3BgZLBgcAhisABiBl8Q4QkkAA==",
        /// Underwater FX
        "VW5kZXJ3YXRlciBGWA==:Y2YQseo3Y2BgcAMA|KzRnsGCwSXcCAA==|u5uS5dPm6+MBAA==|Y2ZgZWROMzK2nmXKPN+t2tPWlZkBDJgZGBlBTGZGRhBmBAA=|Y3BgYrBgbPA5a+AQxMjg6xDEsOucQxgjAA==",
        /// Init
        "SW5pdA==:Y2BgsAJCIAAA|Y2BgsGCwSdMCAA==|iy9lAAMA|Y2ZgYGBmAANmBgcQhPNQMQA=|Y3BgZLBgcAhisABiBl8Q4QkkAA=="
    ]

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
            self.currentPreset = preset
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
        presets.removeAll()
        for presetStr in PresetController.factoryPresetsStrings {
            var preset = Preset(name: "")
            do {
                try preset.parse(presetStr)
                presets.append(preset)
            } catch {
                print("Fail to parse factory preset: \(presetStr)")
                continue
            }
        }
        self.currentPreset = presets[0]
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
        presetStr.append(oscParams.dump())
        presetStr.append(envParams.dump())
        presetStr.append(filterParams.dump())
        presetStr.append(lfoParams.dump())
        presetStr.append(afxParams.dump())
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


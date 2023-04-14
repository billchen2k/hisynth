//
//  Parameters.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/14.
//

import Foundation

struct OscillatorParameters: ParameterManagable {
    typealias Controller = OscillatorController

    var waveform1: HSWaveform?
    var waveform2: HSWaveform?
    var level1: Float?
    var level2: Float?
    var pitch1: Float?
    var pitch2: Float?

    func apply(controller: Controller) {
        assign(waveform1, to: &controller.waveform1)
        assign(waveform2, to: &controller.waveform2)
        assign(level1, to: &controller.level1)
        assign(level2, to: &controller.level2)
        assign(pitch1, to: &controller.pitch1)
        assign(pitch2, to: &controller.pitch2)
    }

    mutating func inject(from values: [String: Any]) {
        waveform1 = values["waveform1"] as? HSWaveform
        waveform2 = values["waveform2"] as? HSWaveform
        level1 = values["level1"] as? Float
        level2 = values["level2"] as? Float
        pitch1 = values["pitch1"] as? Float
        pitch2 = values["pitch2"] as? Float
    }


    mutating func extract(controller: Controller) {
        waveform1 = controller.waveform1
        waveform2 = controller.waveform2
        level1 = controller.level1
        level2 = controller.level2
        pitch1 = controller.pitch1
        pitch2 = controller.pitch2
    }
}

struct EnvelopeParameters: ParameterManagable {
    typealias Controller = EnvelopeController

    var attackDuration: Float?
    var decayDuraction: Float?
    var sustainLevel: Float?
    var releaseDuration: Float?

    func apply(controller: EnvelopeController) {
        assign(attackDuration, to: &controller.attackDuration)
        assign(decayDuraction, to: &controller.decayDuration)
        assign(sustainLevel, to: &controller.sustainLevel)
        assign(releaseDuration, to: &controller.releaseDuration)
    }

    mutating func inject(from values: [String: Any]) {
        attackDuration = values["attackDuration"] as? Float
        decayDuraction = values["decayDuraction"] as? Float
        sustainLevel = values["sustainLevel"] as? Float
        releaseDuration = values["releaseDuration"] as? Float
    }

    mutating func extract(controller: Controller) {
        attackDuration = controller.attackDuration
        decayDuraction = controller.decayDuration
        sustainLevel = controller.sustainLevel
        releaseDuration = controller.releaseDuration
    }
}

struct FilterParameters: ParameterManagable {
    typealias Controller = FilterController

    var lowPassCutoff: Float?
    var lowPassRes: Float?
    var highPassCutoff: Float?
    var highPassRes: Float?

    func apply(controller: Controller) {
        assign(lowPassCutoff, to: &controller.lowPassCutoff)
        assign(lowPassRes, to: &controller.lowPassRes)
        assign(highPassCutoff, to: &controller.highPassCutoff)
        assign(highPassRes, to: &controller.highPassRes)
    }

    mutating func inject(from values: [String: Any]) {
        lowPassCutoff = values["lowPassCutoff"] as? Float
        lowPassRes = values["lowPassRes"] as? Float
        highPassCutoff = values["highPassCutoff"] as? Float
        highPassRes = values["highPassRes"] as? Float
    }

    mutating func extract(controller: Controller) {
        lowPassCutoff = controller.lowPassCutoff
        lowPassRes = controller.lowPassRes
        highPassCutoff = controller.highPassCutoff
        highPassRes = controller.highPassRes
    }
}

struct LFOParameters: ParameterManagable {
    typealias Controller = LFOController

    var waveforms: [HSWaveform]?
    var depths: [Float]?
    var speeds: [Float]?
    var phases: [Float]?
    var modPitch: [Bool]?
    var modAmplitude: [Bool]?
    var modFilterLow: [Bool]?
    var modFilterHigh: [Bool]?

    func apply(controller: Controller) {
        assign(waveforms, to: &controller.waveforms)
        assign(depths, to: &controller.depths)
        assign(speeds, to: &controller.speeds)
        assign(phases, to: &controller.phases)
        assign(modPitch, to: &controller.modPitch)
        assign(modAmplitude, to: &controller.modAmplitude)
        assign(modFilterLow, to: &controller.modFilterLow)
        assign(modFilterHigh, to: &controller.modFilterHigh)
    }

    mutating func inject(from values: [String: Any]) {
        waveforms = values["waveforms"] as? [HSWaveform]
        depths = values["depths"] as? [Float]
        speeds = values["speeds"] as? [Float]
        phases = values["phases"] as? [Float]
        modPitch = values["modPitch"] as? [Bool]
        modAmplitude = values["modAmplitude"] as? [Bool]
        modFilterLow = values["modFilterLow"] as? [Bool]
        modFilterHigh = values["modFilterHigh"] as? [Bool]
    }

    mutating func extract(controller: Controller) {
        waveforms = controller.waveforms
        depths = controller.depths
        speeds = controller.speeds
        phases = controller.phases
        modPitch = controller.modPitch
        modAmplitude = controller.modAmplitude
        modFilterLow = controller.modFilterLow
        modFilterHigh = controller.modFilterHigh
    }
}


struct AFXParameters: ParameterManagable {
    typealias Controller = AFXController

    var reverbSize: Float?
    var reverbType: HSReverbType?
    var reverbMix: Float?
    var reverbOn: Bool?

    var delayFeedback: Float?
    var delayTime: Float?
    var delayMix: Float?
    var delayOn: Bool?

    var decimatorRate: Float?
    var decimatorMix: Float?
    var decimatorOn: Bool?

    var driveGain: Float?
    var driveMix: Float?
    var driveOn: Bool?

    func apply(controller: Controller) {
        assign(reverbSize, to: &controller.reverbSize)
        assign(reverbType, to: &controller.reverbType)
        assign(reverbMix, to: &controller.reverbMix)
        assign(reverbOn, to: &controller.reverbOn)
        assign(delayFeedback, to: &controller.delayFeedback)
        assign(delayTime, to: &controller.delayTime)
        assign(delayMix, to: &controller.delayMix)
        assign(delayOn, to: &controller.delayOn)
        assign(decimatorRate, to: &controller.decimatorRate)
        assign(decimatorMix, to: &controller.decimatorMix)
        assign(decimatorOn, to: &controller.decimatorOn)
        assign(driveGain, to: &controller.driveGain)
        assign(driveMix, to: &controller.driveMix)
        assign(driveOn, to: &controller.driveOn)
    }

    mutating func inject(from values: [String: Any]) {
        reverbSize = values["reverbSize"] as? Float
        reverbType = values["reverbType"] as? HSReverbType
        reverbMix = values["reverbMix"] as? Float
        reverbOn = values["reverbOn"] as? Bool
        delayFeedback = values["delayFeedback"] as? Float
        delayTime = values["delayTime"] as? Float
        delayMix = values["delayMix"] as? Float
        delayOn = values["delayOn"] as? Bool
        decimatorRate = values["decimatorRate"] as? Float
        decimatorMix = values["decimatorMix"] as? Float
        decimatorOn = values["decimatorOn"] as? Bool
        driveGain = values["driveGain"] as? Float
        driveMix = values["driveMix"] as? Float
        driveOn = values["driveOn"] as? Bool
    }

    mutating func extract(controller: Controller) {
        reverbSize = controller.reverbSize
        reverbType = controller.reverbType
        reverbMix = controller.reverbMix
        reverbOn = controller.reverbOn
        delayFeedback = controller.delayFeedback
        delayTime = controller.delayTime
        delayMix = controller.delayMix
        delayOn = controller.delayOn
        decimatorRate = controller.decimatorRate
        decimatorMix = controller.decimatorMix
        decimatorOn = controller.decimatorOn
        driveGain = controller.driveGain
        driveMix = controller.driveMix
        driveOn = controller.driveOn
    }
}


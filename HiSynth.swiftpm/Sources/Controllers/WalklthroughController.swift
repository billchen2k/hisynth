//
//  WalklthroughController.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/17.
//

import Foundation
import SwiftUI

enum HSComponent: Int8 {

    case welcome = 0
    case osc = 1
    case env = 2
    case filter = 3
    case lfo = 4
    case afx = 5
    case preset = 6
    case rack = 7

    var title: String {
        switch self {
        case .welcome:
            return "Welcome"
        case .osc:
            return "Oscillator"
        case .env:
            return "Envelope Generator"
        case .filter:
            return "Filters"
        case .lfo:
            return "Low Frequency Oscillators (LFO)"
        case .afx:
            return "Audio Effects"
        case .preset:
            return "Presets"
        case .rack:
            return "Rack"
        }
    }

    var description: String {
        switch self {
        case .welcome:
            return "Welcome to HiSynth! HiSynth is a synthesizer app built with SwiftUI. It is currently in beta and is not yet available on the App Store. This walkthrough will guide you through the basic features of HiSynth."
        case .osc:
            return "The oscillator is the heart of a synthesizer. It generates a waveform that is then processed by the other components of the synthesizer. HiSynth has 3 oscillators, each with its own waveform, pitch, and volume. The waveform can be either a sine wave, square wave, sawtooth wave, or triangle wave. The pitch can be adjusted by either dragging the pitch wheel or by using the pitch bend wheel. The volume can be adjusted by dragging the volume slider. The volume slider can be dragged up to 100% to increase the volume of the oscillator, or down to -100% to decrease the volume of the oscillator."
        case .env:
            return "The envelope generator is used to control the volume of the oscillator over time. The envelope generator has 4 stages: attack, decay, sustain, and release. The attack stage is the time it takes for the oscillator to reach its maximum volume. The decay stage is the time it takes for the oscillator to reach its sustain volume. The sustain stage is the volume the oscillator will stay at until the note is released. The release stage is the time it takes for the oscillator to reach 0 volume after the note is released. The envelope generator can be adjusted by dragging the sliders in the envelope generator view."
        case .filter:
            return "The filter is used to filter out certain frequencies of the oscillator. HiSynth has 3 filters, each with its own type, cutoff frequency, and resonance. The filter type can be either low pass, high pass, band pass, or notch. The cutoff frequency can be adjusted by dragging the cutoff slider. The resonance can be adjusted by dragging the resonance slider. The resonance slider can be dragged up to 100% to increase the resonance of the filter, or down to -100% to decrease the resonance of the filter."
        case .lfo:
            return "The low frequency oscillator (LFO) is used to modulate the pitch and volume of the oscillator. HiSynth has 3 LFOs, each with its own waveform, pitch, and volume"
        case .afx:
            return "The audio effects are used to process the sound of the oscillator. HiSynth has 3 audio effects, each with its own type, cutoff frequency, and resonance. The audio effect type can be either low pass, high pass, band pass, or notch. The cutoff frequency can be adjusted by dragging the cutoff slider. The resonance can be adjusted by dragging the resonance slider. The resonance slider can be dragged up to 100% to increase the resonance of the audio effect, or down to -100% to decrease the resonance of the audio effect."
        case .preset:
            return "The presets are used to save the settings of the synthesizer. HiSynth has 3 presets, each with its own name, oscillator settings, envelope generator settings, filter settings, LFO settings, and audio effect settings. The preset can be saved by clicking the save button. The preset can be loaded by clicking the load button."
        case .rack:
            return "The rack is used to save the settings of the synthesizer. HiSynth has 3 racks, each with its own name, oscillator settings, envelope generator settings, filter settings, LFO settings, and audio effect settings. The rack can be saved by clicking the save button. The rack can be loaded by clicking the load button."
        }
    }

    var extras: AnyView? {
        switch self {
        default:
            return AnyView(EmptyView())
        }
    }
}


class WalkthroughController: ObservableObject {

    @Published var presentWelcome = true
    @Published var presentOscHelp = false
    @Published var presentEnvHelp = false
    @Published var presentFilterHelp = false
    @Published var presentLFOHelp = false
    @Published var presentAFXHelp = false
    @Published var presentPresetHelp = false
    @Published var presentRackHelp = false

    @Published var scrollTarget: Int8 = HSComponent.osc.rawValue

    var walkthroughChain: [HSComponent] = [.welcome, .osc, .env, .filter, .lfo, .afx, .preset, .rack]
    var presentBindings: [HSComponent: Binding<Bool>] = [:]

    init() {
        self.presentBindings = [
            .welcome: Binding(get: { self.presentWelcome }, set: { self.presentWelcome = $0 }),
            .osc: Binding(get: { self.presentOscHelp }, set: { self.presentOscHelp = $0 }),
            .env: Binding(get: { self.presentEnvHelp }, set: { self.presentEnvHelp = $0 }),
            .filter: Binding(get: { self.presentFilterHelp }, set: { self.presentFilterHelp = $0 }),
            .lfo: Binding(get: { self.presentLFOHelp }, set: { self.presentLFOHelp = $0 }),
            .afx: Binding(get: { self.presentAFXHelp }, set: { self.presentAFXHelp = $0 }),
            .preset: Binding(get: { self.presentPresetHelp }, set: { self.presentPresetHelp = $0 }),
            .rack: Binding(get: { self.presentRackHelp }, set: { self.presentRackHelp = $0 }),
        ]
    }

    private func nextComponent(_ component: HSComponent) -> HSComponent? {
        if let index = walkthroughChain.firstIndex(of: component) {
            if index < walkthroughChain.count - 1 {
                return walkthroughChain[index + 1]
            }
        }
        return nil
    }

    public func walkthrough(for component: HSComponent) -> AnyView {
        let nextComponent: HSComponent? = nextComponent(component)
        switch component {
        case .welcome:
            return AnyView(EmptyView())
        default:
            return AnyView(WalkthroughContainer(
                isPresented:  presentBindings[component]!,
                title: component.title,
                content: component.description,
                extras: component.extras,
                component: component,
                nextComponent: nextComponent))
        }
    }

    public func dismiss(for component: HSComponent?) {
        if let component = component, let nextComponent = nextComponent(component) {
            presentBindings[component]!.wrappedValue = false
            if [.osc, .env, .filter, .lfo, .afx, .preset].contains(where: { $0 == component}) {
                scrollTarget = nextComponent.rawValue
            }
        }
    }

    public func activate(for component: HSComponent?) {
        if let component = component {
            presentBindings[component]!.wrappedValue = true
        }
    }
}


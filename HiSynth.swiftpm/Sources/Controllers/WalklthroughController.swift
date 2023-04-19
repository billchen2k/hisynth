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
            return "From the timeless funk music of Michal Jackson, James Brown, Earth Wind and Fire to the catchy pop songs of Taylor Swift, Harry Styles and SZA, synthesizers are everywhere. HiSynth is a simple yet powerful analog synthesizer built with entirely with Swift that allows you to explore the fundamental elements of a synthesizer. With HiSynth, you can create unique sounds and delve into the world of waveforms.\n\nWould you like to begin the tutorial first to look through the components of HiSynth?"
        case .osc:
            return "Oscillator is the heart of the synthesizer, serving as the sound source for each voice. It generates a periodic waveform at a specific frequency. Different waveform produces different sounds and the frequency of it is decided by which key you pressed on the keyboard, with higher pitches corresponding to higher frequencies.\n\nIn HiSynth, there are two oscillators that can be layered, with each one can be set to one of the five waveforms: **Sine** Wave, **Saw** wave, **Square** Wave, **Triangle** Wave, and **Pulse** Wave. You can adjust the level (volume) and pitch offset (in semitones) for each oscillator to create different sounds."
        case .env:
            return "TEnvelope Generator creates an *envelope* that controls the volume of each note over time. This envelope consists of four stages: **Attack**, **Decay**, **Sustain** and **Release**. The volume of the note gradually increase from zero to its maximum level in the Attack stage. The Decay stage follows, during which the volume decreases to the sustain level, which is the volume that the note will maintain for the duration that the key is pressed. Finally, the Release stage gradually decreases the volume from the sustain level to zero once the key is released.\n\nBy adjusting the envelop generator’s parameters, you can create sound with different characteristics, such as percussive lead, or pluck sounds and smooth pad sounds.\n\nHere is a picture to help you understand each stage:"
        case .filter:
            return "Filters are used to shape the sound of the synthesizer by modifying its frequency content. They work by selectively amplifying or attenuating different frequencies of the sound, which can drastically change its character.\n\nIn HiSynth, there are two filters: **Low Pass Filter** and **High Pass Filter**. The low pass filter only allows frequencies below a certain cutoff frequencies to pass through, resulting in a mellow, darker sound. While the high pass filter allows frequencies above a certain cutoff frequencies to pass through, making the sound brighter, more transparent. The resonance parameter for the filters can adjust the frequencies that are near the cutoff frequency. A positive resonance can emphasize it, giving you the “wah” sound effect. A negative value will further smooth the curve, making the sound more gentle."
        case .lfo:
            return "LFO is powerful tool that can add movement and variation to your sound. It works by generating a waveform that oscillates at a frequency lower than the audible range (0.2 Hz - 20Hz), and using the waveform to modulate other parameters of the synthesizer.\n\nIn HiSynth, there are three LFOs that can be used to modulate different parameters, including the pitch, amplitude, and cutoff frequencies of the filters. Each LFO can be configured with **Waveform**, **Depth**, **Rate**, and **Phase**. The depth determines how much the LFO affects the parameter, the rate determines how fast the LFO oscillates, and the phase determines where in the waveform the modulation starts.\n\nNote that these modulation can be combined to create complex variations. Try experimenting with different combinations to create surprising and unique sounds!"
        case .afx:
            return "Audio effects can change the sound in a variety of ways. In HiSynth, there are four sound effects you can play around with:\n\n**Reverb** is an effect that simulates the natural ambience of a room or space. It adds depth and space to your sound by creating a series of echoes that blend together.\n\n**Delay** is an effect that creates a series of echoes that follow the original sound. It can be used to create complex rhythms and patterns, as well as to add depth and texture to your sound.\n\n**Drive** is an effect that simulates the sound of a driven amplifier, adding warmth, grit, and character to your sound. It can be used to create distorted guitar sounds, or to add edge to synth leads and.\n\n**Decimator** is an effect that reduces the bit depth of the signal, creating a gritty, lo-fi sound that can be used for creative effect.\n\nach effect has its own controls and a mix control, allowing you to balance the dry (unprocessed) sound and wet (processed) sound."
        case .preset:
            return "Here you can play with HiSynth’s factory presets. The name of each factory preset ends with the sound type, which is one of the five categories: **Key**, **Lead**, **Pad**, **Pluck** and **FX**. Key sounds simulate the characteristic of a general keyboard-based instrument like piano. Lead sounds can be used for melodies and solos, while Pad sounds are designed to add background textures. Pluck sounds are percussive, plucky and FX sounds are sound effects that creative, complex or fun.\n\nYou can import and export sounds to share your sound design with your friends easily, with a short preset string in your pasteboard."
        case .rack:
            return "HiSynth’s rack compose of four components:\n\n- Oscilloscope: It displays the waveform of the sound being generated and processed by HiSynth. You can visually *see* the sound here.\n- Piano Roll: It displays the note history of the keyboard.\n- Song Player: This feature in only available on macOS, allowing you to play MIDI files directly in the synthesizer.\n- Octave Control: You can adjust the octave of the keyboard here.\n\nThis is the end of the tutorial. Hope you enjoy your journey with HiSynth and get to know better about the world of waveforms."
        }
    }

    var extras: AnyView? {
        switch self {
        case .env:
            return AnyView(
                HStack{
                    Spacer()
                    Image("ADSR")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300.0)
                    Spacer()
                }
            )
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


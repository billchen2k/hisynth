//
//  HiSynthCore.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/3.
//
import Foundation
import AudioKit
import Tonic

class HiSynthCore: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var polyOscillators: [PolyOscillator]

    @Published var oscillatorController: OscillatorController
    @Published var envelopeController: EnvelopeController
    @Published var filterController: FilterController
    @Published var lfoController: LFOController
    @Published var afxController: AFXController
    @Published var presetController: PresetController?
    @Published var rackController: RackController

    init() {
        polyOscillators = [PolyOscillator(), PolyOscillator()]
        let oscillatorController = OscillatorController(oscs: polyOscillators)
        let envelopeController = EnvelopeController(oscs: polyOscillators)
        let filterController = FilterController(envelopeController.outputNode)
        let sfxController = AFXController(filterController.outputNode)

        self.oscillatorController = oscillatorController
        self.envelopeController = envelopeController
        self.filterController = filterController
        self.afxController = sfxController
        engine.output = sfxController.outputNode

        // Connect lfos
        let lfoController = LFOController(connectors: [oscillatorController, filterController])
        lfoController.amplitudeMod = filterController.amplitudeModulator
        lfoController.filterLowMod = filterController.lowPassModulator
        lfoController.filterHighMod = filterController.highPassModulator
        lfoController.pitchMod = oscillatorController.pitchModulator
        self.lfoController = lfoController

        self.rackController =  RackController(sfxController.outputNode)
        self.presetController = PresetController(core: self)
        self.rackController.core = self
    }

    func noteOn(pitch: Pitch, point: CGPoint = CGPoint(0, 0)) {
        print("Note on:", pitch.midiNoteNumber)
        // If it is the first note, sync the lfo.
//        if oscillatorController.osc1.voices.count == 0 || oscillatorController.osc2.voices.count == 0 {
            lfoController.sync()
//        }
        oscillatorController.noteOn(pitch)
        rackController.noteHistoryManager.on(pitch)
    }

    func noteOff(pitch: Pitch) {
        print("Note off:", pitch.midiNoteNumber)
        oscillatorController.noteOff(pitch)
        rackController.noteHistoryManager.off(pitch)
    }

    func start() {
        do {
            try engine.start()
        } catch {
            print("Error: engine start failed.")
        }
        envelopeController.setup()
        filterController.setup()
        afxController.setup()
        presetController?.setup()
    }
}

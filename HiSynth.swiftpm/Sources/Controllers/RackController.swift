//
//  RackController.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/16.
//

import Foundation

/// Handles displaying real-time waveform, piano roll of playing history, chose sound, and octave
class RackController: ObservableObject {

    @Published var octave: Int8 = 3
    @Published var songs: [String] = []
    @Published var selectedSongs: String = ""
    @Published var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                sequencer.stop()
            } else {
                sequencer.play()
            }
        }
    }

    @Published var externalActivatedNotes: [Pitch] = []

    /// Used for drawing the piano roll.
    var noteHistoryManager: NoteHistoryManager = NoteHistoryManager()

    weak var core: HiSynthCore?
    var inputNode: Node

    private var sequencer = AppleSequencer()
    private var instrument: MIDICallbackInstrument?

    private var taskQueue = DispatchQueue(label: "io.billc.hisynth.midi")

    init(_ input: Node) {
        self.inputNode = input

        let midiFiles = Bundle.main.paths(forResourcesOfType: "mid", inDirectory: nil)
            .map { URL(fileURLWithPath: $0).deletingPathExtension().lastPathComponent }
        self.songs = midiFiles
        self.setUpSequencer()
    }

    private func setUpSequencer() {
        let instrument = MIDICallbackInstrument { status, note, velocity in
            guard let midiStatus = MIDIStatusType.from(byte: status) else {
                return
            }
            let pitch = Pitch(Int8(note))
            if midiStatus == .noteOn {
                self.taskQueue.async {
                    self.core?.noteOn(pitch: pitch)
                }
                self.externalActivatedNotes.append(pitch)
            } else if midiStatus == .noteOff {
                self.taskQueue.async {
                    self.core?.noteOff(pitch: pitch)
                }
                self.externalActivatedNotes.removeAll(where: { $0.midiNoteNumber == pitch.midiNoteNumber })
            }
        }
        self.instrument = instrument
    }

    private func setSong(_ song: String) {
        guard let instrument = instrument else {
            return
        }
        sequencer.loadMIDIFile(song)
        sequencer.setGlobalMIDIOutput(instrument.midiIn)
        sequencer.play()
    }
}

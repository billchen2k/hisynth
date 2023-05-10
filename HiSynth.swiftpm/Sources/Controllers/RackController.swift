//
//  RackController.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/16.
//

import Foundation
import Tonic
import AudioKit

struct Song {
    var title: String
    var composer: String?
    var fileName: String
}

/// Handles displaying real-time waveform, piano roll of playing history, chose sound, and octave
class RackController: ObservableObject {

    @Published var octave: Int8 = 4
    @Published var songs: [Song] = []
    @Published var selectedSong: Song
    @Published var tempo: Double = 120.0
    @Published var position: Duration = Duration(beats: 0.0, tempo: 0.0)
    @Published var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                sequencer.play()
            } else {
                sequencer.rewind()
                sequencer.stop()
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
        var songs: [Song] = midiFiles.map {
            // Song: composer - author
            let composer = $0.split(separator: "-").first?.trimmingCharacters(in: .whitespacesAndNewlines)
            let title = $0.split(separator: "-").last?.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let composer = composer, let title = title, composer != title else {
                return Song(title: $0, composer: nil, fileName: $0)
            }
            return Song(title: title, composer: composer, fileName: $0)
        }
        songs.sort(by: { $0.title < $1.title })
        self.songs = songs
        self.selectedSong = songs[1]
        self.setUpSequencer()
    }

    private func setUpSequencer() {
        let instrument = MIDICallbackInstrument { [self] status, note, velocity in
            print("Callback called \(status), \(note), \(velocity)")
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

        // Update progress every seconds
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.position = self.sequencer.currentRelativePosition
        }
        self.instrument = instrument
    }

    public func setSong(_ song: Song, play: Bool = true) {
        guard let instrument = self.instrument else {
            return
        }
        self.isPlaying = false
        sequencer.rewind()
        sequencer.loadMIDIFile(song.fileName)
        sequencer.setGlobalMIDIOutput(instrument.midiIn)
        tempo = sequencer.tempo
        self.selectedSong = song
        self.sequencer.setLoopInfo(Duration(beats: 2.0, tempo: tempo), loopCount: 10)
        self.sequencer.enableLooping()
        print("Song loaded: \(song.title)")
        if play {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                self.isPlaying = true
            }
        }
    }
}

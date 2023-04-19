import SwiftUI
import AVFoundation

@main
struct HiSynthApp: App {

    static let debug = false
    static var backgroundMusciAllowed = true
    static let sceneFPS = 30

    init() {
#if os(iOS)
        do {
            // Increase the buffer size.
            Settings.bufferLength = .long
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(Settings.bufferLength.duration)
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                            options: [.defaultToSpeaker, .mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)

            // Check if background audio is allowed (Only allowed on macOS)
            var midiIn = MIDIEndpointRef()
            let status: OSStatus = MIDIDestinationCreateWithBlock(MIDI.sharedInstance.client, "midi test" as CFString, &midiIn) { _, _ in }
            if status == kMIDINotPermitted {
                HiSynthApp.backgroundMusciAllowed = false
            }
        } catch let err {
            print(err)
        }
#endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}




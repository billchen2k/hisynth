import SwiftUI
import AVFoundation

@main
struct HiSynthApp: App {

    init() {
#if os(iOS)
        do {
            // Set buffer size to 256 samples on iOS devices.
            Settings.bufferLength = .medium
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(Settings.bufferLength.duration)
            try AVAudioSession.sharedInstance().setCategory(.playback,
                                                            options: [.defaultToSpeaker, .mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
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




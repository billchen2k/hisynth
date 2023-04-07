import SwiftUI
import AVFoundation

@main
struct HiSynthApp: App {

    init() {
#if os(iOS) && !targetEnvironment(macCatalyst)
        do {
            // Increase buffer size to 256 samples.
            Settings.bufferLength = .medium
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(Settings.bufferLength.duration)
            try AVAudioSession.sharedInstance().setCategory(.playback,
                                                            options: [.defaultToSpeaker, .mixWithOthers, .allowBluetoothA2DP])
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




import SwiftUI
import AVFoundation
import Keyboard

struct ContentView: View {

    @StateObject var core = HiSynthCore()

    init() {
        Fonts.registerAllFonts()
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [GridItem(.adaptive(minimum: 180))]) {
                        OscillatorPanel(controller: core.oscillatorController)
                        EnvelopePanel(controller: core.envelopeController)
                        OscillatorPanel(controller: core.oscillatorController)
                        OscillatorPanel(controller: core.oscillatorController)
                        OscillatorPanel(controller: core.oscillatorController)
                        OscillatorPanel(controller: core.oscillatorController)
                    }.padding(4.0)
                }
                .frame(height: geometry.size.height / 2.0)
                // Status Bar
                HStack{
                    Spacer()
                }.frame(height: 60)
                    .background(Color(hex: 0x333333))
                    .border(.black, width: 2)
                VStack {
                    KeyboardView(core: core)
                }
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: 0x4a4a4a), Color(hex: 0x000000)]),
                                       startPoint: .top, endPoint: .bottom))
        }
    }
}

struct ContentViewPreviewProvider: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeRight)
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
    }
}


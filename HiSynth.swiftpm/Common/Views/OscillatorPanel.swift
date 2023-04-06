//
//  OscillatorPanel.swift
//
//
//  Created by Bill Chen on 2023/4/5.
//

import Foundation
import SwiftUI

struct OscillatorPanel: View {

    @State var waveform: Float = 5.0

    weak var controller: OscillatorController?

    let waveforms: [HSWaveform] = [.sine, .saw, .square, .triangle, .pulse]

    var body: some View {
        ControlPanelContainer(title: "Oscillator") {
            HStack(spacing: 15) {
                // OSC1 Selector
                VStack {
                    GeometryReader { geo in
                        HStack(spacing: 15) {
                            HSSlider(value: $waveform, range: 1...5, steps: 5, height: geo.size.height, allowPoweroff: false)
                            VStack(alignment: .leading) {
                                ForEach(0..<waveforms.count, id: \.self) { i in
                                    HStack {
                                        ScreenBox(isOn: Int(waveform) == 5 - i, blankStyle: true,
                                                  width: 40, height: 22) {
                                            Image(waveforms[i].getSymbolImageName())
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 28)
                                        }
                                        Text(waveforms[i].getReadableName().uppercased())
                                            .modifier(HSFont(.body1))
                                    }
                                    if (i < waveforms.count - 1) {
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    Text("OSC 1 Waveform").modifier(HSFont(.body1))
                }
                VStack {
                }
            }
        }
    }
}

struct OscillatorPanel_Previews: PreviewProvider {
    static var previews: some View {
        OscillatorPanel().frame(width: 500, height: 220)
    }
}


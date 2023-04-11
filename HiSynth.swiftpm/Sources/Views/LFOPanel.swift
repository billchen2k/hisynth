//
//  LFOPanel.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/12.
//

import Foundation
import SwiftUI

struct LFOPanel: View {

    @ObservedObject var controller: LFOController

    @State var managing: Int = 0

    let waveforms: [HSWaveform] = [.sine, .rsaw, .saw, .square, .pulse]

    var lfoCount: Int {
        LFOController.lfoCount
    }

    var waveformValue: Float {
        4.0 - Float(waveforms.firstIndex(of: controller.waveforms[managing])!)
    }

    let knobSize: CGFloat = 48.0
    let switchWidth: CGFloat = 32.0
    let switchHeight: CGFloat = 26.0

    var body: some View {
        ControlPanelContainer(title: "Low Frequency Oscillator") {
            HStack(spacing: 8.0) {
                GeometryReader { geo in
                    VStack {
                        ForEach(0..<lfoCount, id: \.self) { i in
                            LightButton(isOn: managing == i,
                                        width: 30.0,
                                        height: 60.0,
                                        title: "LFO \(i + 1)",
                                        vertical: true) {
                                managing = i
                            }
                            if i < lfoCount - 1 { Spacer() }
                        }
                    }.frame(height: geo.size.height * 0.85)
                }.frame(width: 50.0)

                GeometryReader {geo in
                    VStack {
                        HStack(spacing: 15) {
                            HSSlider(value: .constant(waveformValue), range: 0...4, stepSize: 1.0, height: geo.size.height * 0.85, allowPoweroff: false) {value in
                                controller.waveforms[managing] = waveforms[4 - Int(value)]
                            }
                            VStack(alignment: .leading) {
                                ForEach(0..<waveforms.count, id: \.self) { i in
                                    HStack {
                                        ScreenBox(isOn: waveforms[i] == controller.waveforms[managing], blankStyle: true,
                                                  width: 40, height: 21) {
                                            Image(waveforms[i].getSymbolImageName())
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 26)
                                                .onTapGesture {
                                                    controller.waveforms[managing] = waveforms[i]
                                                }
                                        }
                                    }
                                    if (i < waveforms.count - 1) {
                                        Spacer()
                                    }
                                }
                            }.frame(height: geo.size.height * 0.85)
                        }
                        Spacer()
                        Text("OSC \(managing + 1) Waveform").modifier(HSFont(.body2))
                    }
                }.frame(width: 175.0)

                GeometryReader { geo in
                    VStack {
                        HStack {
                            VStack {
                                HSKnob(value: $controller.depths[managing],
                                       range: 0.0...1.0,
                                       size: knobSize,
                                       stepSize: 0.01,
                                       allowPoweroff: true)
                                Text("Depth").modifier(HSFont(.body2))
                            }
                            VStack {
                                HSKnob(value: $controller.speeds[managing],
                                       range: 0.25...20.0,
                                       size: knobSize,
                                       stepSize: 0.01,
                                       allowPoweroff: false,
                                       ifShowValue: true,
                                       valueFormatter: { String(format: "%.1f", $0)})
                                Text("Speed (Hz)").modifier(HSFont(.body2))
                            }
                            VStack {
                                HSKnob(value: $controller.phases[managing],
                                       range: 0.0...1.0,
                                       size: knobSize,
                                       stepSize: 0.01,
                                       allowPoweroff: false,
                                       ifShowValue: true,
                                       valueFormatter: { String(format: "%.1fπ", $0 * 2) })
                                Text("Phase").modifier(HSFont(.body2))
                            }
                        }
                        ScreenBox(isOn: false, blankStyle: false, width: geo.size.width * 0.9, height: geo.size.height * 0.35) {
                        }
                        Text("Waveform Preview").modifier(HSFont(.body2))
                    }
                }.frame(width: 180.0)
                VStack {
                    VStack(alignment: .leading) {
                        HStack {
                            ForEach(0..<lfoCount, id: \.self) { i in
                                LightButton(isOn: controller.modPitch[i], width: switchWidth, height: switchHeight) {
                                    controller.modPitch[i].toggle()
                                }
                            }
                            Text("PITCH").modifier(HSFont(.body1))
                        }
                        HStack {
                            ForEach(0..<lfoCount, id: \.self) { i in
                                LightButton(isOn: controller.modAmplitude[i], width: switchWidth, height: switchHeight) {
                                    controller.modAmplitude[i].toggle()
                                }
                            }
                            Text("AMPLITUDE").modifier(HSFont(.body1))
                        }
                        HStack {
                            ForEach(0..<lfoCount, id: \.self) { i in
                                LightButton(isOn: controller.modFilterLow[i], width: switchWidth, height: switchHeight) {
                                    controller.modFilterLow[i].toggle()
                                }
                            }
                            Text("FILTER LOW").modifier(HSFont(.body1))
                        }
                        HStack {
                            ForEach(0..<lfoCount, id: \.self) { i in
                                LightButton(isOn: controller.modFilterHigh[i], width: switchWidth, height: switchHeight) {
                                    controller.modFilterHigh[i].toggle()
                                }
                            }
                            Text("FILTER HIGH").modifier(HSFont(.body1))
                        }
                    }
                }
            }
        }
    }
}

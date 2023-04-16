//
//  RackView.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/16.
//

import Foundation
import SwiftUI
import SpriteKit

struct RackView: View {

    @ObservedObject var controller: RackController

    let buttonSize: CGFloat = 45.0

    var oscilloscopeScene: OscilloscopeScene {
        let scene = OscilloscopeScene()
        scene.controller = controller
        return scene
    }

    var body: some View {
        HStack {
            ScreenBox(isOn: false, blankStyle: false, width: 180.0, height: buttonSize) {
                SpriteView(scene: oscilloscopeScene, options: [.allowsTransparency],
                           debugOptions: [.showsFPS, .showsNodeCount])
                .padding(2.0)
            }.padding(.horizontal, 7.5)
            Spacer()
            HStack(spacing: -1) {
                Button(action: {
                    handleOctaveChange(-1)
                }, label: {
                    Rectangle()
                        .frame(width: buttonSize, height: buttonSize)
                        .foregroundColor(Theme.colorGray3)
                        .border(.black, width: 1.0)
                        .overlay {
                            Image(systemName: "arrowtriangle.left.fill")
                                .font(.system(size: 18.0))
                                .foregroundColor(.white)
                        }
                })
                ScreenBox(isOn: false, blankStyle: false, width: buttonSize, height: buttonSize) {
                    VStack(spacing: -2.0) {
                        Text("\(controller.octave)")
                            .font(.system(size: 20.0, weight: .bold))
                            .foregroundColor(Theme.colorBodyText)
                        Text("Octave").modifier(HSFont(.body2))
                    }
                }
                Button(action: {
                    handleOctaveChange(1)
                }, label: {
                    Rectangle()
                        .frame(width: buttonSize, height: buttonSize)
                        .foregroundColor(Theme.colorGray3)
                        .border(.black, width: 1.0)
                        .overlay {
                            Image(systemName: "arrowtriangle.right.fill")
                                .font(.system(size: 18.0))
                                .foregroundColor(.white)
                        }
                })
            }.padding(.horizontal, 7.5)
        }.frame(height: 60)
            .background(Theme.colorGray2)
            .border(.black, width: 2)
    }

    private func handleOctaveChange(_ offset: Int8) {
        let newOctave: Int8 = controller.octave + offset
        controller.octave = newOctave.clamped(to: 1...8)
    }
}

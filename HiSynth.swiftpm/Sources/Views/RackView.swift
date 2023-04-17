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

    @State private var showPlaylist: Bool = false

    let buttonSize: CGFloat = 45.0

    var oscilloscopeScene: OscilloscopeScene {
        let scene = OscilloscopeScene()
        scene.controller = controller
        return scene
    }

    var pianoRollScene: PianoRollScene {
        let scene = PianoRollScene()
        scene.manager = controller.noteHistoryManager
        return scene
    }

    private func IconButton(icon: String, action: @escaping (() -> Void)) -> some View {
        return Button(action: {
            action()
        }, label: {
            Rectangle()
                .frame(width: buttonSize, height: buttonSize)
                .foregroundColor(Theme.colorGray3)
                .border(.black, width: 1.0)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 18.0))
                        .foregroundColor(.white)
                }
        })
    }

    var body: some View {
        HStack(spacing: 0.0) {
            /// Oscilloscope
            ScreenBox(isOn: false, blankStyle: false, width: 180.0, height: buttonSize) {
                SpriteView(scene: oscilloscopeScene, options: [.allowsTransparency],
                           debugOptions: HiSynthApp.debug ? [.showsFPS, .showsNodeCount] : [])
                .padding(2.0)
            }.padding(.leading, 7.5)
                .padding(.trailing, 0.0)
            
            /// Piano Roll
            ScreenBox(isOn: false, blankStyle: false, width: 220.0, height: buttonSize) {
                SpriteView(scene: pianoRollScene,
                           preferredFramesPerSecond: 30,
                           options: [.allowsTransparency],
                           debugOptions: HiSynthApp.debug ? [.showsFPS, .showsNodeCount] : [])
                .padding(2.0)
            }.padding(.leading, 7.5)
                .padding(.trailing, 0.0)
            
            Spacer()
            
            /// Song Player: **Only available on macOS. Since I cannot enable background music for iOS devices.**
#if os(macOS) || targetEnvironment(macCatalyst)
            HStack(spacing: -1) {
                IconButton(icon: "music.note.list", action: {
                    showPlaylist.toggle()
                })
                .popover(isPresented: $showPlaylist) {
                    VStack {
                        List(content: {
                            Section(content: {
                                ForEach(controller.songs, id: \.fileName) { song in
                                    Button(action: {
                                        controller.setSong(song)
                                        showPlaylist = false
                                    }, label: {
                                        VStack(alignment: .leading) {
                                            Text(song.title)
                                            Text(song.composer ?? "").font(.caption)
                                        }
                                    })
                                }
                            }, footer: {
                                Text("Song player is only available on macOS.").font(.caption)
                            })
                        }).frame(width: 300.0, height: 400.0)

                    }
                }
                ScreenBox(isOn: false, blankStyle: false, width: 220.0, height: buttonSize) {
                    HStack {
                        VStack(alignment: .leading, spacing: -2.0) {
                            Text(controller.selectedSong.title)
                                .font(.system(size: 20.0, weight: .bold))
                                .foregroundColor(Theme.colorBodyText)
                            Text(controller.selectedSong.composer ?? "Now Playing").modifier(HSFont(.body2))
                        }
                        Spacer()
                    }.frame(width: 200.0).padding(0)
                }
                IconButton(icon: controller.isPlaying ? "stop.fill" : "play.fill", action: {
                    controller.isPlaying.toggle()
                })
            }.padding(.leading, 7.5)
                .padding(.trailing, 0.0)
                .onAppear {
                    controller.setSong(controller.songs[1], play: false)
                }
#endif
            /// Octave Control
            HStack(spacing: -1) {
                IconButton(icon: "arrowtriangle.left.fill", action: {
                    handleOctaveChange(-1)
                })
                ScreenBox(isOn: false, blankStyle: false, width: buttonSize, height: buttonSize) {
                    VStack(spacing: -2.0) {
                        Text("\(controller.octave)")
                            .font(.system(size: 20.0, weight: .bold))
                            .foregroundColor(Theme.colorBodyText)
                        Text("Octave").modifier(HSFont(.body2))
                    }
                }
                IconButton(icon: "arrowtriangle.right.fill", action: {
                    handleOctaveChange(1)
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



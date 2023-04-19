//
//  PresetView.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/13.
//

import Foundation
import SwiftUI

struct PresetPanel: View {

    @ObservedObject var controller: PresetController
    @EnvironmentObject var walkthrough: WalkthroughController

    @State private var showImport = false
    @State private var showImportSuccess = false
    @State private var importPresetStr = ""
    @State private var importedPresetName = ""
    @State private var showImportError = false
    @State private var importErrorMsg = ""

    @State private var showExport = false
    @State private var showExportSuccess = false
    @State private var exportPresetName = ""
    @State private var exportPresetStr = ""

    let buttonSize: CGFloat = 30.0

    var body: some View {
        ControlPanelContainer(title: "Presets", component: .preset) {
            HStack {
                GeometryReader { geo in
                    ScrollView(showsIndicators: true) {
                        VStack(spacing: -1) {
                            ForEach(controller.presets, id: \.name) { preset in
                                ScreenBox(isOn: preset == controller.currentPreset,
                                          blankStyle: false,
                                          width: geo.size.width, height: 28.0) {
                                    HStack{
                                        Text("\(preset.name)").modifier(HSFont(.body1))
                                        Spacer()
                                    }.padding(10.0)

                                }
                                          .onTapGesture {
                                              controller.currentPreset = preset
                                          }
                            }
                            Spacer()
                        }
                    }
                }
                .background(Theme.colorGray1)
                .border(.black, width: 1.0)
                .frame(width: 200.0)
                VStack(spacing: 10.0) {
                    Button(action: { handleImport() }) {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(Theme.colorGray4)
                    }
                    Button(action: { handleExport() }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Theme.colorGray4)
                    }
                    Spacer()
                }
                Spacer()
                GeometryReader { geo in
                    VStack(spacing: 20.0) {
                        Text("HiSynth").modifier(HSFont(.artTitle0))
                        Text("A simple yet powerful analog synthesizer\n for educational purpose.")
                            .multilineTextAlignment(.center)
                            .frame(width: 250.0)
                            .fixedSize()
                            .modifier(HSFont(.body1))
                        Text("Crafted with 💙 by Bill Chen.").modifier(HSFont(.body2))
                    }.frame(height: geo.size.height)
                    .onTapGesture {
                        walkthrough.presentWelcome = true
                    }
                }.frame(width: 260.0)
            }.padding(.bottom, 5.0)
        }
        .alert("Import Preset", isPresented: $showImport, actions: {
            TextField("Preset String", text: $importPresetStr)
            Button("Import", action: {
                controller.parsePreset(importPresetStr, onCompletion: { name in
                    showImportSuccess = true
                    importedPresetName = name
                }, onError: { err in
                    showImportError = true
                    importErrorMsg = err
                })
                showImport = false
            })
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Please paste the preset string below:")
        })
        .alert("Import Success", isPresented: $showImportSuccess, actions: {
            Button("OK", role: .cancel, action: {})
        }, message: {
            Text("Successfully imported preset \(importedPresetName).")
        })
        .alert("Import Error", isPresented: $showImportError, actions: {
            Button("OK", role: .cancel, action: {})
        }, message: {
            Text("Fail to import preset: \(importErrorMsg)")
        })
        .alert("Export Preset", isPresented: $showExport, actions: {
            TextField("Name (1 - 24 Characters)", text: $exportPresetName)
            Button("Export", action: {
                if exportPresetName.count > 0 && exportPresetName.count <= 24 {
                    exportPresetStr = controller.dumpCurrent(name: exportPresetName)
                    showExport = false
                    showExportSuccess = true
                }
            })
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Please name your preset (1 - 24 Characters):")
        })
        .alert("Export Success", isPresented: $showExportSuccess, actions: {
            Button("Copy to pasteboard", action: {
                UIPasteboard.general.string = exportPresetStr
            })
            Button("OK", role: .cancel, action: {})
        }, message: {
            Text("Successfully exported preset \(exportPresetName): \n\n\(exportPresetStr)")
        })
    }

    func handleExport() {
        showExport = true
    }

    func handleImport() {
        showImport = true
    }

}

//
//  RoundedCornerButton.swift
//  HiSynth
//
//  Created by Bill Chen on 2023/4/17.
//

import Foundation
import SwiftUI

struct ActionButton: View {
    var title: String
    var icon: String
    var width: CGFloat = 90.0

    var action: (() -> Void)

    var body: some View {
        Button(action: {
            action()
        }, label: {
            Rectangle()
                .fill(Theme.colorGray4)
                .cornerRadius(20.0)
                .frame(width: width, height: 24.0)
                .overlay {
                    RoundedRectangle(cornerSize: CGSize(width: 24.0, height: 24.0))
                        .stroke(Color.gray, lineWidth: 1.0)
                        .frame(width: width, height: 24.0)
                }
                .overlay {
                    HStack {
                        Image(systemName: icon)
                            .font(.system(size: 16.0))
                            .foregroundColor(Theme.colorBodyText)
                            .padding(4.0)
                        Spacer()
                        Text(title).modifier(HSFont(.body1))
                        Spacer()
                    }
                }
        })
    }
}

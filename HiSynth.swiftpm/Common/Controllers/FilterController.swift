//
//  FilterController.swift
//  
//
//  Created by Bill Chen on 2023/4/6.
//

import Foundation
import AVFoundation


class FilterController: ObservableObject {

    @Published var lowPassCutoff: AUValue = 0
    @Published var lowPassRes: AUValue = 0
    @Published var highPassCutoff: AUValue = 2000
    @Published var highPassRes: AUValue = 0

    


}

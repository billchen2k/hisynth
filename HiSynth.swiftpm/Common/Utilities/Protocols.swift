//
//  Protocols.swift
//  
//
//  Created by Bill Chen on 2023/4/6.
//

import Foundation

protocol HasKeyHandlar {
    func noteOn(_ pitch: Pitch)
    func noteOff(_ pitch: Pitch)
}

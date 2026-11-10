//
//  ToggleUIService.swift
//  spots
//
//  Created by Aiden Gage on 11/9/26.
//

import SwiftUI

@Observable
class ToggleUI {
    private var isVisible: Bool = true
    
    func update(newState: Bool) {
        isVisible = newState
    }
    
    func currState() -> Bool {
        return isVisible
    }
}

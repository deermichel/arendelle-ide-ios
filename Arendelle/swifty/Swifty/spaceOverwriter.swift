//
//  spaceOverwriter.swift
//  Swifty
//
//  Created by Pouya Kary on 2/5/15.
//  Copyright (c) 2015 Arendelle Language. All rights reserved.
//

import Foundation

func spaceOverwriterWithID (name: String, inout spaces: [String:[NSNumber]], inout screen: codeScreen) -> [NSNumber] {
    
    var toBeCopiedArray:[NSNumber] = [0]
    
    // OPENING THE SPACE
    
    if name.hasPrefix("$") {
        
        if checkIfStoredSpaceExists(spaceName: name, screen: &screen) {
            
            toBeCopiedArray = storedSpaceLoader(spaceName: name, screen: &screen)
            
        } else {
            report("No stored space as '\(name)' found", &screen)
        }
        
    } else if name.hasPrefix("!") {
        
        var funcCode = Arendelle(code: name)
        let functionParts = functionLexer(arendelle: &funcCode, screen: &screen)
        toBeCopiedArray = funcEval(funcParts: functionParts, screen: &screen, spaces: &spaces)
        
    } else {
        
        if spaces[name] != nil {
            
            toBeCopiedArray = spaces[name]!
            
        } else {
            
            report("Space \(name) not found", &screen)
        }
    }
    
    return toBeCopiedArray
}
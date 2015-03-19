//
//  Eval.swift
//  Swifty
//
//  Created by Pouya Kary on 11/14/14.
//  Copyright (c) 2014 Arendelle Language. All rights reserved.
//

import Foundation


    /// removes spaces defined eval
    func evalSpaceRemover (inout #spaces: [String:[NSNumber]], #spacesToBeRemoved: [String]) {
        for space in spacesToBeRemoved {
            if spaces[space] != nil && space != "@return" {
                spaces.removeValueForKey(space)
            }
        }
    }

    /// Kernel of Arendelle which evaluates any given Arendelle Blueprint
    func eval (inout arendelle: Arendelle, inout screen: codeScreen, inout spaces: [String:[NSNumber]]) -> [String] {
                    
        var spacesToRemove:[String] = []
        
        /// Paints a dot in the matrix
        func paintInDot (color: Int) {
            if screen.x < screen.screen.colCount() && screen.y < screen.screen.rowCount()
                && screen.x >= 0 && screen.y >= 0 {
                    screen.screen[screen.x, screen.y] = color
            }
        }
        
        
        while arendelle.i < arendelle.codeSize() && screen.whileSign && !screen.stop {
            
            var command = Character(arendelle.readAtI().toString().lowercaseString)
            
            switch command {
                
            //
            // GRAMMARS
            //
                
            case "(" :
                let grammarParts = openCloseLexer(openCommand: "(", arendelle: &arendelle, screen: &screen)
                let spaceToBeRemoved = spaceEval(grammarParts: grammarParts, screen: &screen, spaces: &spaces, arendelle: &arendelle)
                if spaceToBeRemoved != "" { spacesToRemove.append(spaceToBeRemoved) } 
                
            case "[" :
                let grammarParts = openCloseLexer(openCommand: "[", arendelle: &arendelle, screen: &screen)
                loopEval(grammarParts: grammarParts, screen: &screen, spaces: &spaces, arendelle: &arendelle)
                
            case "{" :
                let grammarParts = openCloseLexer(openCommand: "{", arendelle: &arendelle, screen: &screen)
               conditionEval(grammarParts: grammarParts, screen: &screen, spaces: &spaces, arendelle: &arendelle)
                
            case "'", "\"" :
                screen.title = onePartOpenCloseParser(openCloseCommand: command, spaces: &spaces, arendelle: &arendelle, screen: &screen, preprocessorState: false)
                --arendelle.i
                
                if screen.errors.count == 0 {
                    
                    titleWriteLine(screen.title)

                }
               
    
                
            //
            // FUNCTION
            //
                
            case "!" :
                let functionParts = functionLexer(arendelle: &arendelle, screen: &screen)
                funcEval(funcParts: functionParts, screen: &screen, spaces: &spaces)
                
            
                
            //
            // COMMANDS
            //
                
            case "p":
                paintInDot(screen.n)
                
            case "c":
                paintInDot(0)
                
            case "i":
                screen.x = 0
                screen.y = 0
                
            case "n":
                if screen.n == 4 { screen.n = 1 } else { screen.n++ }
                
            case "r":
                screen.x++
                
            case "l":
                screen.x--
                
            case "u":
                screen.y--
                
            case "d":
                screen.y++
                
            case "e":
                screen.whileSign = false
                
            case "w":
                NSThread.sleepForTimeInterval(0.001)
                
            case "s":
                report("Stop-Clean command is no longer supported by Arendelle compilers", &screen)
                
            case ",":
                report("Using grammar divider ',' out of grammars", &screen)
                
            case "<", ">":
                report("Using function header in middle of blueprint", &screen)
                
            case "]", "}", ")" :
                report("Grammar closer: '\(command)' is used for an undefined grammar", &screen)
                
            case ";":
                report("Semicolons found in command-zone", &screen)
                
            case ":":
                report("In-Function comment sign found in command-zone", &screen)
                
            case "@":
                report("Space sign found in command-zone", &screen)
                
            case "#":
                report("Source sign found in command-zone", &screen)
                
            case "$":
                report("Stored space sign found in command-zone", &screen)
                
            case "*", "/", "^", "-", "+", "%" :
                report("Arithmetic operator '\(command)' found in command-zone", &screen)
                
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                report("Number '\(command)' found in command-zone", &screen)
                
            default:
                report("Unknown command: \(command)", &screen)
            }
            
            arendelle.i++
        
        }
    
        return spacesToRemove
}

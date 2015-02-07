//
//  OnePartOpenCloseParser.swift
//  Swifty
//
//  Created by Pouya Kary on 11/23/14.
//  Copyright (c) 2014 Arendelle Language. All rights reserved.
//

import Foundation

func onePartOpenCloseParser (#openCloseCommand:Character, inout #spaces: [String:[NSNumber]], inout #arendelle: Arendelle, inout #screen: codeScreen, #preprocessorState: Bool) -> String {

    // going to the right char
    ++arendelle.i
    
    // our result
    var result:String = ""
    
    // value replacing controller
    var replace:Bool = false
    
    // corrent char
    var charToRead:Character
    
    while arendelle.whileCondtion() {
    
        // corrent char
        charToRead = arendelle.readAtI()
        
        switch charToRead {
        
        case openCloseCommand :
            arendelle.i++
            return result
            
        case "\\" :
            
            if arendelle.whileCondtion() {
            
                arendelle.i++
                charToRead = arendelle.readAtI()
                
                switch charToRead {
                    
                case "\"" :
                    result += "\""
                    
                case "'"  :
                    result += "'"
                    
                case "\\" :
                    result += "\\"
                    
                case "(" :
                    var replacerParts = openCloseLexer(openCommand: "(", arendelle: &arendelle, screen: &screen)
                    var replacerOnePart = ""
                    for part in replacerParts { replacerOnePart += part }
                    
                    if preprocessorState == true {
                        result += "\\("
                        result += replacerOnePart
                        result += ")"
                        
                        if arendelle.i >= arendelle.codeSize() {
                            report("Unfinished replace scape \\( ... ) found", &screen)
                        }
                        
                    } else {
                        result += mathEval(stringExpression: replacerOnePart, screen: &screen, spaces: &spaces).result.stringValue
                    }
                    
                    --arendelle.i
                    
                default:
                    report("Bad escape sequence: '\\\(charToRead)'", &screen)
                }
            
            } else {
            
                report("Unfinished \(openCloseCommand)...\(openCloseCommand) grammar found", &screen)
                return "BadGrammar"
            
            }
            
        default:
            result.append(charToRead)
        
        }
        
        arendelle.i++
    
    }
    
    report("Unfinished \(openCloseCommand)...\(openCloseCommand) grammar found", &screen)
    return "BadGrammar"
}
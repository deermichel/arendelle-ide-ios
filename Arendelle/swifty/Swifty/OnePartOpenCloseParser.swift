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
            
        case "|" :
            var replacerParts = openCloseLexer(openCommand: "|", arendelle: &arendelle, screen: &screen)
            var replacerOnePart = ""
            for part in replacerParts { replacerOnePart += part }
            
            if preprocessorState == true {
                result += "|"
                result += replacerOnePart
                result += "|"
                
                if arendelle.i >= arendelle.codeSize() {
                    report("Unfinished string interpolation | ... | found", &screen)
                }
                
            } else {
                if replacerOnePart != "" {
                    
                    result += mathEval(stringExpression: replacerOnePart, screen: &screen, spaces: &spaces).result.stringValue
                    
                } else {
                    var errtext = ""
                    
                    if result.utf16Count > 10 {
                        
                        
                        
                    } else {
                        
                        errtext = result
                        
                    }
                    
                    screen.errors.append("Empty string interpolation found: \"\(result)| ... |")
                }
            }
            
            --arendelle.i
            
        case "\\" :
            
            if arendelle.whileCondtion() {
            
                arendelle.i++
                charToRead = arendelle.readAtI()
                
                switch charToRead {
                    
                case "n" :
                    result += "\n"
                    
                case "t" :
                    result += "   " // 1 tab in Arendelle == 3 white spaces;
                    
                case "\"" :
                    result += "\""
                    
                case "'"  :
                    result += "'"
                    
                case "\\" :
                    result += "\\"
                    
                case "|" :
                    result += "|"
                    
                    
                /* 
                    
                    /* ----------------------------------------------------------------------- *
                     * ::::: I N   C A S E   O F   S W I F T   I N T E R P O L A T I O N ::::: *
                     * ----------------------------------------------------------------------- */
                    
                case "(" :
                    var replacerParts = openCloseLexer(openCommand: "(", arendelle: &arendelle, screen: &screen)
                    var replacerOnePart = ""
                    for part in replacerParts { replacerOnePart += part }
                    
                    if preprocessorState == true {
                        result += "\\("
                        result += replacerOnePart
                        result += ")"
                        
                        if arendelle.i >= arendelle.codeSize() {
                            report("Unfinished string interpolation \\( ... ) found", &screen)
                        }
                        
                    } else {
                        if replacerOnePart != "" {
                            
                            result += mathEval(stringExpression: replacerOnePart, screen: &screen, spaces: &spaces).result.stringValue
                            
                        } else {
                            var errtext = ""
                            
                            if result.utf16Count > 10 {
                            
                                
                            
                            } else {
                            
                                errtext = result
                            
                            }
                            
                            screen.errors.append("Empty string interpolation found: \"\(result)\\()...\"")
                        }
                    }
                    
                    --arendelle.i */
                    
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
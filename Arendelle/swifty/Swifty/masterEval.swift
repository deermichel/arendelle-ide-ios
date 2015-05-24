//
//  masterEval.swift
//  Swifty
//
//  Created by Pouya Kary on 11/25/14.
//  Copyright (c) 2014 Arendelle Language. All rights reserved.
//

import Foundation

/// Space remover tool: removes spaces and comments from
/// the code for performance
func preprocessor (#codeToBeSpaceFixed: String, inout #screen: codeScreen) -> String {
    
    var spaces: [String: [NSNumber]] = ["@return":[0]]

    var theCode = Arendelle (code: codeToBeSpaceFixed)
    var result : String = ""
    var tempArray = Array(theCode.code)
    
    while theCode.whileCondtion() {
        
        var currentChar = theCode.readAtI()
        
        switch currentChar {
            
        case "'" :
            result += "'" + onePartOpenCloseParser(openCloseCommand: "'", spaces: &spaces, arendelle: &theCode, screen: &screen, preprocessorState: true) + "'"
            --theCode.i
            
        case "\"" :
            result += "\"" + onePartOpenCloseParser(openCloseCommand: "\"", spaces: &spaces, arendelle: &theCode, screen: &screen, preprocessorState: true) + "\""
            --theCode.i
            
        case "/" :
            ++theCode.i
            currentChar = tempArray[theCode.i]
            
            //
            // SLASH SLASH COMMENT REMOVER
            //
            
            
            
            if currentChar == "/" {
                
                theCode.i++
                var whileControl = true
                
                while theCode.i < count(theCode.code.utf16) && whileControl {
                    
                    currentChar = tempArray[theCode.i]
                    
                    if currentChar == "\n" {
                        
                        whileControl = false
                        
                    } else {
                        
                        theCode.i++
                        
                    }
                    
                }
                
                
                //
                // SLASH START ... STAR SLASH REMOVER
                //
                
            } else if currentChar == "*" {
                
                theCode.i++
                var whileControl = true
                
                while theCode.i < count(theCode.code.utf16) && whileControl {
                    
                    currentChar = tempArray[theCode.i]
                    
                    if currentChar == "*" {
                        
                        theCode.i++
                        
                        if theCode.i < count(theCode.code.utf16) {
                            
                            currentChar = tempArray[theCode.i]
                            
                            if currentChar == "/" {
                                
                                whileControl = false
                                
                            } else {
                                
                                theCode.i++
                                currentChar = tempArray[theCode.i]
                                
                            }
                        }
                    }
                    
                    theCode.i++
                }
                
                if whileControl == true { report("Unfinished /* ... */ comment", &screen) }
                
                //
                // ARE WE WRONG
                //
                
            } else {
                
                result += "/"
                
            }
            
            theCode.i--
            
        case "&", "|":
            report("&&/& and ||/| are not accepted by Arendelle, Use 'and' and 'or' instead", &screen)

        case "÷":
            result += "÷"
            
        case "×":
            result += "*"
            
        case " ", "\n", "\t" :
            break
            
        default:
            result.append(currentChar)
            
        }
        
        theCode.i++
    }
    
    
    return result
}



func masterEvaluator (#code: String, inout #screen: codeScreen) {
    
    //
    // Initing the first spaces
    //
    
    var spaces: [String: [NSNumber]] = ["@return":[0]]

    //
    // Rest of initilization
    //
    
    var arendelle = Arendelle(code: preprocessor(codeToBeSpaceFixed: code, screen: &screen))
        
    //
    // EVALUATION
    //

    let toBeRemoved = eval(&arendelle, &screen, &spaces)
    evalSpaceRemover(spaces: &spaces, spacesToBeRemoved: toBeRemoved)
    
    // done
}
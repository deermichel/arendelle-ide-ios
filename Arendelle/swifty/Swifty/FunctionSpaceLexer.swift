//
//  FunctionLexer.swift
//  Swifty
//
//  Created by Pouya Kary on 12/28/14.
//  Copyright (c) 2014 Arendelle Language. All rights reserved.
//

import Foundation

struct FuncParts {
    
    var name:String
    var inputs:[String]
    var index:String
    
    init () {
        self.name = "BadGrammar"
        self.inputs = []
        self.index = "0"
    }
}


func functionLexer (inout #arendelle: Arendelle, inout #screen: codeScreen) -> FuncParts {

    var name:String
    var inputs:[String]
    var input:String
    
    var result = FuncParts()
    
    var whileControl = true
    var charToRead:Character
    var part = ""
    
    arendelle.i++
    

    
    //
    // ! FUNC (120, 23, 34) [12]
    // --^^^^-------------------
    
    while whileControl && arendelle.whileCondtion() {
    
        charToRead = arendelle.readAtI()
        
        if charToRead == "(" {
            
            if part =~ "[a-zA-Z0-9\\.]+" {
        
                result.name = part
                whileControl = false;
                
            } else {
                report("Bad function name found: \(part)", &screen)
                return result
            }
            
        } else {
        
            part.append(charToRead)
            arendelle.i++
            
            if arendelle.i == count(arendelle.code.utf16) {
                report("Function name without parenthesis found", &screen)
                return result
            }
        }
    }
    

    
    //
    // ! FUNC (120, 23, 34) [12]
    // --------^^^^^^^^^^^------
    
    if arendelle.i < arendelle.codeSize() - 1 {
    
        let numberOfErrorBefore = screen.errors.count
        let inputParts = openCloseLexer(openCommand: "(", arendelle: &arendelle, screen: &screen)
        
        if screen.errors.count == numberOfErrorBefore {
        
            result.inputs = inputParts
            
        } else {
            report("Broken function parenthesis found", &screen)
            return result
        }
    }
    
    
    
    //
    // ! FUNC (120, 23, 34) [12]
    // ----------------------^^-
    
    if arendelle.whileCondtion() {
    
        charToRead = arendelle.readAtI()
        
        if charToRead == "[" {
            
            let numberOfErrorBefore = screen.errors.count
            let indexParts = openCloseLexer(openCommand: "[", arendelle: &arendelle, screen: &screen)
            
            if screen.errors.count == numberOfErrorBefore && indexParts.count == 1 {
                
                result.index = indexParts[0]
                return result
                
            } else {
                if indexParts.count != 1 {
                    report("Function index with more or less than one part found.", &screen)
                    return result
                } else {
                    report("Broken function parenthesis found", &screen)
                    return result
                }
            }
        }
    }
    
    return result
}
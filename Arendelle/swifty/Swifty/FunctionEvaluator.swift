//
//  FunctionEvaluator.swift
//  Swifty
//
//  Created by Pouya Kary on 12/29/14.
//  Copyright (c) 2014 Arendelle Language. All rights reserved.
//

import Foundation



func funcEval (#funcParts: FuncParts, inout #screen: codeScreen, inout #spaces: [String:[NSNumber]]) -> [NSNumber] {
    
    
    if funcParts.name == "BadGrammar" { return [0] }
    
    let numberOfErrorsInStart = screen.errors.count
    
    func funcHeaderReader (inout #code: Arendelle) -> [String] {
        
        let header = code.code =~ "<(.|\n)*>"
        
        if header.items.count > 0 {
        
            if code.code.hasPrefix(header[0]) {
                
                return openCloseLexer(openCommand: "<", arendelle: &code, screen: &screen)
                
            } else {
                report("Function started with something other than function header", &screen)
                return ["BadGrammar"]
            }
            
        } else {
            return [""]
        }
        
    }

    if funcParts.name =~ "[a-zA-Z0-9\\.]+" {
        
        let funcURL = arendellePathToNSURL(arendellePath: funcParts.name, kind: "arendelle" , screen: &screen)
        
        if checkIfURLExists (funcURL) {
   
            var funcCode = Arendelle(code: preprocessor (codeToBeSpaceFixed: String(contentsOfURL: funcURL, encoding: NSUTF8StringEncoding, error: nil)!, screen: &screen))

            if funcCode.code != "" {
            
                var funcSpaces: [String: [NSNumber]] = ["@return":[0]]
                let headerParts = funcHeaderReader(code: &funcCode )
                
                //
                // FUNCTION SPACE'S EVAL
                //
                
                
                var numberOfHeaderParts = headerParts.count; if headerParts[0] == "" { numberOfHeaderParts--}
                var numberOfFunctionParts = funcParts.inputs.count; if funcParts.inputs[0] == "" { numberOfFunctionParts--}
                
                if numberOfHeaderParts == numberOfFunctionParts {
                    
                    for var counter = 0; counter < numberOfFunctionParts; counter++  {
                        
                        var spaceExpr = funcParts.inputs[counter]
                        
                        let match = funcParts.inputs[counter] =~ "[a-zA-Z0-9]+:"
                        if match.items.count == 1{
                            if funcParts.inputs[counter].hasPrefix(match.items[0]) {
                                spaceExpr = funcParts.inputs[counter].substringFromIndex(match.items[0].utf16Count)
        
                            }
                        }
                        
                        let regexMatchForPartTwo = spaceExpr =~ "((\\$|\\@)[0-9a-zA-Z\\.]+)|(![a-zA-Z0-9\\.]+(\\((?:\\(.*\\)|[^\\(\\)])*\\)))"
                        
                        let spaceName = "@\(headerParts[counter])"
                        
                        
                        //----- Space overwrite -----------------------------------------------------------------------------------------
                        
                        if regexMatchForPartTwo.items.count == 1 && regexMatchForPartTwo.items[0] == spaceExpr {
                         
                            funcSpaces[spaceName] = spaceOverwriterWithID(spaceExpr, &spaces, &screen)
                            
                        //----- Only first space ----------------------------------------------------------------------------------------
                            
                        } else {
                            
                            var spaceValue = mathEval(stringExpression: spaceExpr, screen: &screen, spaces: &spaces)
                            
                            if spaceValue.itsNotACondition == true && spaceValue.doesItHaveErros == false {
                                
                                funcSpaces[spaceName] = [spaceValue.result]
                                
                            } else {
                                if spaceValue.doesItHaveErros == true {
                                    report("Header value for '\(spaceName)' of function: !\(funcParts.name)() is broken", &screen)
                                } else {
                                    report("Conditional value fount for '\(spaceName)' of function: !\(funcParts.name)()", &screen)
                                }
                            }
                        }
                        
                        //---------------------------------------------------------------------------------------------------------------
                    }
                    
                //
                // ERROR FOR FUNCTION SPACE NUMBERS
                //
                
                    
                } else {
                    switch (numberOfHeaderParts) {
                    case 0:
                        report("Function: !\(funcParts.name)() takes no space", &screen)
                    case 1:
                        report("Function: !\(funcParts.name)() takes one space", &screen)
                    default:
                        report("Function: !\(funcParts.name)() takes \(headerParts.count) spaces", &screen)
                    }
                }
                
                
                
                //
                // FUNCTION EVAL
                //
                
                if numberOfErrorsInStart == screen.errors.count {
                
                    let nowName = screen.funcName
                    screen.funcName = funcParts.name
                    
                    let toBeRemoved = eval (&funcCode, &screen, &funcSpaces)
                    evalSpaceRemover(spaces: &funcSpaces, spacesToBeRemoved: toBeRemoved)
                    
                    screen.funcName = nowName
                    
                    return funcSpaces["@return"]!
                    
                } else {
                    return [0]
                }
                
                //
                // DONE
                //
                
                
            } else {
                report("Could not load function '\(funcParts.name)'", &screen)
                return [0]
            }
            
        } else {
            report("No function with name '\(funcParts.name)' found", &screen)
            return [0]
        }
    
    } else {
        report("Bad function name: '\(funcParts.name)' found", &screen)
        return [0]
    }
}
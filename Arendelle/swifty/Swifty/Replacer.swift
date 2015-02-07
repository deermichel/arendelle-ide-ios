//
//  Replacer.swift
//  Swifty
//
//  Created by Pouya Kary on 11/30/14.
//  Copyright (c) 2014 Arendelle Language. All rights reserved.
//


import Foundation


func spaceReplacerWithEvaluation (#name: String, #spaceParts: [String], #simpleSpaceOrNot: Bool, #numberOfErrors: Int, inout #screen: codeScreen, inout spaces: [String:[NSNumber]]) -> String {
    
    var result = "0"
    
    if spaceParts.count == 1 && numberOfErrors == screen.errors.count {
        
        let calculatedIndexExpression = mathEval(stringExpression: spaceParts[0], screen: &screen, spaces: &spaces)
        
        if calculatedIndexExpression.doesItHaveErros == false && calculatedIndexExpression.itsNotACondition {
            
            if simpleSpaceOrNot {
                result = spaceLoaderWithName(name, atIndex: calculatedIndexExpression.result.integerValue, spaces: spaces, screen: &screen).stringValue
            } else {
                result = storedSpaceLoaderWithName(name, atIndex: calculatedIndexExpression.result.integerValue, spaces: spaces, screen: &screen).stringValue
            }
            
        } else if calculatedIndexExpression.itsNotACondition == false {
            report("Using conditions are not allowed in space index", &screen)
        }
        
    } else if spaceParts.count != 1 {
        report("Space with array index with more or less than one part found.", &screen)
    }
    
    return result
}





func storedSpaceLoaderWithName (name: String, atIndex index: Int, #spaces: [String:[NSNumber]], inout #screen: codeScreen) -> NSNumber {

    var spaceArray = storedSpaceLoader(spaceName: name, screen: &screen);
    
    if spaceArray.count > index && index >= 0 {
    
        return spaceArray[index]
    
    } else {

        report("Array out of range for \(name) at [ \(index) ]", &screen)
        return 0;
    }
    
}



func spaceLoaderWithName (name: String, atIndex index: Int, #spaces: [String:[NSNumber]], inout #screen: codeScreen) -> NSNumber {
    
    var result:NSNumber = 0;

    if spaces[name] != nil {
        
        if spaces[name]!.count > index && index >= 0 {
        
            let temp = spaces[name]?[index]; result = temp!
        
        } else {
            report("Array out of range for \(name) at [ \(index) ]", &screen)
        }
        
    } else {
        report("Space \(name) not found", &screen)
    }
    
    return result
}





func spaceSize (#spaceName: String, #spaces:[String:[NSNumber]], #simpleSpaceOrNot: Bool, inout #screen: codeScreen) -> Int {
    
    if simpleSpaceOrNot {
    
        if spaces[spaceName] != nil {
    
            let a = spaces[spaceName]?.count
            return a!
            
        } else {
            report("Space \(spaceName) not found", &screen)
            return 0
        }
    
    } else {
    
        let numOfErrs = screen.errors.count;
        var space = storedSpaceLoader(spaceName: spaceName, screen: &screen);
        
        if numOfErrs == screen.errors.count {
        
            return space.count;
        
        } else {
            return 0;
        }
    }
}





func replacer (#expressionString: String, inout #spaces: [String:[NSNumber]], inout #screen: codeScreen) -> String {
    
    var collection : [String] = []
    var part = ""
    func cleanPart () {
        part = part.replace("floor", withString: "floo_r")
        part = part.replace("or", withString: "||")
        part = part.replace("floo_r", withString: "floor")
        part = part.replace("and", withString: "&&")
        collection.append(part); part = ""
    }
    
    
    
    var expression = Arendelle(code: expressionString)
    
    
    var replaceString = "";
    
    while expression.whileCondtion() {
        
        var command = expression.readAtI()
        
        switch command {
            
        //
        // SOURCE REPLACER
        //
            
        case "#":
            
            cleanPart()
            expression.i++
            
            while expression.whileCondtion() {
                var command = Array(expression.code)[expression.i]
                if "\(command)" =~ "[a-zA-Z]" {
                    replaceString += "\(command)"
                } else {
                    break
                }
                expression.i++
            }
            
            switch replaceString.lowercaseString {
                
            case "i" , "width" :
                replaceString = "\(screen.screen.colCount())"
                
            case "j" , "height" :
                replaceString = "\(screen.screen.rowCount())"
                
            case "x" :
                replaceString = "\(screen.x)"
                
            case "y" :
                replaceString = "\(screen.y)"
                
            case "n" :
                replaceString = "\(screen.n)"
                
            case "pi" :
                replaceString = "3.141592653589"
                
            case "rnd" :
                replaceString = arendelleRandom()
                
            case "date" :
                replaceString = timeDate()
            
                
            default:
                report("No source as '\(replaceString)' exists", &screen)
                replaceString = "0"
            }
            
            collection.append(replaceString); replaceString = ""
         
            
            
            
            
            
        //
        // FUNCTION REPLACER
        //
            
        case "!":
            
            cleanPart()
            
            let funcParts = functionLexer(arendelle: &expression, screen: &screen)
            let result = funcEval(funcParts: funcParts, screen: &screen, spaces: &spaces)
            
            if funcParts.index != "0" {
                
                let index = mathEval(stringExpression: funcParts.index, screen: &screen, spaces: &spaces)
                
                if index.itsNotACondition == true &&  index.doesItHaveErros == false && index.result.integerValue >= 0 && index.result.integerValue < result.count {
                    
                    collection.append("\(result[index.result.integerValue])")
                    
                } else {
                    if index.result.integerValue < 0 || index.result.integerValue >= result.count {
                        report("Index of function !\(funcParts.name)() out of range", &screen)
                    } else if index.itsNotACondition == false {
                        report("Condition found in index of function !\(funcParts.name)()", &screen)
                    } else {
                        report("Bad expression for index of function !\(funcParts.name)()", &screen)
                    }
                    
                    collection.append("0");
                }
                
            } else {
                
                collection.append("\(result[0])")
                
            }
            
            
            
            
    
            
            
        //
        // SPACE FAMILY REPLACER
        //
            
        case "$", "@":
            
            cleanPart()
            
            var simpleSpaceOrNot = true; if command == "$" { simpleSpaceOrNot = false }
            
            var rule = ""; if simpleSpaceOrNot { rule = "\\." }
            replaceString.append(command); expression.i++
            

            //
            // ADD storedSpaceLoader FOR STORED SAPCES
            //
            
            while expression.whileCondtion() {
                
                var command = expression.readAtI()
                
                if String(command) =~ "[a-zA-Z\(rule)]" {
                    replaceString.append(command)
                    
                } else if command == "[" {
                    
                    let numberOfErrors = screen.errors.count
                    var spaceGrammarParts = openCloseLexer(openCommand: "[", arendelle: &expression, screen: &screen)
                    
                    replaceString = spaceReplacerWithEvaluation(name: replaceString, spaceParts: spaceGrammarParts, simpleSpaceOrNot: simpleSpaceOrNot, numberOfErrors: numberOfErrors, screen: &screen, &spaces)
                    
                    break
                    
                } else if command == "?" {
                    
                    expression.i++
                    replaceString = "\(spaceSize(spaceName: replaceString, spaces: spaces, simpleSpaceOrNot: simpleSpaceOrNot, screen: &screen))"
                    break
                    
                } else {
                
                    if simpleSpaceOrNot {
                        replaceString = spaceLoaderWithName(replaceString, atIndex: 0, spaces: spaces, screen: &screen).stringValue
                    } else {
                        replaceString = storedSpaceLoader(spaceName: replaceString, screen: &screen)[0].stringValue
                    }
                    
                    break
                
                }
                
                if expression.i == expression.codeSize() - 1 {
                    
                    if simpleSpaceOrNot {
                        replaceString = spaceLoaderWithName(replaceString, atIndex: 0, spaces: spaces, screen: &screen).stringValue
                    } else {
                        replaceString = storedSpaceLoader(spaceName: replaceString, screen: &screen)[0].stringValue
                    }
                }
                
                expression.i++

            }
            
            collection.append(replaceString); replaceString = ""

            
            
            
            
            
        //
        // NO-NEED-FOR REPLACEMENT PARTS
        //
            
        default:
            part.append(command)
            if expression.i < expression.codeSize() - 1 {
                expression.i++
            } else {
                cleanPart()
                expression.i++
            }
        }
    }
    
    
    //for line in collection { println("--> '\(line)'") }
    
    var result = ""; for str in collection { result += str }; return result
}


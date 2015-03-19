//
//  SpaceEvaluator.swift
//  Swifty
//
//  Created by Pouya Kary on 12/15/14.
//  Copyright (c) 2014 Arendelle Language. All rights reserved.
//

import Foundation

struct spaceStruct {
    var name : String
    var index : Int
    
    init (spaceName: String, spaceIndex: Int) {
        self.name = spaceName
        self.index = spaceIndex
    }
}


// Stores a value into the given space
func saveToSpace (#spaceName: String, #indexAtSpace: Int, #valueToSave: NSNumber, inout #spaces: [String:[NSNumber]]) {
    
    if spaces["@\(spaceName)"] == nil {
        spaces["@\(spaceName)"] = [0]
    }
    
    if spaces["@\(spaceName)"]?.count < indexAtSpace + 1 {
        
        let toStupidityOfOptionalTypeOfSwift = spaces["@\(spaceName)"]?.count
        let forNumber = indexAtSpace - toStupidityOfOptionalTypeOfSwift!
        
        for var addressOfLastIndex = 0; addressOfLastIndex < forNumber ; addressOfLastIndex++ {
            spaces["@\(spaceName)"]?.append(0)
        }
        spaces["@\(spaceName)"]?.append(valueToSave)
        
    } else {
        spaces["@\(spaceName)"]?[indexAtSpace] = (valueToSave)
    }
}


/// Reads a [NSNumber] from an Arendelle Stored Space
func storedSpaceLoader (#spaceName: String, inout #screen: codeScreen) -> [NSNumber] {

    let spaceURL = arendellePathToNSURL(arendellePath: spaceName.replace("$", withString: ""), kind: "space", screen: &screen)
    var checkValidation = NSFileManager.defaultManager()
    
    if checkValidation.fileExistsAtPath(spaceURL.path!) {
    
        let spaceValue = String(contentsOfURL: spaceURL, encoding: NSUTF8StringEncoding, error: nil)?.replace("\n", withString: "")
        let array = spaceValue?.componentsSeparatedByString(";"); var addArray:[NSNumber] = []
        for spc in array! { addArray.append(NSNumber(double: spc.toDouble())) }
        
        if addArray != [] {
            
            return addArray
            
        } else {
            report("Broken stored space: '\(spaceName)' found", &screen)
            return [0]
        }
    
    } else {
        report("No stored space as '\(spaceName)' found", &screen)
        return [0]
    }
}

/// Checks if a stored space exists
func checkIfStoredSpaceExists (#spaceName: String, inout #screen: codeScreen) -> Bool {

    let spaceURL = arendellePathToNSURL(arendellePath: spaceName.replace("$", withString: ""), kind: "space", screen: &screen)
    return checkIfURLExists(spaceURL)
}


/// Evaluates a space grammar
func spaceEval (#grammarParts: [String], inout #screen: codeScreen, inout #spaces: [String:[NSNumber]], inout #arendelle: Arendelle) -> String {
    
    var spaceResult = "";
    
    func spaceRegexNameError (#text: String) {
        report("Unaccepted space name : '\(grammarParts[0])'", &screen)
    }
    
    
    func saveNumberToStoredSpace (#number: [NSNumber], toSpace space: String) {
        
        let spaceURL = arendellePathToNSURL(arendellePath: space, kind: "space", screen: &screen)
        
        storedSpaceFolderChecker(spaceURL, screen.mainPath)
        
        var toBeStored = "\(number)".replace(" ", withString: "").replace(",", withString: ";")
        
        let er = toBeStored[1...toBeStored.utf16Count-2].writeToURL(spaceURL, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        
        if !er {
            report("Storing space '\(space).space' failed", &screen)
        }
    }
    
    
    func spaceNameAndIndexReaderWithName (name: String) -> spaceStruct {
    
        var spaceName = ""; var spaceIndexFinal:Int = 0; var spaceReader = Arendelle(code: name);
        
        while spaceReader.whileCondtion() {
            
            var spaceCharToRead = spaceReader.readAtI()
            
            switch spaceCharToRead {
                
            case "[":
                let spaceIndexArgs = openCloseLexer(openCommand: "[", arendelle: &spaceReader, screen: &screen)
                
                if spaceIndexArgs.count == 1 {
                
                    var spaceIndex = mathEval(stringExpression: spaceIndexArgs[0], screen: &screen, spaces: &spaces)
                    
                    if spaceIndex.itsNotACondition && spaceIndex.doesItHaveErros == false {
                    
                        spaceIndexFinal = spaceIndex.result.integerValue
                    
                    } else if spaceIndex.itsNotACondition == false {
                        report("Space index must not be condition", &screen)
                    }
                    
                } else {
                    report("Space index must be one part", &screen)
                }
                
            default :
                spaceName.append(spaceCharToRead)
                spaceReader.i++
            }
        }
    
        return spaceStruct(spaceName: spaceName, spaceIndex: spaceIndexFinal)
    }
    
    
    
    /*if grammarParts[0].hasPrefix("return") {
        if spaces["@return"] == nil {
            report("Using @return is forbidden in the main blueprint", &screen)
        }
    }*/

    
    let regexMathes = grammarParts[0] =~ "(([a-zA-Z0-9_]+)|(\\$[a-zA-Z0-9_\\.]+)) *(\\[.*\\])?"
    
    if grammarParts.count == 1 {
    
        //
        // UNTITLED INPUT
        //
        
        if regexMathes.items.count == 1 && regexMathes.items[0] == grammarParts[0] {
            
            // stored space
            
            let space = spaceNameAndIndexReaderWithName(grammarParts[0])
            
            if space.name != "BadGrammar" {
            
                if space.name.hasPrefix("$") {
                    
                    let spaceValue = spaceInput(text: "Sign stored space '\(space.name)' at index '\(space.index)' with a number:", screen: &screen)
                    
                    saveNumberToStoredSpace(number: [spaceValue], toSpace: space.name.replace("$", withString: ""))
                    
                    // simple space
                    
                } else {
                    let spaceValue = spaceInput(text: "Sign space '@\(space.name)' at index '\(space.index)' with a number:", screen: &screen)
                    saveToSpace(spaceName: space.name, indexAtSpace: space.index, valueToSave: spaceValue, spaces: &spaces)
                }
            
            } else {
                report("Problem with space name found.", &screen)
            }
            
        
        } else {
            spaceRegexNameError(text: grammarParts[0])
        }
        
        //
        // END OF UNTITLED INPUT
        //
        
    } else if grammarParts.count == 2 {
        
        let regexMatchForPartTwo = grammarParts[1] =~ "((\\$|\\@)[0-9a-zA-Z\\._]+)|(![a-zA-Z0-9\\._]+(\\((?:\\(.*\\)|[^\\(\\)])*\\)))"

        if regexMathes.items.count == 1 && regexMathes.items[0] == grammarParts[0] {
            
            let space = spaceNameAndIndexReaderWithName(grammarParts[0])
            
            
            //
            // INPUT
            //
            
            if ( grammarParts[1].hasPrefix("\"") && grammarParts[1].hasSuffix("\"") ) ||
               ( grammarParts[1].hasPrefix("'") && grammarParts[1].hasSuffix("'") ){
                
                var spaceInputArendelleFortmat = Arendelle(code: grammarParts[1])
                var stringSing = "\"" as Character ; if grammarParts[1].hasPrefix("'") { stringSing = "'"; }
            
                let spaceInputText = onePartOpenCloseParser(openCloseCommand: stringSing, spaces: &spaces, arendelle: &spaceInputArendelleFortmat, screen: &screen, preprocessorState:false)
                var spaceValue = spaceInput(text: spaceInputText, screen: &screen)
                
                // if it's stored space
                
                if space.name.hasPrefix("$") {
                    
                    saveNumberToStoredSpace(number: [spaceValue], toSpace: space.name.replace("$", withString: ""))
                
                // simple space
                    
                } else {
                    
                    saveToSpace(spaceName: space.name, indexAtSpace: space.index, valueToSave: spaceValue, spaces: &spaces)
                    
                }
                
                
                
                
            //
            // SHORTCUTS
            //
                
            } else if grammarParts[1].hasPrefix("+") || grammarParts[1].hasPrefix("-") || grammarParts[1].hasPrefix("/") || grammarParts[1].hasPrefix("*")    {
                
                
                //
                // SIMPLE SPACE
                //
                
                if !grammarParts[0].hasPrefix("$") {
                    
                    let result = mathEval(stringExpression: "@\(grammarParts[0])\(grammarParts[1])", screen: &screen, spaces: &spaces)

                    if result.doesItHaveErros == false && result.itsNotACondition == true {
                        
                        saveToSpace(spaceName: space.name, indexAtSpace: space.index, valueToSave: result.result, spaces: &spaces)
                    
                    } else {
                        if result.itsNotACondition == false {
                            report("Unaccepted using of conditions in space value: '\(grammarParts[1])'", &screen)
                        } else {
                            report("Bad expression: '\(grammarParts[1])'", &screen)
                        }
                    }
                   
                    
                //
                // STORED SPACE
                //
                    
                } else if grammarParts[0].hasPrefix("$") {
                    
                    if checkIfStoredSpaceExists(spaceName: space.name, screen: &screen) {
                    
                        let result = mathEval(stringExpression: "\(grammarParts[0]) \(grammarParts[1])", screen: &screen, spaces: &spaces)
           
                        if !result.doesItHaveErros && result.itsNotACondition {
 
                            saveNumberToStoredSpace(number: [result.result], toSpace: grammarParts[0].replace("$", withString: ""))
                        
                        } else {
                            
                            if result.itsNotACondition == false {
                                report("Unaccepted using of conditions in space value: '\(grammarParts[1])'", &screen)
                            } else {
                                report("Bad expression: '\(grammarParts[1])'", &screen)
                            }
                        }
                    
                    } else {
                        report("No stored space as '@\(grammarParts[0])' found", &screen)
                    }
                
                }
                
                
                
            //
            // ( space , @copyAFullSpaceToSpace )
            //
            
            } else if regexMatchForPartTwo.items.count == 1 && regexMatchForPartTwo.items[0] == grammarParts[1] {
                
                let toBeCopiedArray = spaceOverwriterWithID(grammarParts[1], &spaces, &screen)
                
                if grammarParts[0].hasPrefix("$") {
                    saveNumberToStoredSpace(number: toBeCopiedArray, toSpace: grammarParts[0].replace("$", withString: ""))
                } else {
                    spaces["@\(grammarParts[0])"] = toBeCopiedArray
                }

                
                
            //
            // ( space , 1; 1; 2; 3; 5; 8; 13; 21; 34; 55 )
            //
                
            } else if Array(grammarParts[1] =~ ";").count > 0 {
                
                if grammarParts[1].hasSuffix(";") || grammarParts[1].hasPrefix(";") || Array(grammarParts[1] =~ ";;").count > 0 {
                
                    // Empty entry counter
                    var numberOfErrors = 0; if grammarParts[1].hasSuffix(";;") { numberOfErrors++ }
                    if Array(grammarParts[1] =~ ";+").count > 0 { numberOfErrors += Array(grammarParts[1] =~ ";;").count }
                    var ies = "y"; if numberOfErrors > 1 { ies = "ies" }
                    report("Multi index space init with empty entr\(ies) found", &screen)
                
                } else {
                    
                    let array = grammarParts[1].componentsSeparatedByString(";"); var addArray:[NSNumber] = []
                    
                    for str in array {
                        let rslt = mathEval(stringExpression: str, screen: &screen, spaces: &spaces)
                        if rslt.doesItHaveErros == false {
                            if rslt.itsNotACondition == true {
                                addArray.append(rslt.result);
                            } else {
                                report("Conditional inputs are forbidden in space init ", &screen)
                            }
                        } else {
                            report("Bad expression: '\(str)'", &screen)
                        }
                    }
                    
                    
                    if grammarParts[0].hasPrefix("$") {
                        
                        saveNumberToStoredSpace(number: addArray, toSpace: grammarParts[0].replace("$", withString: ""))
                        
                    } else {
                        
                        spaces["@\(grammarParts[0])"] = addArray;
                        
                    }
                }
                
            
            
                
                
            //
            // ( space , done )
            //
                
            } else if grammarParts[1] == "done" {
                
                if grammarParts[0].hasPrefix("$") {
                
                    if checkIfStoredSpaceExists(spaceName: space.name, screen: &screen) {
                    
                        let spaceURL = arendellePathToNSURL(arendellePath: space.name.replace("$", withString: ""), kind: "space", screen: &screen)
                        
                        removeFileWithURL(spaceURL)
                        
                    } else {
                        report("No stored space as \(space.name) found to be deleted", &screen)
                    }
                
                } else {
                
                    if spaces["@\(space.name)"] != nil {
                        
                        if space.name != "return" {
                        
                            spaces.removeValueForKey("@\(space.name)")
                        
                        } else {
                            report("The @return space can not be deleted", &screen)
                        }
        
                    } else {
                        report("No space as @\(space.name) found to be deleted", &screen)
                    }
                }
            
                
                
            
            //
            // STANDARD INIT OF SPACE
            //
                
            } else {
                
                let spaceValue = mathEval(stringExpression: grammarParts[1], screen: &screen, spaces: &spaces)
                
                if spaceValue.doesItHaveErros == false {
                    
                    if spaceValue.itsNotACondition == true {
                        
                        
                        //
                        // INIT OF SPACE WITH 2 PARTS
                        //
                        
                            // if it's stored space
                        
                            if space.name.hasPrefix("$") {
                            
                                saveNumberToStoredSpace(number: [spaceValue.result], toSpace: grammarParts[0].replace("$", withString: ""))
                            
                            // simple space
                                
                            } else {
                                
                                saveToSpace(spaceName: space.name, indexAtSpace: space.index, valueToSave: spaceValue.result, spaces: &spaces)
                                spaceResult = space.name
                                
                            }
                        
                        
                        //
                        // END OF SPACE WITH 2 PARTS
                        //
                        
                    } else {
                        report("Unaccepted using of conditions in space value: '\(grammarParts[1])'", &screen)
                    }
                    
                } else {
                    report("Bad expression: '\(grammarParts[1])'", &screen)
                }
            }
        
        } else {
            spaceRegexNameError(text: grammarParts[0])
        }
    
    } else {
        report("Space grammar found with more than 2 parts", &screen)
    }
    
    --arendelle.i
    return spaceResult
}

// done


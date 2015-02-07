//
//  OpenCloseLexer.swift
//  Swifty
//
//  Created by Pouya Kary on 11/17/14.
//  Copyright (c) 2014 Arendelle Language. All rights reserved.
//

import Foundation

func openCloseLexer ( #openCommand: Character, inout #arendelle: Arendelle, inout #screen: codeScreen) -> [String] {
    
    ++arendelle.i
                        
    var command:Character
                        
    var arg:String = ""
    var args:[String] = []
    var whileControl = true
    var openCloseDictionary:[Character:Character] = [ "{":"}", "(":")", "[":"]" , "<":">", "~":":" ]
    let closeCommand = openCloseDictionary[openCommand]!
    
    while arendelle.whileCondtion() && whileControl {
        
        command = arendelle.readAtI()
                            
        switch command {
                                
        case "," :
            args.append(arg)
            arg=""

            
        case "[", "(", "{" :
                                
            let innerOpenCommand = command
            let innerCloseCommand = openCloseDictionary[innerOpenCommand]
            let newCode = openCloseLexer(openCommand: innerOpenCommand, arendelle: &arendelle, screen: &screen)
            var result:String = ""
                                
            switch newCode.count {
                                    
            case 1:
                result = newCode[0]
                                    
            case 2:
                result = newCode[0] + "," + newCode[1]
                                    
            case 3:
                result = newCode[0] + "," + newCode[1] + "," + newCode[2]
                                    
            default:
                report("Grammar with more than 3 parts", &screen)
                return["BadGrammar"]
                                    
            }
                                
            arg += String(innerOpenCommand) + result + String(innerCloseCommand!)
            --arendelle.i
                                
        case closeCommand :
            args.append(arg)
            whileControl = false
                                
        default:
            arg.append(command)
                                
        }
        
        ++arendelle.i
    }
    
    if args.count == 0 { args.append("BadGrammar") }
                        
    if whileControl == true { report ("Unfinished gramamr found", &screen) }
    
    return args

}
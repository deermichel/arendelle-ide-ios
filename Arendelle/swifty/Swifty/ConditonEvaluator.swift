//
//  ConditonEvaluator.swift
//  Swifty
//
//  Created by Pouya Kary on 11/29/14.
//  Copyright (c) 2014 Arendelle Language. All rights reserved.
//

import Foundation

/// Evaluates a condition grammar
func conditionEval (#grammarParts: [String], inout #screen: codeScreen, inout #spaces: [String:[NSNumber]], inout #arendelle: Arendelle) {

                    
    if grammarParts.count == 2 {
    
        let condtionResult =  mathEval(stringExpression: grammarParts[0], screen: &screen, spaces: &spaces)
        
        if condtionResult.itsNotACondition == false && condtionResult.result == 1 && condtionResult.doesItHaveErros == false {
        
            var conditonCode = Arendelle(code: grammarParts[1])
            let toBeRemoved = eval(&conditonCode, &screen, &spaces)
            evalSpaceRemover(spaces: &spaces, spacesToBeRemoved: toBeRemoved)
        
        }
        
    } else if grammarParts.count == 3 {
        
        let condtionResult =  mathEval(stringExpression: grammarParts[0], screen: &screen, spaces: &spaces)
        
        if condtionResult.itsNotACondition == false && condtionResult.result == 1 && condtionResult.doesItHaveErros == false {
            
            var conditonCode = Arendelle(code: grammarParts[1])
            let toBeRemoved = eval(&conditonCode, &screen, &spaces)
            evalSpaceRemover(spaces: &spaces, spacesToBeRemoved: toBeRemoved)
            
        } else {
        
            if condtionResult.itsNotACondition == false && condtionResult.result == 0 && condtionResult.doesItHaveErros == false {
                
                var conditonCode = Arendelle(code: grammarParts[2])
                let toBeRemoved = eval(&conditonCode, &screen, &spaces)
                evalSpaceRemover(spaces: &spaces, spacesToBeRemoved: toBeRemoved)
                
            } else {
                report("Bad condition expression: '\(grammarParts[0])'", &screen)
            }
        }
        
    } else {
        report("Condition with \(grammarParts.count) part\(PIEndS(number: grammarParts.count)) found", &screen)
    }
    
    arendelle.i--
}
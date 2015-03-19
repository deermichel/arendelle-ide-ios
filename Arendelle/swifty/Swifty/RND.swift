//
//  RND.swift
//  Swifty
//
//  Created by Pouya Kary on 11/28/14.
//  Copyright (c) 2014 Arendelle Language. All rights reserved.
//

import Foundation


/// creates a arendelle standard random number
func arendelleRandom () -> String {

    var r:String = ""
    switch arc4random_uniform(10) {
    
    case 1:
        return "0.0\(arc4random_uniform(10000))"
        
    default:
        return "0.\(arc4random_uniform(10000))"
    
    }
}

// done
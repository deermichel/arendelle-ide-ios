//
//  Arendelle.swift
//  Swifty
//
//  Created by Pouya Kary on 11/14/14.
//  Copyright (c) 2014 Arendelle Language. All rights reserved.
//

import Foundation



struct Arendelle {
    
    var code = ""
    var i:Int = 0
    
    
    //---------------------------------------
    init (code: String) {
        self.code = code
    }
    
    
    //---------------------------------------
    func codeSize () -> Int {
        return self.code.utf16Count
    }
    
    
    //---------------------------------------
    func read(index: Int) -> Character {
        return self.code.PiIndex(index)
    }
    
    
    //---------------------------------------
    func readAtI () -> Character {
        return self.code.PiIndex(self.i)
    }
    
    
    //---------------------------------------
    func whileCondtion () -> Bool {
        return self.i < self.codeSize()
    }
    
}









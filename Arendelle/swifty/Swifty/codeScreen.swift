//
//  codeScreen.swift
//  Swifty
//
//  Created by Pouya Kary on 11/14/14.
//  Copyright (c) 2014 Arendelle Language. All rights reserved.
//

import Foundation

func report(text: String, inout screen: codeScreen) {

    screen.errors.append("\(screen.funcName): \(text)")

}


struct codeScreen {
    
    //--- Init ---------------------------------------------
    init (xsize:Int, ysize: Int) {
        
        self.screen = PIArray2D (cols: xsize, rows: ysize)
        
    }
    
    //--- Screen -------------------------------------------
    var screen = PIArray2D (cols: 10, rows: 10)
    
    
    //--- MainPath -----------------------------------------
    var mainPath = "."
    
    
    //--- Title --------------------------------------------
    var title:String = "Arendelle"
    
    
    //--- Stop ---------------------------------------------
    var stop = false
    
    //--- Func Name ----------------------------------------
    var funcName = "main"
    
    //--- Errors -------------------------------------------
    var errors:[String] = []
    
    //--- Ordinations --------------------------------------
    var x = 0
    var y = 0
    var z = 0
    
    //--- Rest ---------------------------------------------
    var n = 1
    var whileSign = true
    
}

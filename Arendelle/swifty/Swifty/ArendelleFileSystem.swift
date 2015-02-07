//
//  ArendelleFileSystem.swift
//  Swifty
//
//  Created by Pouya Kary on 12/26/14.
//  Copyright (c) 2014 Arendelle Language. All rights reserved.
//

import Foundation


func arendellePathToNSURL (#arendellePath: String, #kind: String, inout #screen: codeScreen) -> NSURL {
    
    let dotToSlash = arendellePath.replace(".", withString: "/")
    
    let pathString = "\(screen.mainPath)/\(dotToSlash).\(kind)"
    return NSURL(fileURLWithPath: pathString)!
}


func checkIfURLExists (URL:NSURL) -> Bool {

    let fileManager = NSFileManager();
    return fileManager.fileExistsAtPath(URL.path!)

}


func removeFileWithURL (URL:NSURL) {

    let fileManager = NSFileManager();
    if fileManager.fileExistsAtPath(URL.path!) {
        fileManager.removeItemAtURL(URL, error: nil)
    }
}


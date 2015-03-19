//
//  ArendelleFileSystem.swift
//  Swifty
//
//  Created by Pouya Kary on 12/26/14.
//  Copyright (c) 2014 Arendelle Language. All rights reserved.
//

import Foundation

func storedSpaceFolderChecker (url: NSURL, mainPath: String) {
    
    let spaceName  = url.path! =~ "/[a-zA-Z0-9_]+\\.space"
    let stringPath = url.path!.removeFromEnd(spaceName.items[0])
    
    // File manager
    var fileManager = NSFileManager.defaultManager()
    
    if !fileManager.fileExistsAtPath(stringPath) {
        
        // Parts of our path
        var urlParts = stringPath.componentsSeparatedByString("/")
        
        // Where we keep where we are
        var currentFolder = "";
        
        // We check each level of folders
        for part in urlParts {
            
            if !fileManager.fileExistsAtPath("\(currentFolder)/\(part)") {
                
                fileManager.createDirectoryAtPath("\(currentFolder)/\(part)", withIntermediateDirectories: false, attributes: nil, error: nil)
                
            }
            
            currentFolder = "\(currentFolder)/\(part)"
        }
    }
}

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

func checkToSeeIfItsANeedToCreateFoldersForStoredSpaceSaverWithURL (url: NSURL) {

    if !checkIfURLExists(url) {
        
        var urlparts = url.path;
    
    }
}


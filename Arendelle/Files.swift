//
//  Files.swift
//  Arendelle
//
//  Created by mh on 01/01/15.
//  Copyright (c) 2015 Arendelle Project. All rights reserved.
//

import Foundation

// file operations
class Files {
    
    // get Documents directory
    class func getDocsDir() -> String {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as String
        
        return docsDir
    }
    
    // reads text from a given file
    class func read(file: String) -> String {
        
        let fileManager = NSFileManager.defaultManager()
        var data: NSData?
        data = fileManager.contentsAtPath(file)
        
        return NSString(data: data!, encoding: NSUTF8StringEncoding)!
    }
    
    // writes text to the given file
    class func write(file: String, text: String) {
        
        let data = text.dataUsingEncoding(NSUTF8StringEncoding)
        data!.writeToFile(file, atomically: true)
        
    }
    
    // parses a given config file
    class func parseConfigFile(file: String) -> Dictionary<String, String> {
        
        var properties = [String: String]()
        let fileContent = read(file)
        var lines = fileContent.componentsSeparatedByString("\n")
        var property: [String]
        for line in lines {
            if line != "" {
                property = line.componentsSeparatedByString("=")
                properties[property[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())] = property[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
        }
        
        return properties
    }
    
    // creates a config file with the given properties
    class func createConfigFile(file: String, properties: Dictionary<String, String>) {
        
        var fileContent: String = ""
        for (key, value) in properties {
            fileContent += key + "=" + value + "\n";
        }
        write(file, text: fileContent)
        
    }
    
    // saves an image to the given file
    class func saveImage(file: String, image: Int) {
        
        // TODO: write method
        
    }
    
    // gets all files of a folder and its subfolders
    class func getFiles(folder: String) -> [String] {
        
        let fileManager = NSFileManager.defaultManager()
        var files: [String] = []
        let filelist = fileManager.contentsOfDirectoryAtPath(folder, error: nil)
        for file in filelist! {
            let name = file as String
            var isDir: ObjCBool = false
            fileManager.fileExistsAtPath(folder.stringByAppendingPathComponent(name), isDirectory: &isDir)
            if name[name.startIndex] != "." {
                if isDir {
                    files.extend(self.getFiles(folder.stringByAppendingPathComponent(name)))
                } else {
                    files.append(folder.stringByAppendingPathComponent(name))
                }
            }
        }
        
        return files
    }
    
    // gets relative path
    class func getRelativePath(root: String, path: String) -> String {
        return path.substringFromIndex((root + "/").endIndex)
    }
    
    // deletes a file or folder
    class func delete(file: String) {
        
        let fileManager = NSFileManager.defaultManager()
        fileManager.removeItemAtPath(file, error: nil)
        
    }
    
}
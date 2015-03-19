//
//  PI.swift
//  THE PI FRAMEWORK: A SET OF TOOLS SWIFT NEEDS
//
//  Created by Pouya Kary on 11/17/14.
//  Copyright (c) 2014 Pouya Kary and other contribiuters. All rights reserved.
//

import Foundation

////////////////////
/// STRING TOOLS ///
////////////////////

/// Returns an S for plural words
func PIEndS (#number: Int) -> String {
    if number > 1 {
        return "s"
    } else {
        return ""
    }
}


/* --------------------------------------------------------------------------- *
 * :::::::::::::::::::::::::: R E G E X   T O O L S :::::::::::::::::::::::::: *
 * --------------------------------------------------------------------------- */


/// PI 2D Array
class PIArray2D {
    var cols:Int, rows:Int
    var matrix:[Int]
    
    /// Array init
    init(cols:Int, rows:Int) {
        self.cols = cols
        self.rows = rows
        matrix = Array(count:cols*rows, repeatedValue:0)
    }
    
    subscript(col:Int, row:Int) -> Int {
        get {
            return matrix[cols * row + col]
        }
        set {
            matrix[cols*row+col] = newValue
        }
    }
    
    /// Returns the number of the array columns
    func colCount() -> Int {
        return self.cols
    }
    
    /// Returns the number of the array rows
    func rowCount() -> Int {
        return self.rows
    }
}

/// Regex Facilities
infix operator =~ {}

func =~ (value : String, pattern : String) -> RegexMatchResult {
    var err : NSError?
    let nsstr = value as NSString // we use this to access the NSString methods like .length and .substringWithRange(NSRange)
    let options = NSRegularExpressionOptions(0)
    let re = NSRegularExpression(pattern: pattern, options: options, error: &err)
    if let e = err {
        return RegexMatchResult(items: [])
    }
    let all = NSRange(location: 0, length: nsstr.length)
    let moptions = NSMatchingOptions(0)
    var matches : Array<String> = []
    re!.enumerateMatchesInString(value, options: moptions, range: all) {
        (result : NSTextCheckingResult!, flags : NSMatchingFlags, ptr : UnsafeMutablePointer<ObjCBool>) in
        let string = nsstr.substringWithRange(result.range)
        matches.append(string)
    }
    return RegexMatchResult(items: matches)
}

struct RegexMatchCaptureGenerator : GeneratorType {
    mutating func next() -> String? {
        if items.isEmpty { return nil }
        let ret = items[0]
        items = items[1..<items.count]
        return ret
    }
    var items: Slice<String>
}

struct RegexMatchResult : SequenceType, BooleanType {
    var items: Array<String>
    func generate() -> RegexMatchCaptureGenerator {
        return RegexMatchCaptureGenerator(items: items[0..<items.count])
    }
    var boolValue: Bool {
        return items.count > 0
    }
    subscript (i: Int) -> String {
        return items[i]
    }
}




/* --------------------------------------------------------------------------- *
 * ::::::::::::::::::::::::::: E X T E N S I O N S ::::::::::::::::::::::::::: *
 * --------------------------------------------------------------------------- */


extension Character
{
    func toString () -> String {
    
        var text:String = ""
        text.append(self)
        return text
    
    }
}

extension String
{
    func PiIndex (theEndIndex: Int) -> Character {
            let index = advance(startIndex, theEndIndex)
            return self[index]
    }
    
    /// removes a part of the string from
    /// start of a string unless there is
    /// no text in the start of the string
    func removeFromStart(text: String) -> String {
    
        if self.hasPrefix(text) {
        
            return self[text.utf16Count...self.utf16Count - 1]
        
        } else {
            return self
        }
    }
    
    func removeFromEnd(text: String) -> String {
        
        if self.hasSuffix(text) {
            
            return self[0...self.utf16Count - text.utf16Count - 1 ]
            
        } else {
            return self
        }
    }
    
    /// Converts string to Int
    func toInt () -> Int {
        return Int(NSInteger(NSString(string: self).integerValue))
    }
    
    /// Converts string to Float
    func toFloat () -> Float {
        return Float(NSInteger(NSString(string: self).floatValue))
    }
    
    /// Converts string to Double
    func toDouble () -> Double {
        return Double(NSInteger(NSString(string: self).doubleValue))
    }

    /// Converts string to Int
    func characterAtIndex(index:Int) -> unichar
    {
        return self.utf16[index]
    }
    
    // String[Index] notation
    subscript(index:Int) -> unichar
    {
        return characterAtIndex(index)
    }
    
    
    // MARK: - sub String
    func substringToIndex(index:Int) -> String {
        return self.substringToIndex(advance(self.startIndex, index))
    }
    
    func substringFromIndex(index:Int) -> String {
        return self.substringFromIndex(advance(self.startIndex, index))
    }
    
    func substringWithRange(range:Range<Int>) -> String {
        let start = advance(self.startIndex, range.startIndex)
        let end = advance(self.startIndex, range.endIndex)
        return self.substringWithRange(start..<end)
    }
    
    /* subscript(index:Int) -> Character{
        return self[advance(self.startIndex, index)]
    } */
    
    subscript(range:Range<Int>) -> String {
        let start = advance(self.startIndex, range.startIndex)
        let end = advance(self.startIndex, range.endIndex)
        return self[start..<end]
    }

    
    // MARK: - replace
    func replaceCharactersInRange(range: Range<Int>,  withString: String!) -> String {
                                
        var result:NSMutableString = NSMutableString(string: self)
        result.replaceCharactersInRange(NSRange(range), withString: withString)
        return result
    }
    
    func replace(target: String, withString: String) -> String {
                
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}

// done

//
//  ScreenViewController.swift
//  Arendelle
//
//  Created by mh on 21.01.15.
//  Copyright (c) 2015 Arendelle Project. All rights reserved.
//

import UIKit

class ScreenViewController: UIViewController {
    
    var code: String = ""
    var projectFolder: String = ""
    var configFile: String = ""
    var gridWidth: Int = 0
    var gridHeight: Int = 0
    var cellWidth: Int = 0
    var cellHeight: Int = 0
    var showErrorsDialog = true
    var colorPalette: [UIColor] = []
    var evaluating = false
    
    // Arendelles screen
    var screen: codeScreen?
    
    // gui objects
    @IBOutlet weak var imageResult: UIImageView!
    @IBOutlet weak var textChronometer: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // add bar buttons
        var buttonStop = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "actionStop:")
        var buttonShare = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "actionShare:")
        self.navigationItem.rightBarButtonItems = [buttonStop, buttonShare]
        
        // set title
        self.title = projectFolder.lastPathComponent
        
        // helper function: creates an UIColor from a hex string
        func colorWithHexString(hex:String) -> UIColor {
            var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
            var rString = cString.substringToIndex(2)
            var gString = cString.substringFromIndex(2).substringToIndex(2)
            var bString = cString.substringFromIndex(4).substringToIndex(2)
            var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
            NSScanner(string: rString).scanHexInt(&r)
            NSScanner(string: gString).scanHexInt(&g)
            NSScanner(string: bString).scanHexInt(&b)
            return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
        }
        
        // get color palette
        let properties = Files.parseConfigFile(configFile)
        colorPalette.append(colorWithHexString(properties["colorBackground"]!))
        colorPalette.append(colorWithHexString(properties["colorFirst"]!))
        colorPalette.append(colorWithHexString(properties["colorSecond"]!))
        colorPalette.append(colorWithHexString(properties["colorThird"]!))
        colorPalette.append(colorWithHexString(properties["colorFourth"]!))
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // set cell and grid size
        cellWidth = Int(10.0 * UIScreen.mainScreen().scale)
        cellHeight = Int(10.0 * UIScreen.mainScreen().scale)
        gridWidth = Int(imageResult.frame.size.width) / cellWidth
        gridHeight = Int(imageResult.frame.size.height) / cellHeight
        
        // reevaluate the code
        evaluate()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // evaluates the code
    func evaluate() {
        
        // reset screen
        textChronometer.text = ""
        
        // evaluate
        evaluating = true
        screen = codeScreen(xsize: gridWidth, ysize: gridHeight)
        screen!.title = projectFolder.lastPathComponent
        
        // eval thread
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            // work
            let timestamp = NSDate.timeIntervalSinceReferenceDate()
            masterEvaluator(code: self.code, screen: &self.screen!)
            self.evaluating = false
            let elapsedTime = NSDate.timeIntervalSinceReferenceDate() - timestamp
            
            // update UI
            dispatch_async(dispatch_get_main_queue()) {
                
                // chronometer
                self.textChronometer.text = "\(elapsedTime * 1000) ms"
                
                // TODO: get errors via screen.errors
                
                // switch to reeval button
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "actionRefresh:")
                
            }
            
        }
        
        // update thread
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            var run = true
            while (run) {
                
                // work
                var result = self.draw()
                
                // update UI
                dispatch_async(dispatch_get_main_queue()) {
                    
                    // update screen
                    self.imageResult.image = result
                    self.imageResult.setNeedsDisplay()
                    self.title = self.screen!.title
                    
                    run = self.evaluating
                }
                
            }
            
        }
        
        // TODO: create preview image
        /*size = CGSize(width: 5 * cellWidth, height: 5 * cellHeight)
        UIGraphicsBeginImageContext(size)
        context = UIGraphicsGetCurrentContext()
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))
        for x in 0..<5 {
            for y in 0..<5 {
                switch screen!.screen[x,y] {
                    
                case 1:
                    CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
                    
                case 2:
                    CGContextSetFillColorWithColor(context, UIColor.lightGrayColor().CGColor)
                    
                case 3:
                    CGContextSetFillColorWithColor(context, UIColor.grayColor().CGColor)
                    
                case 4:
                    CGContextSetFillColorWithColor(context, UIColor.darkGrayColor().CGColor)
                    
                default:
                    CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
                    
                }
                
                CGContextFillRect(context, CGRectMake(CGFloat(x * cellWidth), CGFloat(y * cellHeight), CGFloat(cellWidth), CGFloat(cellHeight)))
            }
        }
        result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // save preview image
        UIImagePNGRepresentation(result).writeToFile(projectFolder.stringByAppendingPathComponent(".preview.png"), atomically: true)*/
        
    }
    
    func actionStop(sender: AnyObject) {
        
        // stop evaluating
        if (evaluating) {
            screen!.stop = true
        }

        // switch to reeval button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "actionRefresh:")
        
    }
    
    func actionRefresh(sender: AnyObject) {
        
        // reevaluate
        showErrorsDialog = true
        evaluate()
        
        // switch to stop button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "actionStop:")
        
    }
    
    // draws result
    func draw() -> UIImage {
        
        var size = CGSize(width: gridWidth * cellWidth, height: gridHeight * cellHeight)
        UIGraphicsBeginImageContext(size)
        var context = UIGraphicsGetCurrentContext()
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))
        for x in 0..<screen!.screen.colCount() {
            for y in 0..<screen!.screen.rowCount() {
                switch screen!.screen[x,y] {
                    
                case 1:
                    CGContextSetFillColorWithColor(context, colorPalette[1].CGColor)
                    
                case 2:
                    CGContextSetFillColorWithColor(context, colorPalette[2].CGColor)
                    
                case 3:
                    CGContextSetFillColorWithColor(context, colorPalette[3].CGColor)
                    
                case 4:
                    CGContextSetFillColorWithColor(context, colorPalette[4].CGColor)
                    
                default:
                    CGContextSetFillColorWithColor(context, colorPalette[0].CGColor)
                    
                }
                
                CGContextFillRect(context, CGRectMake(CGFloat(x * cellWidth), CGFloat(y * cellHeight), CGFloat(cellWidth), CGFloat(cellHeight)))
            }
        }
        var result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // stop evaluating
        if (evaluating) {
            screen!.stop = true
        }
        
    }
    
    func actionShare(sender: AnyObject) {
        
        let objectsToShare = [imageResult.image!]
        let activity = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activity.popoverPresentationController?.barButtonItem = sender as UIBarButtonItem
        self.presentViewController(activity, animated: true, completion: nil)
        
    }
    
}

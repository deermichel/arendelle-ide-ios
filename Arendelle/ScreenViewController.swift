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
    var errorDialogJustClosed = false
    
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
        
        // get color palette
        let properties = Files.parseConfigFile(configFile)
        colorPalette.append(colorWithHexString(properties["colorBackground"]!))
        colorPalette.append(colorWithHexString(properties["colorFirst"]!))
        colorPalette.append(colorWithHexString(properties["colorSecond"]!))
        colorPalette.append(colorWithHexString(properties["colorThird"]!))
        colorPalette.append(colorWithHexString(properties["colorFourth"]!))
        
    }
    
    // helper function: creates an UIColor from a hex string
    private func colorWithHexString(hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString.substringFromIndex(1)
        var rString = cString.substringToIndex(2)
        var gString = cString.substringFromIndex(2).substringToIndex(2)
        var bString = cString.substringFromIndex(4).substringToIndex(2)
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // set cell and grid size
        cellWidth = Int(10.0 * UIScreen.mainScreen().scale)
        cellHeight = Int(10.0 * UIScreen.mainScreen().scale)
        gridWidth = Int(imageResult.frame.size.width) / cellWidth
        gridHeight = Int(imageResult.frame.size.height) / cellHeight
        
        // reevaluate the code
        if (!errorDialogJustClosed) {
            evaluate()
        } else {
            errorDialogJustClosed = false
        }
        
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
        screen!.mainPath = projectFolder
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
                
                // show errors
                if self.screen!.errors.count > 0 {
                    self.performSegueWithIdentifier("showErrors", sender: self)
                }
                
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
            
            // create preview image
            let size = CGSize(width: self.screen!.screen.colCount() * self.cellWidth, height: 5 * self.cellHeight)
            UIGraphicsBeginImageContext(size)
            let context = UIGraphicsGetCurrentContext()
            CGContextSetFillColorWithColor(context, self.colorWithHexString("#FFFFFF").CGColor)
            CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))
            CGContextSetAlpha(context, 0.1)
            for x in 0..<self.screen!.screen.colCount() {
                for y in 0..<5 {
                    switch self.screen!.screen[x,y] {
                        
                    case 1:
                        CGContextSetFillColorWithColor(context, self.colorWithHexString("#CECECE").CGColor)
                        
                    case 2:
                        CGContextSetFillColorWithColor(context, self.colorWithHexString("#8C8A8C").CGColor)
                        
                    case 3:
                        CGContextSetFillColorWithColor(context, self.colorWithHexString("#424542").CGColor)
                        
                    case 4:
                        CGContextSetFillColorWithColor(context, self.colorWithHexString("#000000").CGColor)
                        
                    default:
                        CGContextSetFillColorWithColor(context, self.colorWithHexString("#FFFFFF").CGColor)
                        
                    }
                    
                    CGContextFillRect(context, CGRectMake(CGFloat(x * self.cellWidth), CGFloat(y * self.cellHeight), CGFloat(self.cellWidth), CGFloat(self.cellHeight)))
                }
            }
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // save preview image
            UIImagePNGRepresentation(result).writeToFile(self.projectFolder.stringByAppendingPathComponent(".preview.png"), atomically: true)
            
        }
        
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
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showErrors" {
            errorDialogJustClosed = true
            let controller = segue.destinationViewController as ErrorsViewController
            controller.errors = screen!.errors
        }
        
    }
    
}

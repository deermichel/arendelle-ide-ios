//
//  DetailViewController.swift
//  Arendelle
//
//  Created by mh on 01/01/15.
//  Copyright (c) 2015 Arendelle Project. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var configFile: String = ""
    var projectFolder: String = ""
    var file: String = ""
    
    // gui objects
    @IBOutlet weak var textCode: UITextView!
    

    // update view
    func updateView() {
        
        if file != "" {
            self.navigationItem.title = file.lastPathComponent.componentsSeparatedByString(".arendelle")[0]
            textCode.text = Files.read(file)
            view.userInteractionEnabled = true
        } else {
            textCode.text = ""
            view.userInteractionEnabled = false
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.updateView()
        
        // register keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        // setup shortkey toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        func getToolbarButtons() -> [UIBarButtonItem] {
            
            var buttons: [UIBarButtonItem] = []
            var titles: [String] = ["[", ",", "]", "(", ")", "{", "}", "@", "#", "TAB", "/", "=", "-", "+", "*", "!", "?", "$", "&", "^", "%", "<", ">", "'", "\"", "\\"]
            
            for title in titles {
                var button = UIBarButtonItem(title: title, style: .Plain, target: self, action: "toolbarKeyPressed:")
                button.width = 40
                buttons.append(button)
            }
            
            return buttons
        }
        
        var buttons = getToolbarButtons()
        
        var scrollView = UIScrollView()
        scrollView.frame = toolbar.frame
        scrollView.bounds = toolbar.bounds
        scrollView.autoresizingMask = toolbar.autoresizingMask
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        
        toolbar.autoresizingMask = UIViewAutoresizing.None
        toolbar.frame = CGRectMake(0, 0, CGFloat((buttons.count + 7) * 40), toolbar.frame.size.height)
        toolbar.bounds = toolbar.frame
        toolbar.setItems(buttons, animated: false)
        
        scrollView.contentSize = toolbar.frame.size
        scrollView.addSubview(toolbar)
        
        textCode.inputAccessoryView = scrollView
        
        // setup textview
        textCode.userInteractionEnabled = true
        
    }
    
    func toolbarKeyPressed(sender: AnyObject) {
        
        // shortkey button handler
        if let key = sender as? UIBarButtonItem {
            
            // insert text into code
            if (key.title! == "TAB") {
                textCode.replaceRange(textCode.selectedTextRange!, withText: "   ")
            } else {
                textCode.replaceRange(textCode.selectedTextRange!, withText: key.title!)
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // save code if file exists
        if NSFileManager.defaultManager().fileExistsAtPath(file) {
            Files.write(file, text: textCode.text)
        }
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        // get keyboard frame
        let keyboardFrameValue = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue
        let keyboardFrame = keyboardFrameValue.CGRectValue()
        
        // resize textview
        var contentInsets = textCode.contentInset
        contentInsets.bottom = CGRectGetHeight(keyboardFrame)
        textCode.contentInset = contentInsets
        textCode.scrollIndicatorInsets = contentInsets
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        // resize textview
        var contentInsets = textCode.contentInset
        contentInsets.bottom = 0
        textCode.contentInset = contentInsets
        textCode.scrollIndicatorInsets = contentInsets
        
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "show" {
            
            if file != "" {
                /*let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
                controller.file = file
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true*/
                
                // save code
                Files.write(file, text: textCode.text)
                
                let controller = segue.destinationViewController as ScreenViewController
                let mainFunction = projectFolder.stringByAppendingPathComponent(Files.parseConfigFile(configFile)["mainFunction"]!)
                controller.code = Files.read(mainFunction)
                controller.configFile = configFile
                controller.projectFolder = projectFolder
                
            }
            
        }
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        if file != "" {
            return true
        } else {
            return false
        }
        
    }

}


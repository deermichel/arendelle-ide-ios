//
//  WebviewViewController.swift
//  Arendelle
//
//  Created by mh on 21.02.15.
//  Copyright (c) 2015 Arendelle Project. All rights reserved.
//

import UIKit

class WebviewViewController: UIViewController {
    
    var html: String = ""
    
    // gui objects
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationBar.topItem?.title = self.title
        webView.loadRequest(NSURLRequest(URL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(html, ofType: "html")!, isDirectory: false)!))
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func actionOK(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
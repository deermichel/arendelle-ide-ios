//
//  ErrorsViewController.swift
//  Arendelle
//
//  Created by mh on 20.02.15.
//  Copyright (c) 2015 Arendelle Project. All rights reserved.
//

import UIKit

class ErrorsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var errors: [String] = []
    
    // gui objects
    @IBOutlet weak var errorsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        errorsTableView.dataSource = self
        errorsTableView.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func actionOK(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return errors.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = errors[indexPath.row]
        var icon = ion_ios_bolt_outline
        let error = errors[indexPath.row].lowercaseString
        
        // choose icon
        if error.rangeOfString("unknown command") != nil {
            icon = ion_ios_help_empty
        } else if error.rangeOfString("bad expression") != nil {
            //icon = ion_ios_bolt_outline
        } else if error.rangeOfString("function") != nil {
            icon = ion_ios_flask_outline
        } else if error.rangeOfString("space") != nil {
            icon = ion_ios_medical_outline
        } else if error.rangeOfString("loop") != nil {
            icon = ion_ios_infinite_outline
        } else if error.rangeOfString("condition") != nil {
            icon = ion_ios_shuffle
        } else if error.rangeOfString("zone") != nil {
            icon = ion_ios_close_empty
        }
        
        cell.imageView!.image = IonIcons.imageWithIcon(icon, iconColor: UIColor(red: 230.0/255.0, green: 1.0/255.0, blue: 132.0/255.0, alpha: 1.0), iconSize: 30, imageSize: CGSize(width: 30, height: 30))
        
        return cell
    }
    
}
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
        
        return cell
    }
    
}
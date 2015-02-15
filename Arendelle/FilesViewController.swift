//
//  FilesViewController.swift
//  Arendelle
//
//  Created by mh on 13.01.15.
//  Copyright (c) 2015 Arendelle Project. All rights reserved.
//

import UIKit

class FilesViewController: UITableViewController {
    
    var projectName: String = ""
    var projectFolder: String = ""
    var configFile: String = ""
    var currentFunction: String = ""
    var mainFunction: String = ""
    var fileList: [String] = []
    var optionsList: [String] = ["Add Function", "Project Settings"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        //self.navigationItem.rightBarButtonItem = addButton
        self.title = projectName
        
        // TODO: migrating from Android
        
        // get files
        let fileManager = NSFileManager.defaultManager()
        projectFolder = Files.getDocsDir().stringByAppendingPathComponent(projectName)
        configFile = projectFolder.stringByAppendingPathComponent("project.config")
        mainFunction = projectFolder.stringByAppendingPathComponent(Files.parseConfigFile(configFile)["mainFunction"]!)
        currentFunction = projectFolder.stringByAppendingPathComponent(Files.parseConfigFile(configFile)["currentFunction"]!)
        let filelist = Files.getFiles(projectFolder)
        let indexPath = NSIndexPath(forRow: 0, inSection: 1)
        for file in filelist {
            if file.rangeOfString(".arendelle") != nil {
                let name = Files.getRelativePath(projectFolder, path: file).componentsSeparatedByString(".arendelle")[0].stringByReplacingOccurrencesOfString("/", withString: ".", options: .LiteralSearch, range: nil)
                self.fileList.append(name)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
        
        // open last edited function
        performSegueWithIdentifier("showDetail", sender: self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let file = projectFolder.stringByAppendingPathComponent(fileList[indexPath.row].stringByReplacingOccurrencesOfString(".", withString: "/", options: .LiteralSearch, range: nil) + ".arendelle")
                let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
                controller.file = file
                controller.projectFolder = projectFolder
                controller.configFile = configFile
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                // save as current function
                if file != currentFunction {
                    var properties = Files.parseConfigFile(configFile)
                    properties["currentFunction"] = Files.getRelativePath(projectFolder, path: file)
                    Files.createConfigFile(configFile, properties: properties)
                }
                
            } else {
                let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
                controller.file = currentFunction
                controller.projectFolder = projectFolder
                controller.configFile = configFile
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
            
        } else if segue.identifier == "showSettings" {
            
            //let controller = (segue.destinationViewController as UINavigationController).topViewController as SettingsViewController
            let controller = segue.destinationViewController as SettingsViewController
            controller.projectFolder = projectFolder
            controller.configFile = configFile
            //controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
            
        }
        
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            return optionsList.count
        default:
            return fileList.count
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
        case 0:
            return "Options"
        default:
            return "Functions"
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        switch (indexPath.section) {
        case 0:
            cell.textLabel!.text = optionsList[indexPath.row]
        default:
            cell.textLabel!.text = fileList[indexPath.row]
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        // option selected
        if (indexPath.section == 0) {
            switch (indexPath.row) {
            case 0:
                showNewFunctionDialog()
                return nil
            case 1:
                performSegueWithIdentifier("showSettings", sender: self)
                return nil
            default:
                break
            }
        }
        
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // remove highlight color
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    // shows dialog for new function
    func showNewFunctionDialog() {
        
        var alert = UIAlertController(title: "New function", message: "Enter a name for the new function.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            let textName = alert.textFields![0] as UITextField
            self.newFunction(textName.text)
        }))
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Name"
        })
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // creates a new function
    func newFunction(functionName: String) {
        
        var function: String
        
        if functionName.componentsSeparatedByString(".").count > 1 {
            
            // really needed here
            func getFoldersPath() -> String {
                let elements = functionName.componentsSeparatedByString(".")
                var foldersPath = ""
                for i in 0..<elements.count - 1 {
                    foldersPath += elements[i] + "/"
                }
                foldersPath.removeAtIndex(advance(foldersPath.endIndex, -1))
                return foldersPath
            }
            
            // create folders for namespaces
            var foldersPath = getFoldersPath()
            let fileManager = NSFileManager.defaultManager()
            let folders = projectFolder.stringByAppendingPathComponent(foldersPath)
            fileManager.createDirectoryAtPath(folders, withIntermediateDirectories: true, attributes: nil, error: nil)
            
            // create function file
            function = folders.stringByAppendingPathComponent(functionName.componentsSeparatedByString(".")[functionName.componentsSeparatedByString(".").count - 1] + ".arendelle")
            
        } else {
            
            // create function file
            function = projectFolder.stringByAppendingPathComponent(functionName + ".arendelle")
            
        }
        
        // create file
        Files.write(function, text: "")
        
        // add to file list
        let indexPath = NSIndexPath(forRow: fileList.count, inSection: 1)
        self.fileList.append(functionName)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        // open file
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        performSegueWithIdentifier("showDetail", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // close editor keyboard
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            let detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
            detailViewController?.view.endEditing(true)
        }
        
    }
    
}

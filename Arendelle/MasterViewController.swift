//
//  MasterViewController.swift
//  Arendelle
//
//  Created by mh on 01/01/15.
//  Copyright (c) 2015 Arendelle Project. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var projectList: [String] = []


    override func awakeFromNib() {
        super.awakeFromNib()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        // fill project list
        let fileManager = NSFileManager.defaultManager()
        let docsDir = Files.getDocsDir()
        println(docsDir)
        let filelist = fileManager.contentsOfDirectoryAtPath(docsDir, error: nil)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        for file in filelist! {
            let name = file as String
            var isDir: ObjCBool = false
            fileManager.fileExistsAtPath(docsDir.stringByAppendingPathComponent(name), isDirectory: &isDir)
            if isDir && name[name.startIndex] != "." {
                self.projectList.append(name)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
        
    }

    func insertNewObject(sender: AnyObject) {
        
        // show dialog for new Arendelle project
        var alert = UIAlertController(title: "New project", message: "Enter a name and a name for the main function to create a new Arendelle project.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            let textName = alert.textFields![0] as UITextField
            let textMainFunctionName = alert.textFields![1] as UITextField
            self.newProject(textName.text, mainFunctionName: textMainFunctionName.text)
        }))
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Name"
        })
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Name of main function"
        })
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "show" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let project = projectList[indexPath.row]
                let controller = segue.destinationViewController as FilesViewController
                controller.projectName = project
            }
            
        }
        
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let project = projectList[indexPath.row]
        cell.textLabel!.text = project
        /*if let preview = UIImage(contentsOfFile: Files.getDocsDir().stringByAppendingPathComponent(project).stringByAppendingPathComponent(".preview.png")) {
            cell.imageView!.image = preview
        }*/
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // remove highlight color
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // delete project
            let project = projectList[indexPath.row]
            Files.delete(Files.getDocsDir().stringByAppendingPathComponent(project))
            projectList.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // create new Arendelle project
    func newProject(projectName: String, mainFunctionName: String) {
        
        // create project folder
        let fileManager = NSFileManager.defaultManager()
        let docsDir = Files.getDocsDir()
        let projectFolder = docsDir.stringByAppendingPathComponent(projectName)
        fileManager.createDirectoryAtPath(projectFolder, withIntermediateDirectories: true, attributes: nil, error: nil)

        // create default config file
        var properties = [String: String]()
        properties["mainFunction"] = mainFunctionName + ".arendelle"
        properties["currentFunction"] = properties["mainFunction"]
        properties["colorPalette"] = "0"
        properties["colorBackground"] = "000000"
        properties["colorFirst"] = "FFFFFF"
        properties["colorSecond"] = "CECECE"
        properties["colorThird"] = "8C8A8C"
        properties["colorFourth"] = "424542"
        Files.createConfigFile(projectFolder.stringByAppendingPathComponent("project.config"), properties: properties)
        
        // create main function
        Files.write(projectFolder.stringByAppendingPathComponent(mainFunctionName + ".arendelle"), text: "")
        
        // TODO: create preview image
        /*var size = CGSize(width: 0, height: 0)
        UIGraphicsBeginImageContext(size)
        var context = UIGraphicsGetCurrentContext()
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))
        var result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImagePNGRepresentation(result).writeToFile(projectFolder.stringByAppendingPathComponent(".preview.png"), atomically: true)*/
        
        // add to project list
        self.setEditing(false, animated: true)
        let indexPath = NSIndexPath(forRow: projectList.count, inSection: 0)
        self.projectList.append(projectName)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        // open project
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        performSegueWithIdentifier("show", sender: self)
        
    }

}


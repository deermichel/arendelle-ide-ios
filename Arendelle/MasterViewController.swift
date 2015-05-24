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
        //let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        let moreIcon = IonIcons.imageWithIcon(ion_ios_more,
            iconColor: UIColor(red: 230.0/255.0, green: 1.0/255.0, blue: 132.0/255.0, alpha: 1.0),
            iconSize: 32,
            imageSize: CGSize(width: 22, height: 22))
        let moreButton = UIBarButtonItem(image: moreIcon, style: .Plain, target: self, action: "actionMore:")
        self.navigationItem.rightBarButtonItem = moreButton
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
            split.preferredDisplayMode = UISplitViewControllerDisplayMode.Automatic
        }
        
        // first start 1/2
        let prefs = NSUserDefaults.standardUserDefaults()
        if !prefs.boolForKey("firstStart") {
            
            // create example projects
            createExampleProjects()
            
        }
        
        // fill project list
        let fileManager = NSFileManager.defaultManager()
        let docsDir = Files.getDocsDir()
        //println(docsDir)
        let filelist = fileManager.contentsOfDirectoryAtPath(docsDir, error: nil)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        for file in filelist! {
            let name = file as! String
            var isDir: ObjCBool = false
            fileManager.fileExistsAtPath(docsDir.stringByAppendingPathComponent(name), isDirectory: &isDir)
            if isDir && name[name.startIndex] != "." {
                self.projectList.append(name)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
        
        // if not touched so far -> setup book button footer
        if prefs.boolForKey("hideBookButton") {
            return
        }
        
        // create preview image if necessary
        let bookButtonPreview = Files.getDocsDir().stringByAppendingPathComponent(".bookButtonPreview.png")
        if !NSFileManager.defaultManager().fileExistsAtPath(bookButtonPreview) {
            UIImagePNGRepresentation(createPreviewImage("nn[ #i / 3 + 1 , [ 2 , prd ] [ 3 , pld ] [ 5 , u ] [ 4 , r ] nnn { #n = 3 , nnn } ] id [ #i / 2 - 7 , r ] [ 3 , [ 14 , cr ] [ 14 , l ] d ]")).writeToFile((bookButtonPreview), atomically: true)
        }
        
        // add footer
        let footer = UIView(frame: CGRectMake(0, 0, self.view.bounds.size.width, 100))
        let label = UILabel(frame: footer.frame)
        footer.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        label.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        label.text = "Learn Arendelle"
        label.font = UIFont.boldSystemFontOfSize(25)
        label.textAlignment = NSTextAlignment.Center
        footer.addSubview(label)
        footer.backgroundColor = UIColor(patternImage: UIImage(contentsOfFile: bookButtonPreview)!)
        let button = UIButton(frame: footer.frame)
        button.opaque = true
        button.addTarget(self, action: "bookButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        footer.addSubview(button)
        tableView.tableFooterView = footer
        
    }
    
    func bookButtonTapped(sender: AnyObject) {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setBool(true, forKey: "hideBookButton")
        UIApplication.sharedApplication().openURL(NSURL(string: "http://web.arendelle.org/book")!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // first start 2/2
        let prefs = NSUserDefaults.standardUserDefaults()
        if !prefs.boolForKey("firstStart") {
            prefs.setBool(true, forKey: "firstStart")
            
            // open welcome dialog
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let view = storyboard.instantiateViewControllerWithIdentifier("webView") as! WebviewViewController
            view.title = "Welcome to Arendelle"
            view.html = "welcome"
            presentViewController(view, animated: true, completion: nil)
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func actionMore(sender: AnyObject) {
        
        // setup and show menu
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "New Project", style: .Default, handler: { action in self.showNewProjectDialog() }))   // new project
        alert.addAction(UIAlertAction(title: "Basics", style: .Default, handler: { action in
            
            // show welcome screen
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let view = storyboard.instantiateViewControllerWithIdentifier("webView") as! WebviewViewController
            view.title = "Basics"
            view.html = "welcome"
            self.presentViewController(view, animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Learn Arendelle", style: .Default, handler: { action in
            
            // learn Arendelle (book)
            UIApplication.sharedApplication().openURL(NSURL(string: "http://web.arendelle.org/book")!)
            return
            
        }))
        alert.addAction(UIAlertAction(title: "Help", style: .Default, handler: { action in
            
            // show help
            UIApplication.sharedApplication().openURL(NSURL(string: "http://web.arendelle.org/book/getting_started/arendelle_ios_app.html")!)
            return
            
        }))
        alert.addAction(UIAlertAction(title: "Rate Me", style: .Default, handler: { action in
            
            // rate app
            UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/app/id962486181")!)
            return
            
        }))
        alert.addAction(UIAlertAction(title: "Report Bug", style: .Default, handler: { action in
            
            // report bug
            UIApplication.sharedApplication().openURL(NSURL(string: "http://reporter.arendelle.org/bug/ios")!)
            return
            
        }))
        alert.addAction(UIAlertAction(title: "About", style: .Default, handler: { action in
            
            // show about screen
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let view = storyboard.instantiateViewControllerWithIdentifier("webView") as! WebviewViewController
            view.title = "About"
            view.html = "about"
            self.presentViewController(view, animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        if let presentationController = alert.popoverPresentationController {
            presentationController.barButtonItem = self.navigationItem.rightBarButtonItem
        }
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    func showNewProjectDialog() {
        
        // show dialog for new Arendelle project
        var alert = UIAlertController(title: "New", message: "Enter a name to create a new Arendelle project.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            let textName = alert.textFields![0] as! UITextField
            //let textMainFunctionName = alert.textFields![1] as UITextField
            
            // check input
            if textName.text == "" {
                self.showNewProjectDialog()
            } else {
                self.newProject(textName.text, mainFunctionName: "main")
            }
            
        }))
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Name"
        })
        /*alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Name of main function"
        })*/
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "show" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let project = projectList[indexPath.row]
                let controller = segue.destinationViewController as! FilesViewController
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        let project = projectList[indexPath.row]
        cell.textLabel!.text = project
        if let preview = UIImage(contentsOfFile: Files.getDocsDir().stringByAppendingPathComponent(project).stringByAppendingPathComponent(".preview.png")) {
            var imageView = UIImageView(image: preview)
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.clipsToBounds = true
            cell.backgroundView = imageView
        }
        
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
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        // show rename dialog
        var alert = UIAlertController(title: "Rename", message: "Enter a new name for the project.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            let textName = alert.textFields![0] as! UITextField
            
            // check input
            if textName.text == "" {
                self.tableView(tableView, accessoryButtonTappedForRowWithIndexPath: indexPath)
            } else {
                self.renameProject(indexPath.row, newName: textName.text)
            }
            
        }))
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "New name"
        })
        self.presentViewController(alert, animated: true, completion: nil)
        
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
        properties["colorBackground"] = "#000000"
        properties["colorFirst"] = "#FFFFFF"
        properties["colorSecond"] = "#CECECE"
        properties["colorThird"] = "#8C8A8C"
        properties["colorFourth"] = "#424542"
        Files.createConfigFile(projectFolder.stringByAppendingPathComponent("project.config"), properties: properties)
        
        // create main function
        Files.write(projectFolder.stringByAppendingPathComponent(mainFunctionName + ".arendelle"), text: "")
        
        // create preview image
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
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        performSegueWithIdentifier("show", sender: self)
        tableView(self.tableView, didSelectRowAtIndexPath: indexPath)
        
    }
    
    // renames a project
    func renameProject(index: Int, newName: String) {
        
        let projectFolder = projectList[index]
        let fileManager = NSFileManager.defaultManager()
        fileManager.moveItemAtPath(Files.getDocsDir().stringByAppendingPathComponent(projectFolder), toPath: Files.getDocsDir().stringByAppendingPathComponent(newName), error: nil)
        
        projectList[index] = newName
        var cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
        cell!.textLabel!.text = newName
        
    }
    
    // creates a preview image
    private func createPreviewImage(code: String) -> UIImage {
        
        var screen = codeScreen(xsize: Int(UIScreen.mainScreen().bounds.width) / Int(10.0 * UIScreen.mainScreen().scale), ysize: 5)
        masterEvaluator(code: code, screen: &screen)
        
        // helper function: creates an UIColor from a hex string
        func colorWithHexString(hex:String) -> UIColor {
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
        
        let size = CGSize(width: screen.screen.colCount() * Int(10.0 * UIScreen.mainScreen().scale), height: 5 * Int(10.0 * UIScreen.mainScreen().scale))
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, colorWithHexString("#FFFFFF").CGColor)
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))
        CGContextSetAlpha(context, 0.1)
        for x in 0..<screen.screen.colCount() {
            for y in 0..<5 {
                switch screen.screen[x,y] {
                    
                case 1:
                    CGContextSetFillColorWithColor(context, colorWithHexString("#CECECE").CGColor)
                    
                case 2:
                    CGContextSetFillColorWithColor(context, colorWithHexString("#8C8A8C").CGColor)
                    
                case 3:
                    CGContextSetFillColorWithColor(context, colorWithHexString("#424542").CGColor)
                    
                case 4:
                    CGContextSetFillColorWithColor(context, colorWithHexString("#000000").CGColor)
                    
                default:
                    CGContextSetFillColorWithColor(context, colorWithHexString("#FFFFFF").CGColor)
                    
                }
                
                CGContextFillRect(context, CGRectMake(CGFloat(x * Int(10.0 * UIScreen.mainScreen().scale)), CGFloat(y * Int(10.0 * UIScreen.mainScreen().scale)), CGFloat(Int(10.0 * UIScreen.mainScreen().scale)), CGFloat(Int(10.0 * UIScreen.mainScreen().scale))))
            }
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    // creates example projects
    private func createExampleProjects() {
        
        let examples = [    [   "example_10print",  "10print.arendelle",    "10 PRINT",     "2" ],
                            [   "example_qbert",    "qbert.arendelle",      "Q-Bert",       "0" ],
                            [   "example_basic1",   "basic1.arendelle",     "Basic 1",      "0" ]
        ]
        
        for example in examples {
            
            // create project folder
            let fileManager = NSFileManager.defaultManager()
            let docsDir = Files.getDocsDir()
            let projectFolder = docsDir.stringByAppendingPathComponent(example[2])
            fileManager.createDirectoryAtPath(projectFolder, withIntermediateDirectories: true, attributes: nil, error: nil)
            
            // copy files
            fileManager.copyItemAtPath(NSBundle.mainBundle().pathForResource(example[0], ofType: ".arendelle")!, toPath: projectFolder.stringByAppendingPathComponent(example[1]), error: nil)
            
            // create config file
            var properties = [String: String]()
            properties["mainFunction"] = example[1]
            properties["currentFunction"] = properties["mainFunction"]
            properties["colorPalette"] = example[3]
            switch example[3].toInt()! {
                
                // Arendelle Classic
            case 0:
                properties["colorBackground"] = "#000000"
                properties["colorFirst"] = "#FFFFFF"
                properties["colorSecond"] = "#CECECE"
                properties["colorThird"] = "#8C8A8C"
                properties["colorFourth"] = "#424542"
                
                // Arendelle Pink
            case 2:
                properties["colorBackground"] = "#000000"
                properties["colorFirst"] = "#E60087"
                properties["colorSecond"] = "#B800AD"
                properties["colorThird"] = "#8E00D7"
                properties["colorFourth"] = "#6600FF"
                
            default:
                break
            }
            Files.createConfigFile(projectFolder.stringByAppendingPathComponent("project.config"), properties: properties)
            
            // create preview image
            UIImagePNGRepresentation(createPreviewImage(Files.read(projectFolder.stringByAppendingPathComponent(properties["mainFunction"]!)))).writeToFile(projectFolder.stringByAppendingPathComponent(".preview.png"), atomically: true)
            
        }
        
    }

}


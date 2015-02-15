//
//  SettingsViewController.swift
//  Arendelle
//
//  Created by mh on 29.01.15.
//  Copyright (c) 2015 Arendelle Project. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var projectFolder: String = ""
    var configFile: String = ""
    var fileList: [String] = []
    let colorPalettes: [String] = ["Arendelle Classic", "Sparkling Blue", "Arendelle Pink", "Simple Red", "White Legacy"]
    
    // gui objects
    @IBOutlet weak var mainFunctionPicker: UIPickerView!
    @IBOutlet weak var colorPalettePicker: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // setup pickers
        mainFunctionPicker.dataSource = self
        mainFunctionPicker.delegate = self
        colorPalettePicker.dataSource = self
        colorPalettePicker.delegate = self
        
        // get all functions for main function picker
        let filelist = Files.getFiles(projectFolder)
        let indexPath = NSIndexPath(forRow: 0, inSection: 1)
        for file in filelist {
            if file.rangeOfString(".arendelle") != nil {
                let name = Files.getRelativePath(projectFolder, path: file).componentsSeparatedByString(".arendelle")[0].stringByReplacingOccurrencesOfString("/", withString: ".", options: .LiteralSearch, range: nil)
                self.fileList.append(name)
            }
        }
        
        // select current main function
        let mainFunction = (Files.parseConfigFile(configFile)["mainFunction"]! as String).componentsSeparatedByString(".arendelle")[0].stringByReplacingOccurrencesOfString("/", withString: ".", options: .LiteralSearch, range: nil)
        mainFunctionPicker.selectRow(find(fileList, mainFunction)!, inComponent: 0, animated: false)
        
        // select current color palette
        if let colorPalette = Files.parseConfigFile(configFile)["colorPalette"] {
            colorPalettePicker.selectRow(colorPalette.toInt()!, inComponent: 0, animated: false)
        } else {
            colorPalettePicker.selectRow(0, inComponent: 0, animated: false)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // save all settings
        var properties = Files.parseConfigFile(configFile)
        
        // main function
        properties["mainFunction"] = fileList[mainFunctionPicker.selectedRowInComponent(0)].stringByReplacingOccurrencesOfString(".", withString: "/", options: .LiteralSearch, range: nil) + ".arendelle"
        
        // color palette
        properties["colorPalette"] = String(colorPalettePicker.selectedRowInComponent(0))
        switch colorPalettePicker.selectedRowInComponent(0) {
            
            // Arendelle Classic
        case 0:
            properties["colorBackground"] = "000000"
            properties["colorFirst"] = "FFFFFF"
            properties["colorSecond"] = "CECECE"
            properties["colorThird"] = "8C8A8C"
            properties["colorFourth"] = "424542"
            
            // Sparkling Blue
        case 1:
            properties["colorBackground"] = "000000"
            properties["colorFirst"] = "49CEE6"
            properties["colorSecond"] = "49B3E6"
            properties["colorThird"] = "499EE6"
            properties["colorFourth"] = "4985E6"
            
            // Arendelle Pink
        case 2:
            properties["colorBackground"] = "000000"
            properties["colorFirst"] = "E60087"
            properties["colorSecond"] = "B800AD"
            properties["colorThird"] = "8E00D7"
            properties["colorFourth"] = "6600FF"
            
            // Simple Red
        case 3:
            properties["colorBackground"] = "FFFFFF"
            properties["colorFirst"] = "E70D20"
            properties["colorSecond"] = "EC444B"
            properties["colorThird"] = "F17E81"
            properties["colorFourth"] = "F7BBBE"
            
            // White Legacy
        case 4:
            properties["colorBackground"] = "EAEAEA"
            properties["colorFirst"] = "030303"
            properties["colorSecond"] = "313131"
            properties["colorThird"] = "6D6D6D"
            properties["colorFourth"] = "B3B3B3"
            
        default:
            break
        }
        
        Files.createConfigFile(configFile, properties: properties)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Pickers
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return fileList.count
        case 1:
            return colorPalettes.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        switch pickerView.tag {
        case 0:
            return fileList[row]
        case 1:
            return colorPalettes[row]
        default:
            return ""
        }
    }
    
}

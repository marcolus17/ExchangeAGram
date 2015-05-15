//
//  Alert.swift
//  TaskIt
//
//  Created by Nicholas Markworth on 5/12/15.
//  Copyright (c) 2015 Nick Markworth. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    // Show an alertView
    class func showAlertWithText(#viewController: UIViewController, header: String = "Warning", message: String) {
        var alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    // Show an alertView that contains a TextField for data entry
    class func getAlertWithTextField(#viewController: UIViewController, header: String, message: String, textFieldPlaceholder: String) -> UIAlertController {
        let alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = textFieldPlaceholder
            textField.secureTextEntry = false
        }
        
        return alert
    }
}
//
//  DefinitionPopoverVC.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/26/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit

class DefinitionPopoverVC: UIViewController {
    
    let wordnik = WordnikClient.sharedInstance
    
    var sometext: String? //TODO: give 'sometext' a better variable name!
    var definition: String? // Holds the definition from the OSPD4 dictionary in the original word list
    //var networkDefinitions: String? // Hold the definitions retrieved from the net
    
    @IBOutlet weak var definitionTextView: UITextView!
    @IBOutlet weak var networkDefinitionsTV: UITextView!
    
    @IBOutlet weak var currentWord: UILabel!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentWord.text = "DFault"
        if sometext != nil {
            currentWord.text = sometext
        }

        if definition != nil {
            definitionTextView.text = definition
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if sometext != nil {
            
            wordnik.getDefinitionForWord(sometext!) { response, definitions, success, errorString in
                if response != nil {
                    
                    if success {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.activityView.stopAnimating()
                            var networkDefinitions: String = ""
                            if definitions != nil {
                                for def in definitions! {
                                    networkDefinitions += def
                                    networkDefinitions += "\n\n"
                                }
                                // the case where definitions exist, but holds no values
                                if definitions!.count == 0 {
                                    networkDefinitions += "There are no more definitions for '\(self.sometext!)' found on Wordnik."
                                }
                            }
                            self.networkDefinitionsTV.text = networkDefinitions
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.activityView.stopAnimating()
                            self.networkDefinitionsTV.text = errorString
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityView.stopAnimating()
                        self.networkDefinitionsTV.text = "More definitions may be available on the net, but the internet connection appears to be offline"
                    }
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

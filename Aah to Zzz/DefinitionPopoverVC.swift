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
            
            wordnik.getDefinitionForWord(sometext!) { definitions, success, errorString in
                //TODO: activity indicator while waiting for net defs, and possibly user messages if errors
                // eg, no network: more defs if you get online etc
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        var networkDefinitions: String = "More definitions from the net powered by Wordnik\n\n"
                        for def in definitions {
                            networkDefinitions += def
                            networkDefinitions += "\n\n"
                        }
                        self.networkDefinitionsTV.text = networkDefinitions
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

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
    
    var sometext: String?
    var definition: String?
    
    @IBOutlet weak var definitionTextView: UITextView!
    
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
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        print("SUCCESS!")
                        print("IN POPOVER and defs: \(definitions)")
                        //self.showActivityView(false)
                        //self.performSegueWithIdentifier("loginSegue", sender: sender)
                    }
                }
            //print(wordnik.getDefinitionForWord(sometext!))
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

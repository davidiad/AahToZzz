//
//  AtoZViewController.swift
//  Aah to Zzz
//
//  Created by David Fierstein on 2/18/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit

class AtoZViewController: UIViewController {
    
    var model = AtoZModel.sharedInstance
    var letters: [String]!
    var wordlist = [String]()

    @IBOutlet var lettertiles: [UIButton]!
    
    @IBAction func generateNewWordlist(sender: AnyObject) {
        generateWordList()
        // need to put the word list into the table of words
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // reference for memory leak bug, and fix:
        // http://stackoverflow.com/questions/34075326/swift-2-iboutlet-collection-uibutton-leaks-memory
        //TODO: check for memory leak here
        // create an array to populate the buttons that hold the letters

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // prepareForSegue is called before viewDidLoad, therefore, creating and then passing on the letters & words here
        generateWordList()
        if let wordTableController = segue.destinationViewController as? AtoZTableViewController {
            wordTableController.wordlist = wordlist
        } else {
            print("segue to AtoZTableViewController fail")
        }
    }
    
    func generateWordList() {
        letters = model.generateLetters()
        
        // Set the letters in the buttons being used as letter tiles
        for var i=0; i<letters.count; i++ {
            lettertiles[i].setTitle(letters[i], forState: UIControlState.Normal)
        }
        
        wordlist = model.generateWordlist(letters)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

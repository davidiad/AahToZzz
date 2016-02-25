//
//  AtoZViewController.swift
//  Aah to Zzz
//
//  Created by David Fierstein on 2/18/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit

class AtoZViewController: UIViewController {
    
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    var model = AtoZModel.sharedInstance
    var letters: [Letter]! //TODO: why not ? instead of !
    var wordlist = [String]()
    
    var wordTable: AtoZTableViewController?
    
    var game: GameData?
    var currentLetterSet: LetterSet?
    var currentWords: [Word]?

    @IBOutlet var lettertiles: [UIButton]!
    @IBOutlet weak var wordInProgress: UILabel!
    
    @IBAction func generateNewWordlist(sender: AnyObject) {
        letters = model.generateLetters() // new set of letters created and saved to context
        checkForExistingLetters()
        updateTiles()
        generateWordList()
        // put the word list into the table of words and set all words to blank
        if wordTable != nil {
            wordTable!.wordlist = wordlist
            wordTable!.tableView.reloadData() // needed?
            for var i=0; i<wordlist.count; i++ {
                updateCellForWord("---", index: i, color: UIColor.blackColor())
            }
           
        } else {
            print("wordTable was nil")
        }
    }

    @IBAction func addLetterToWordInProgress(sender: UIButton) {
        // add the new letter to the word in progress
        wordInProgress.text = wordInProgress.text! + (sender.titleLabel?.text)!
        sender.enabled = false
        
        if wordInProgress.text?.characters.count > 2 {
            print("The word is...... \(wordInProgress.text!)")
            let foundValidWord = checkForValidWord(wordInProgress.text!)
            print("Was that a valid word??? \(foundValidWord)")
            wordInProgress.text = ""
            
            for tile in lettertiles {
                tile.enabled = true
            }
        }
    }
    
    func checkForValidWord(wordToCheck: String) -> Bool {
        for var i=0; i<wordlist.count; i++ {
            if wordToCheck == wordlist[i] {
                updateCellForWord(wordlist[i], index: i, color: UIColor.blueColor())
                return true
            }
        }
        return false
    }
    
    func updateCellForWord (word: String, index: Int, color: UIColor) {
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        print("The index i found was: \(index)")
        let cell = wordTable!.tableView.cellForRowAtIndexPath(indexPath)
        cell?.textLabel!.text = word
        wordTable!.tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.textColor = color
        
        /* reloading of cell seems to happen without calling reloadRows...
        // Make an array of NSIndexPaths with just the currently targeted cell's indexpath
        //let indexPaths: [NSIndexPath] = [indexPath]
        //wordTable!.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // reference for memory leak bug, and fix:
        // http://stackoverflow.com/questions/34075326/swift-2-iboutlet-collection-uibutton-leaks-memory
        //TODO: check for memory leak here
        // create an array to populate the buttons that hold the letters
        
        //TODO: get the current letter and word list from the model, if there is one

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // prepareForSegue is called before viewDidLoad, therefore, creating and then passing on the letters & words here
        checkForExistingLetters()
        updateTiles()
        generateWordList()
        if let wordTableController = segue.destinationViewController as? AtoZTableViewController {
            wordTableController.wordlist = wordlist
            // set the instance variable for the embedded table view controller for later use
            wordTable = wordTableController
        } else {
            print("segue to AtoZTableViewController fail")
        }
    }
    
    func checkForExistingLetters () {
        // if there is a saved letterset, then use that instead of a new one
        game = model.fetchGameData()
        if game?.currentLetterSetID == nil {
            //letters = model.generateLetters()
            currentLetterSet = model.generateLetterSet()
        } else {
            // there is a currentLetterSet, so let's find it
            let lettersetURI = NSURL(string: (game?.currentLetterSetID)!)
            let id = sharedContext.persistentStoreCoordinator?.managedObjectIDForURIRepresentation(lettersetURI!)
            do {
                currentLetterSet = try sharedContext.existingObjectWithID(id!) as? LetterSet
                // the Letter's are saved in Core Data as an NSSet, so convert to array
                //letters = currentLetterSet?.letters?.allObjects as! [Letter]
            } catch {
                print("Error in getting current Letterset: \(error)")
            }
        }

    }
    
    func generateWordList() {
        wordlist = model.generateWordlist(currentLetterSet?.letters?.allObjects as! [Letter])
        currentWords = model.createOrUpdateWords(wordlist)
    }
    
    func updateTiles () {
        // Set the letters in the buttons being used as letter tiles
//        for var i=0; i<currentLetterSet?.letters?.count; i++ {
//            lettertiles[i].setTitle(letters[i].letter, forState: UIControlState.Normal
//        }
        //TODO: make optional-safe
//        for letter in (currentLetterSet?.letters)! {
//            lettertiles[i].setTitle(letter.letter, forState: UIControlState.Normal)
//        }
         //Set the letters in the buttons being used as letter tiles
        
        // convert the LetterSet into an array
        letters = currentLetterSet?.letters?.allObjects as! [Letter]
        
        for var i=0; i<lettertiles.count; i++ {
            lettertiles[i].setTitle(letters[i].letter, forState: UIControlState.Normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

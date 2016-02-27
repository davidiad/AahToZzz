//
//  AtoZViewController.swift
//  Aah to Zzz
//
//  Created by David Fierstein on 2/18/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit
import CoreData

class AtoZViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    var model = AtoZModel.sharedInstance
    var letters: [Letter]! //TODO: why not ? instead of !
    var wordlist = [String]()
    
    var wordTable: AtoZTableViewController?
    
    var game: GameData?
    var currentLetterSet: LetterSet?
    var currentWords: [Word]?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var lettertiles: [UIButton]!
    @IBOutlet weak var wordInProgress: UILabel!
    
    // MARK: - NSFetchedResultsController
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Word")
        fetchRequest.predicate = NSPredicate(format: "inCurrentList == %@", true)
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "word", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    //Mark:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Save whatev")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        // reference for memory leak bug, and fix:
        // http://stackoverflow.com/questions/34075326/swift-2-iboutlet-collection-uibutton-leaks-memory
        //TODO: check for memory leak here
        // create an array to populate the buttons that hold the letters
        
        //TODO: get the current letter and word list from the model, if there is one
        checkForExistingLetters()
        updateTiles()
        generateWordList()
        
    }
    

    // MARK:- FetchedResultsController delegate protocol
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            print("Updating Fetched Word")
            if let indexPath = indexPath, let cell = tableView.cellForRowAtIndexPath(indexPath) as? WordListCell {
                configureCell(cell, atIndexPath: indexPath)
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
        }
    }

    
    //MARK:- Table View Data Source Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let _ = fetchedResultsController.sections {
            //let sectionInfo = sections[section]
            //return sectionInfo.numberOfObjects
            return 1
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordlist.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! WordListCell
        
        
        configureCell(cell, atIndexPath: indexPath)
        
        
        return cell
    }
    
    func configureCell(cell: WordListCell, atIndexPath indexPath: NSIndexPath) {
        
        // Fetch Word
        if let word = fetchedResultsController.objectAtIndexPath(indexPath) as? Word {
            if word.found == true {
                cell.textLabel?.text = word.word
            } else {
                cell.word.text = "? ? ?"
            }
        }
}
    
    //MARK:- Actions
    
    @IBAction func generateNewWordlist(sender: AnyObject) {
        currentLetterSet = model.generateLetterSet() // new set of letters created and saved to context

        // converting the new LetterSet to an array, for use in this class
        // TODO: make use of set, rather than a parrallel array that has to be maintained
        letters = currentLetterSet?.letters?.allObjects as! [Letter]
        updateTiles()
        model.generateWordlist(letters)
//        // put the word list into the table of words and set all words to blank
//        if wordTable != nil {
//            wordTable!.wordlist = wordlist
//            wordTable!.tableView.reloadData() // needed?
//            for var i=0; i<wordlist.count; i++ {
//                //updateCellForWord("---", index: i, color: UIColor.blackColor())
//            }
//           
//        } else {
//            print("wordTable was nil")
//        }
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
                //updateCellForWord(wordlist[i], index: i, color: UIColor.blueColor())
                // set the found property of the Word to true
                let indexPath = NSIndexPath(forRow: i, inSection: 0)
                let currentWord = fetchedResultsController.objectAtIndexPath(indexPath) as! Word
                currentWord.found = true
                return true
            }
        }
        return false
    }
 /*
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
*/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // prepareForSegue is called before viewDidLoad, therefore, creating and then passing on the letters & words here
//        checkForExistingLetters()
//        updateTiles()
//        generateWordList()
//        if let wordTableController = segue.destinationViewController as? AtoZTableViewController {
//            wordTableController.wordlist = wordlist
//            // set the instance variable for the embedded table view controller for later use
//            wordTable = wordTableController
//        } else {
//            print("segue to AtoZTableViewController fail")
//        }
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

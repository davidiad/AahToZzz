//
//  AtoZViewController.swift
//  Aah to Zzz
//
//  Created by David Fierstein on 2/18/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit
import CoreData

class AtoZViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    let position1 = CGPointMake(45, 260)
    let position2 = CGPointMake(100, 260)
    let position3 = CGPointMake(155, 260)
    var occupied1: Bool = false
    var occupied2: Bool = false
    var occupied3: Bool = false
    
    var model = AtoZModel.sharedInstance
    var letters: [Letter]! //TODO: why not ? instead of !
    var wordlist = [String]()
    
    
    var game: GameData?
    var currentLetterSet: LetterSet?
    var currentWords: [Word]?
    
    var currentNumberOfWords: Int?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var lettertiles: [Tile]!
    @IBOutlet weak var wordInProgress: UILabel!
    
    //MARK:- vars for UIDynamics
    
    lazy var center: CGPoint = {
        return CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
    }()

    lazy var radialGravity: UIFieldBehavior = {
        let radialGravity: UIFieldBehavior = UIFieldBehavior.radialGravityFieldWithPosition(self.center)
        radialGravity.region = UIRegion(radius: 200.0)
        radialGravity.strength = 100.0
        radialGravity.falloff = 1.0
        radialGravity.minimumRadius = 50.0
        return radialGravity
    }()
    
    private var animator: UIDynamicAnimator!
    private var attachmentBehavior: UIAttachmentBehavior!
    private var pushBehavior: UIPushBehavior!
    private var itemBehavior: UIDynamicItemBehavior!
    private var gravityBehavior = UIGravityBehavior()
    private var collisionBehavior = UICollisionBehavior()
    private var blackhole = UIFieldBehavior!()
//    private var snap0 = UISnapBehavior!()
//    private var snap1 = UISnapBehavior!()
//    private var snap2 = UISnapBehavior!()
    
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
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        // reference for memory leak bug, and fix:
        // http://stackoverflow.com/questions/34075326/swift-2-iboutlet-collection-uibutton-leaks-memory
        //TODO: check for memory leak here
        // create an array to populate the buttons that hold the letters
        
        animator = UIDynamicAnimator(referenceView: view)
        for var i=0; i<lettertiles.count; i++ {
//            var xpos: CGFloat
//            var ypos: CGFloat
//            
//            switch i {
//                
//            case 4, 5, 6:
//                xpos = CGFloat(i - 3) * 65.0
//                ypos = 600.0
//            case 1, 2, 3:
//                xpos = (CGFloat(i) * 85.0) - 40.0
//                ypos = 500.0
//                
//            case 0:
//                xpos = 130.0
//                ypos = 400.0
//                
//            default:
//                xpos = 100
//                ypos = 300
//            }
            
            //let tileLocation: CGPoint = CGPointMake(xpos, ypos)

            lettertiles[i].location = generateLetterPosition(i)
            lettertiles[i].snapBehavior = UISnapBehavior(item: lettertiles[i], snapToPoint: lettertiles[i].location!)
            lettertiles[i].snapBehavior?.damping = 0.9
            animator.addBehavior(lettertiles[i].snapBehavior!)
        }
        checkForExistingLetters()
        updateTiles()
        generateWordList()
        let mainGradient = model.yellowPinkBlueGreenGradient()
        
        mainGradient.frame = view.bounds
        mainGradient.zPosition = -1
        mainGradient.name = "mainGradientLayer"
        view.layer.addSublayer(mainGradient)
        
        pushBehavior = UIPushBehavior(items: lettertiles, mode: .Instantaneous)
        pushBehavior.pushDirection = CGVector(dx: 3.0, dy: 3.0)
        pushBehavior.magnitude = 0.1//magnitude / ThrowingVelocityPadding
        
        gravityBehavior = UIGravityBehavior(items: lettertiles)
        collisionBehavior = UICollisionBehavior(items: lettertiles)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        
        blackhole = UIFieldBehavior.radialGravityFieldWithPosition(CGPointMake(65, 150))
        blackhole.falloff = 0.01
        blackhole.strength = 1234.9
        
//        snap0 = UISnapBehavior(item: lettertiles[0], snapToPoint: CGPointMake(40, 300))
//        snap1 = UISnapBehavior(item: lettertiles[1], snapToPoint: CGPointMake(140, 300))
//        snap2 = UISnapBehavior(item: lettertiles[2], snapToPoint: CGPointMake(240, 300))
        
        //animator.addBehavior(gravityBehavior)
        //animator.addBehavior(pushBehavior)
        //animator.addBehavior(collisionBehavior)
        //animator.addBehavior(blackhole)
//        animator.addBehavior(snap0)
//        animator.addBehavior(snap1)
//        animator.addBehavior(snap2)
    }
    
    func generateLetterPosition(tileNum: Int) -> CGPoint{
        var xpos: CGFloat
        var ypos: CGFloat
            switch tileNum {
                
            case 4, 5, 6:
                xpos = CGFloat(tileNum - 3) * 65.0
                ypos = 600.0
            case 1, 2, 3:
                xpos = (CGFloat(tileNum) * 85.0) - 40.0
                ypos = 500.0
                
            case 0:
                xpos = 130.0
                ypos = 400.0
                
            default:
                xpos = 100
                ypos = 300
            }

        return CGPointMake(xpos, ypos)
    }
    
    func snapTileToPosition (tile: Tile) {
        if !occupied1 {
            tile.snapBehavior?.snapPoint = position1
            occupied1 = true
        } else if !occupied2 {
            tile.snapBehavior?.snapPoint = position2
            occupied2 = true
        } else if !occupied3 {
            tile.snapBehavior?.snapPoint = position3
            occupied3 = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Thank you to Aaron Douglas for showing an easy way to turn on the cool field of lines that visualize UIFieldBehaviors!
        // https://astralbodi.es/2015/07/16/uikit-dynamics-turning-on-debug-mode/
        animator.setValue(true, forKey: "debugEnabled")
        
        let itemBehavior = UIDynamicItemBehavior(items: lettertiles)
        itemBehavior.density = 0.5 // 12
        animator.addBehavior(itemBehavior) // 13
        
        //vortex.addItem(orbitingView) // 14
        radialGravity.addItem(lettertiles[0]) // 15
        
        //animator.addBehavior(radialGravity) // 16
        //animator.addBehavior(vortex) // 17
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
            return 1
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            currentNumberOfWords = sectionInfo.numberOfObjects
            return currentNumberOfWords!
        }
        
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! WordListCell
//        cell.word.text = "x x x"
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell: WordListCell, atIndexPath indexPath: NSIndexPath) {
        
        // Fetch Word
        if let word = fetchedResultsController.objectAtIndexPath(indexPath) as? Word {
            if word.found == true && word.inCurrentList == true {
                cell.word.text = word.word
            } else {
            cell.word.text = "? ? ?"
            }
        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let wordCell = tableView.cellForRowAtIndexPath(indexPath) as? WordListCell {
            // only if false to prevent the same Popover being called again while it's already up for that word
            if wordCell.selected == false {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("definition") as! DefinitionPopoverVC
                vc.modalPresentationStyle = UIModalPresentationStyle.Popover
                if let wordObject = fetchedResultsController.objectAtIndexPath(indexPath) as? Word {
                    vc.sometext = wordObject.word
                    vc.definition = model.getDefinition(wordObject.word!)
                }
                let popover: UIPopoverPresentationController = vc.popoverPresentationController!
                //popover.barButtonItem = sender
                popover.delegate = self
                popover.permittedArrowDirections = UIPopoverArrowDirection.Right
                // tell the popover that it should point from the cell that was tapped
                popover.sourceView = tableView.cellForRowAtIndexPath(indexPath)
                // make the popover arrow point from the sourceRect, further to the right than default
                let sourceRect = CGRectMake(10, 10, 170, 25)
                popover.sourceRect = sourceRect
                presentViewController(vc, animated: true, completion:nil)
            }
        }
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: prevent popover from attempting to present twice in a row
    }
    
    //MARK:- Popover Delegate functions
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        //return UIModalPresentationStyle.FullScreen
        // allows popever style on iPhone as opposed to Full Screen
        return UIModalPresentationStyle.None
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
        let btnDone = UIBarButtonItem(title: "Done", style: .Done, target: self, action: "dismiss")
        navigationController.topViewController!.navigationItem.rightBarButtonItem = btnDone
        return navigationController
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK:- Actions
    
    @IBAction func generateNewWordlist(sender: AnyObject) {
        // Generating a new list, so first, set all the previous Words 'found' property to false
        // and, if the found property is true, first add 1 to the numTimesFound property
        for var i=0; i<fetchedResultsController.fetchedObjects?.count; i++ {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            if let word = fetchedResultsController.objectAtIndexPath(indexPath) as? Word {
                if word.found == true {
                    word.numTimesFound += 1
                }
                word.found = false
                word.inCurrentList = false
            }
        }
        saveContext()
//        let newWord = Word(wordString: "AAA", context: sharedContext)
        currentLetterSet = model.generateLetterSet() // new set of letters created and saved to context

        // converting the new LetterSet to an array, for use in this class
        letters = currentLetterSet?.letters?.allObjects as! [Letter]
        updateTiles()
        currentWords = model.generateWords(letters)
        // save the current # of words for use later in checkForValidWord
        currentNumberOfWords = currentWords?.count
        
    }

    @IBAction func addLetterToWordInProgress(sender: Tile) {
        // add the new letter to the word in progress
        wordInProgress.text = wordInProgress.text! + (sender.titleLabel?.text)!
        snapTileToPosition(sender)
        sender.enabled = false
        
        if wordInProgress.text?.characters.count > 2 {
            _ = checkForValidWord(wordInProgress.text!)
            wordInProgress.text = ""
            
            for tile in lettertiles {
                tile.enabled = true
            }
        }
        
    }
    
    func checkForValidWord(wordToCheck: String) -> Bool {
        //TODO: unwrap currentNumOfWords safely?
        for var i=0; i<currentNumberOfWords; i++ {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let aValidWord = fetchedResultsController.objectAtIndexPath(indexPath) as! Word
            if wordToCheck == aValidWord.word {
                //updateCellForWord(wordlist[i], index: i, color: UIColor.blueColor())
                // set the found property of the Word to true
                
                let currentWord = fetchedResultsController.objectAtIndexPath(indexPath) as! Word
                currentWord.found = true
                saveContext()
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
                return true
            }
            
        }
        return false
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

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
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if sharedContext.hasChanges {
            do {
                try sharedContext.save()
            } catch {
                let nserror = error as NSError
                print("Could not save the Managed Object Context")
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}


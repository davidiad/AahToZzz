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
    
    //TODO: WHen proxy scroll is touched, show scroll indicator. Also show vertical bar with progress?
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == proxyTable {
            wordTable.setContentOffset(proxyTable.contentOffset, animated: false)
        }
//        if scrollView == wordTable {
//            proxyTable.setContentOffset(wordTable.contentOffset, animated: false)
//        }
    }
    
    var model = AtoZModel.sharedInstance //why not let?
    var letters: [Letter]! //TODO: why not ? instead of !
    var wordlist = [String]()
    var positions: [Position]?
    
    @IBOutlet weak var progressLabl: UILabel!
    
    var game: GameData?
    var currentLetterSet: LetterSet?
    var currentWords: [Word]?
    
    var currentNumberOfWords: Int?

    @IBOutlet weak var wordTable: UITableView!
    @IBOutlet weak var proxyTable: UITableView!
    
    var lettertiles: [Tile]! // created in code so that autolayout done't interfere with UI Dynamcis
    @IBOutlet weak var wordInProgress: UILabel!
    @IBOutlet weak var startNewList: UIButton!
    
    
    @IBAction func returnTiles(sender: AnyObject) {
        returnTiles()
    }
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var inProgressLeading: NSLayoutConstraint!
    
    @IBOutlet weak var statusBgHeight: NSLayoutConstraint!
    
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
    
    //MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //proxyTable.registerClass(ProxyTableCell.self, forCellReuseIdentifier: "proxycell")
        //wordTable.registerClass(WordListCell.self, forCellReuseIdentifier: "cell")
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        game = model.game

        
        /* May not be needed, as 'positions' is sorted in the model
        positions = game?.positions?.allObjects as? [Position]
        positions!.sortInPlace {
            ($0.index as Int16?) < ($1.index as Int16?)
        }
        */
        
        // constants allow the tiles to be anchored at desired location
        let tilesAnchorPoint = model.calculateAnchor(view.frame.size.width + 90.0, areaHeight: view.frame.size.height, vertiShift: -540.0)
        model.updateLetterPositions() // needed to get the view bounds first, and then go back to the model to update the Positions
        // Set positions here, to the sorted array position from the model
        //(Confusing because model.game.positions is a Set
        positions = model.positions
        
        // Adjust the constraints for the Tile UI background elements
        topConstraint.constant = tilesAnchorPoint.y + CGFloat(120.0) - 0.5 * wordInProgress.frame.height
        inProgressLeading.constant = tilesAnchorPoint.x - 0.5 * wordInProgress.frame.width

        //scrollingSlider.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * 0.5))
        
        animator = UIDynamicAnimator(referenceView: view)
        lettertiles = [Tile]()
        let image = UIImage(named: "tile") as UIImage?
        let bgImage = UIImage(named: "tile_bg") as UIImage?
        for var i=0; i<7; i++ {

            //let button   = UIButton(type: UIButtonType.Custom) as UIButton
            //TODO: move some of this stuff to init for Tile
            //TODO: use the eventual tile positions
            //lettertiles[i].letter!.position!.position
            if let tilePos = positions?[i].position {
                let tile = Tile(frame: CGRectMake(tilePos.x, tilePos.y * CGFloat(i), 50, 50))
            let bgView = UIImageView(image: bgImage)
            bgView.center = tilePos
            tile.setBackgroundImage(image, forState: .Normal)
            tile.setTitleColor(UIColor.blueColor(), forState: .Normal)
           
            tile.setTitle("Q", forState: .Normal) // Q is placeholder value
            tile.addTarget(self, action: "addLetterToWordInProgress:", forControlEvents:.TouchUpInside)
            lettertiles.append(tile)
            //tile.animator = animator // so that we can affect the animator from inside the Tile class
            setupPanRecognizer(tile)
            view.addSubview(bgView)
            view.addSubview(tile)
            }
        }
        let upperPositionsBg = UIImage(named: "upper_positions_bg") as UIImage?
        let upperPositionsView = UIImageView(image: upperPositionsBg)
        upperPositionsView.center = CGPointMake(tilesAnchorPoint.x, tilesAnchorPoint.y + 120)
        view.addSubview(upperPositionsView)
        // TODO:-make sure all tiles have higher z index than all bg's. Also when tapped
        for t in lettertiles {
            //t.bringSubviewToFront(view)
            view.bringSubviewToFront(t)
        }
        // reference for memory leak bug, and fix:
        // http://stackoverflow.com/questions/34075326/swift-2-iboutlet-collection-uibutton-leaks-memory
        //TODO: check for memory leak here
        // create an array to populate the buttons that hold the letters
        

        checkForExistingLetters()
        updateTiles()
        generateWordList()
        startNewList.alpha = 0
        startNewList.hidden = true
//        for var i=0; i<lettertiles.count; i++ { // lettertiles is array of Tiles: [Tile]
//            lettertiles[i].letter!.position = positions![i]
//            print(positions![i].position)
//            lettertiles[i].snapBehavior = UISnapBehavior(item: lettertiles[i], snapToPoint: lettertiles[i].position!)
//            lettertiles[i].snapBehavior?.damping = 0.75
//            animator.addBehavior(lettertiles[i].snapBehavior!)
//        }
        
        
        let mainGradient = model.yellowPinkBlueGreenGradient()
        
        mainGradient.frame = view.bounds
        mainGradient.zPosition = -1
        mainGradient.name = "mainGradientLayer"
        view.layer.addSublayer(mainGradient)
        
        pushBehavior = UIPushBehavior(items: lettertiles, mode: .Instantaneous)
        pushBehavior.pushDirection = CGVector(dx: 3.0, dy: 3.0)
        pushBehavior.magnitude = 0.1//magnitude / ThrowingVelocityPadding
        
        gravityBehavior = UIGravityBehavior(items: lettertiles)
        collisionBehavior = UICollisionBehavior(items: [])
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        
        blackhole = UIFieldBehavior.radialGravityFieldWithPosition(CGPointMake(65, 150))
        blackhole.falloff = 0.01
        blackhole.strength = 1234.9
        
//        snap0 = UISnapBehavior(item: lettertiles[0], snapToPoint: CGPointMake(40, 300))
//        snap1 = UISnapBehavior(item: lettertiles[1], snapToPoint: CGPointMake(140, 300))
//        snap2 = UISnapBehavior(item: lettertiles[2], snapToPoint: CGPointMake(240, 300))
        
        //animator.addBehavior(gravityBehavior)
        //animator.addBehavior(pushBehavior)
        animator.addBehavior(collisionBehavior)
        //animator.addBehavior(blackhole)
//        animator.addBehavior(snap0)
//        animator.addBehavior(snap1)
//        animator.addBehavior(snap2)
        
//        let scrollGesture = UIPanGestureRecognizer(target: self, action: "scrollByProxy:")
//        scrollProxy.addGestureRecognizer(scrollGesture)
    }
    
//    func scrollByProxy(pan: UIPanGestureRecognizer) {
//        let startPoint = wordTable.contentOffset
//        var currentPoint = startPoint
//        var deltaY = startPoint.y - currentPoint.y
//        switch pan.state {
//        case .Began:
//            print("start pan: \(wordTable.contentOffset)")
//        case .Changed:
//            currentPoint = pan.locationInView(self.view)
//            deltaY = startPoint.y - currentPoint.y
//            wordTable.setContentOffset(CGPointMake(startPoint.x, deltaY), animated: false)
//        case .Ended:
//            currentPoint = pan.locationInView(self.view)
//            deltaY = startPoint.y - currentPoint.y
//            wordTable.setContentOffset(CGPointMake(startPoint.x, deltaY), animated: true)
//            print("end pan: \(wordTable.contentOffset)")
//        default:
//            break
//        }
//    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateProgress(nil)
        // Thank you to Aaron Douglas for showing an easy way to turn on the cool fields of lines that visualize UIFieldBehaviors!
        // https://astralbodi.es/2015/07/16/uikit-dynamics-turning-on-debug-mode/
        //animator.setValue(true, forKey: "debugEnabled")
        
        
        // why is this item behavirot=r needed?
        let itemBehavior = UIDynamicItemBehavior(items: lettertiles)
        itemBehavior.density = 10.0
        itemBehavior.angularResistance = 10.0
        //animator.addBehavior(itemBehavior)
        
        //vortex.addItem(orbitingView)
        radialGravity.addItem(lettertiles[0])
        
        //animator.addBehavior(radialGravity)
        //animator.addBehavior(vortex)
    }
    
//    func snapTileToPosition (tile: Tile) {
//        if !positions![7].occupied {
//            tile.snapBehavior?.snapPoint = positions![7].position //position1
//            positions![7].occupied = true // need to also set the from position to false
//            //TODO: have to get the 'from' Position somehow. How to get the Tile's Letter? add a Letter property to Tile?
//            occupied1 = true
//        } else if !occupied2 {
//            tile.snapBehavior?.snapPoint = positions![8].position
//            occupied2 = true
//            positions![8].occupied = true // need to also set the from position to false
//
//        } else if !occupied3 {
//            tile.snapBehavior?.snapPoint = positions![9].position
//            occupied3 = true
//            positions![9].occupied = true // need to also set the from position to false
//
//        }
//        // update the status of the 'from' tile
//        tile.letter?.position?.occupied = false
//        saveContext()
//    }
    
//    func snapTileToUpperPosition(tile: Tile) {
//        //var newPosition: Position
//        if tile.letter?.position?.index < 7 { // for now, only moving tile if it is in a lower position
//            let newPosition = findUpperVacancy()
//            if newPosition != nil { // if newPosition is nil, then all spaces are occupied, and nothing happens
//                tile.snapBehavior?.snapPoint = (newPosition?.position)!
//                // update the Positions
//                tile.letter?.position?.letter = nil // the previous position is now vacant
//                tile.letter?.position = newPosition
//                newPosition?.letter = tile.letter
//                //tile.position = newPosition?.position // is this line needed?
//                saveContext()
//            }
//        } else {
//            let newPosition = findLowerVacancy()
//        }
//    }
    
    // Each letter should have a position
    func swapTile(tile: Tile) {
        
        let newPosition = findVacancy(tile)

        if newPosition != nil { // if newPosition is nil, then all spaces are occupied, and nothing happens

            
            // update the Positions
            let previousPosition = tile.letter?.position
            
            previousPosition?.letter = nil // the previous position is now vacant

            tile.letter?.position = newPosition
            tile.snapBehavior?.snapPoint = (newPosition?.position)!
            //newPosition?.letter = tile.letter // is the inverse needed?
            saveContext() // safest to save the context here, after every letter swap
            //printTileDiagram()
        }
    }
    
    // in the case that we already know the position
    func swapTileToKnownPosition(tile: Tile, pos: Position) {
        
            // update the Positions
            let previousPosition = tile.letter?.position
            
            previousPosition?.letter = nil // the previous position is now vacant
            tile.letter?.position = pos
            tile.snapBehavior?.snapPoint = pos.position
            saveContext() // safest to save the context here, after every letter swap
    }
    
    func findVacancy(tile: Tile) -> Position? {

        if tile.letter != nil { // tile.letter should never be nil, so this is an extra, possibly unneeded, safeguard
            // tile is in upper position, so look for vacancy in the uppers
            if tile.letter?.position!.index < 7 {
                for var i=7; i<10; i++ {
                    if positions![i].letter == nil {
                        collisionBehavior.addItem(tile) // enable collisions only for tiles when they are in 7 8 or 9
                        return positions![i]
                    }
                }
                return nil
            } else { // must be in the upper positions, so look for a vacancy in the lowers
                
                for var i=6; i>=0; i-- {
                    if positions![i].letter == nil {
                        collisionBehavior.removeItem(tile)
                        return positions![i]
                    }
                }
                return nil
            }
        } else {
            print ("was nil")
            return nil
        }
    }
    

    // MARK:- FetchedResultsController delegate protocol
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        wordTable.beginUpdates()
        proxyTable.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        wordTable.endUpdates()
        proxyTable.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                wordTable.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                proxyTable.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                wordTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                proxyTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath, let cell = wordTable.cellForRowAtIndexPath(indexPath) as? WordListCell {
                configureCell(cell, atIndexPath: indexPath)
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                wordTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                proxyTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                wordTable.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
                proxyTable.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
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
//        var cellIsProxy = false
//        var proxyCell: ProxyTableCell?
//        proxyCell = proxyTable.dequeueReusableCellWithIdentifier("proxycell", forIndexPath: indexPath) as? ProxyTableCell
//        if proxyCell != nil {
//            cellIsProxy = true
//            //return proxyCell!
//        }
//
////        if cellIsProxy == false {
////            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? WordListCell
////            configureCell(cell!, atIndexPath: indexPath)
////            return cell!
////        }
//        
//        switch cellIsProxy {
//        case false:
//            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? WordListCell
//            configureCell(cell!, atIndexPath: indexPath)
//            return cell!
//        case true:
//            return proxyCell!
//        }
        
        if tableView == proxyTable {
            let proxyCell = tableView.dequeueReusableCellWithIdentifier("proxycell", forIndexPath: indexPath) as? ProxyTableCell
            configureProxyCell(proxyCell!, atIndexPath: indexPath)
            return proxyCell!
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? WordListCell
            configureCell(cell!, atIndexPath: indexPath)
            return cell!
        }
        
    }
    
    func configureProxyCell(cell: ProxyTableCell, atIndexPath indexPath: NSIndexPath) {
        //
    }
    
    func configureCell(cell: WordListCell, atIndexPath indexPath: NSIndexPath) {
        
        // Fetch Word
        if let word = fetchedResultsController.objectAtIndexPath(indexPath) as? Word {
            //TODO: can i use cell.wordtext property instead and eliminate the uilabel?
            //TODO: use the word.numTimesFound property to send the correctly colored tiles to the cell
            if word.found == true && word.inCurrentList == true {
                if cell.word != nil { // may be unneeded safeguard
                    //cell.firstLetterBg.image = UIImage(named: "small_tile_yellow")
                    
                    cell.colorCode = ColorCode(code: word.level)
                    cell.word.text = word.word
                    cell.wordtext = cell.word.text // triggers didSet to add image and letters
                    print("In configureCell: \(cell.word.text) at level \(word.level)")
                    
                }
            } else {
                //TODO: remove Word the Label altogether
                //cell.word.text = "? ? ?"
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
                popover.permittedArrowDirections = UIPopoverArrowDirection.Left
                // tell the popover that it should point from the cell that was tapped
                popover.sourceView = tableView.cellForRowAtIndexPath(indexPath)
                // make the popover arrow point from the sourceRect, further to the right than default
                let sourceRect = CGRectMake(10, 10, 170, 25)
                popover.sourceRect = sourceRect
                presentViewController(vc, animated: true, completion:nil)
            }
        } else {
            print("no word cell here")
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
        navigationController.topViewController!.navigationItem.leftBarButtonItem = btnDone
        return navigationController
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK:-Tests
    
    // print out a diagram to see the state of the Tiles and Positions
    
    func printTileDiagram() {
        for var i=0; i<lettertiles.count; i++ {
            //print("\(i): \(lettertiles[i].titleLabel!.text!)    \(lettertiles[i].letter!.position!.index)   \(lettertiles[i].letter!.position!.position)    \(lettertiles[i].snapBehavior!.snapPoint)")
            print("   \(lettertiles[i].letter!.position!.index)   \(lettertiles[i].letter!.position!.position)    \(lettertiles[i].snapBehavior!.snapPoint)")
            
        }
        print("====================================")
        print("")
        print("")
    }
    
    // Progress update //TODO: should these vars be stored to avoid recalc each word?
    func updateProgress(message: String?) {
        progressLabl.alpha = 1.0
        if message != nil {
            progressLabl.text = message
        } else {
            let numFound = currentNumFound()
            if currentNumberOfWords != nil {
                if numFound == currentNumberOfWords {
                    // TODO: make wordListCompleted func
                    animateStatusHeight(80.0)
                    progressLabl.text = "Word List Completed!"
                    animateNewListButton()
                } else {
                    progressLabl.text = "\(numFound) of \(currentNumberOfWords!) words found"                }
            }
        }
        UIView.animateWithDuration(2.35, delay: 0.25, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            
            self.progressLabl.alpha = 0.58
            
            }, completion: { (finished: Bool) -> Void in
                
        })
    }
    
    // each time a word is found, calculate how many have been found to show to the player
    func currentNumFound() -> Int {
        var numWordsFound: Int16 = 0
        for aWord in (fetchedResultsController.fetchedObjects)! {
            let w = aWord as? Word
            if w?.found == true {
                numWordsFound += 1
            }
        }
        return Int(numWordsFound)
    }
    
    //MARK:- Actions
    
    @IBAction func generateNewWordlist(sender: AnyObject) {
        startNewList.alpha = 0
        startNewList.hidden = true
        //printTileDiagram()
        returnTiles() // if any tiles are in the upper positions, return them
        // Generating a new list, so first, set all the previous Words 'found' property to false
        // and, if the found property is true, first add 1 to the numTimesFound property
        for var i=0; i<fetchedResultsController.fetchedObjects?.count; i++ {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            if let word = fetchedResultsController.objectAtIndexPath(indexPath) as? Word {
                word.numTimesPlayed += 1 // the # times the game has put that word into play
                if word.found == true {
                    word.numTimesFound += 1
                    print("Word Level for \(word.word!): \(word.level)")
                }
                //else {
//                    print("not found?")
//                    // if word is NOT found, then take away a point so to speak
//                    // but never go below 0, that could create an unfun hole for the player
//                    if word.numTimesFound > 0 {
//                        word.numTimesFound -= 1
//                    }
               // }
                word.found = false
                word.inCurrentList = false
            }
        }
        saveContext()

        currentLetterSet = model.generateLetterSet() // new set of letters created and saved to context

        // converting the new LetterSet to an array, for use in this class
        letters = currentLetterSet?.letters?.allObjects as! [Letter]
        updateTiles()
        //printTileDiagram()
        currentWords = model.generateWords(letters)
        // save the current # of words for use later in checkForValidWord
        currentNumberOfWords = currentWords?.count
        updateProgress(nil)
        animateStatusHeight(52.0)
        model.printStats()
    }

    @IBAction func addLetterToWordInProgress(sender: Tile) {
        //print("in ADDLETTERTO...")
        //NOTE: should no longer need wordInProgress, getting the text directly from the tiles
        
        // add the new letter to the word in progress
        //wordInProgress.text = wordInProgress.text! + (sender.titleLabel?.text)!
        swapTile(sender) // swapping whichever tile is tapped
        // then, check for a valid word
        // but iff 7 8 and 9 are occupado, then check for valid word
        //TODO: occupied property of positions does not seem to be working right?
        checkUpperPositionsForWord()
        /*
        if positions![7].letter != nil && positions![8].letter != nil && positions![9].letter != nil {
        //if wordInProgress.text?.characters.count > 2 {
            //_ = checkForValidWord(wordInProgress.text!)
            let wordToCheck = (positions![7].letter?.letter)! + (positions![8].letter?.letter)! + (positions![9].letter?.letter)!
            let wordIsValid = checkForValidWord(wordToCheck)
            wordInProgress.text = ""
            
            if wordIsValid { // return the letters to the letter pool
                // Add a brief delay after the 3rd letter so the user can see the 3rd letter displayed before returning letters to original placement
                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(0.55 * Double(NSEC_PER_SEC))) //Int64(NSEC_PER_SEC))
                dispatch_after(time, dispatch_get_main_queue()) {

                    //TODO: might be better to track which tiles have positions at 7 8 and 9 and checking those 3
                    // rather than checking all 7 tiles
                    self.returnTiles()
                }
            } // else: word is *not* valid. Do nothing in that case. The penalty to the user for playing an invalid word is that the flow of their game is interupted. They will have to return the letters manually (or by tapping on return button)
        }
        */
    }
    
    // need to incorporate this into func above this one (and consolidate with checkForValidWord)
    func checkUpperPositionsForWord () {
        if positions![7].letter != nil && positions![8].letter != nil && positions![9].letter != nil {
            let wordToCheck = (positions![7].letter?.letter)! + (positions![8].letter?.letter)! + (positions![9].letter?.letter)!
            let wordIsValid = checkForValidWord(wordToCheck)
            
            if wordIsValid { // return the letters to the letter pool
                //print("\(wordToCheck): at level \(wordToCheck.level)")
                // Add a brief delay after the 3rd letter so the user can see the 3rd letter displayed before returning letters to original placement
                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(0.35 * Double(NSEC_PER_SEC))) //Int64(NSEC_PER_SEC))
                dispatch_after(time, dispatch_get_main_queue()) {
                    //TODO: might be better to track which tiles have positions at 7 8 and 9 and checking those 3
                    // rather than checking all 7 tiles
                    self.returnTiles()
                }
            } else {
            //word is *not* valid. Do nothing in that case (except show a message). The penalty to the user for playing an invalid word is that the flow of their game is interupted. They will have to return the letters manually (by tapping on a button)
                updateProgress("That's not a word!")
            }
        }
    }
    
    func checkForValidWord(wordToCheck: String) -> Bool {
        //TODO: unwrap currentNumOfWords safely?
        var wordWasPreviouslyFound = false
        for var i=0; i<currentNumberOfWords; i++ {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let aValidWord = fetchedResultsController.objectAtIndexPath(indexPath) as! Word
            if wordToCheck == aValidWord.word {
                if aValidWord.found == true {
                    wordWasPreviouslyFound = true
                    updateProgress("Already found \(wordToCheck)")
                }
                let currentWord = fetchedResultsController.objectAtIndexPath(indexPath) as! Word
                currentWord.found = true
                saveContext()
                // Needed to wait until after .found was set before updateProgress, otherwise the newly found word isn't counted
                // But conditional, so we don't overwrite the "Already found.." message
                if wordWasPreviouslyFound == false {
                    updateProgress(nil)
                }
                wordTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
                proxyTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
                

                
                return true
                
            }
        }
        return false
    }
    
    // Check all 7 tiles over each position to find which ones to return
    func returnTiles () {
        for t in self.lettertiles {
            if let _ = t.letter?.position {
                if t.letter!.position!.index > 6 {
                    self.swapTile(t)
                }
            } else {
                t.layer.opacity = 0.3 // a visual cue that something is not working correctly
            }
        }
    }
    
    //TODO: a function to check and reset positions to maintain integrity of model
    func resetPositions() {
        // There should be 7 positions with a letter, and 3 without
        // All 7 Letter's should have a Position (and vice-versa)
        // (Possibly these rules have been violated if their was a crash after the model has been changed, but before it was saved?)
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
            lettertiles[i].letter = letters[i]
            lettertiles[i].position = letters[i].position?.position
            
            lettertiles[i].letter!.position = positions![i]
            
            if lettertiles[i].snapBehavior != nil {
                // update the snapPoint
                lettertiles[i].snapBehavior?.snapPoint = (lettertiles[i].letter?.position?.position)!
            } else { // Add snap behavior to Tile, but only if it doesn't already have one
            //if lettertiles[i].snapBehavior == nil {
                lettertiles[i].snapBehavior = UISnapBehavior(item: lettertiles[i], snapToPoint: lettertiles[i].letter!.position!.position)
                lettertiles[i].snapBehavior?.damping = 0.6
                animator.addBehavior(lettertiles[i].snapBehavior!)
            }
        }
        
        saveContext() // Tile is not in the context, but letter.position is
    }
    
//    //TODO: layout the Tiles which are not using autolayout
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- Panning for Tiles
    func setupPanRecognizer(tile: Tile) {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "panTile:")
        tile.addGestureRecognizer(panRecognizer)
    }
    
    func panTile(pan: UIPanGestureRecognizer) {
        let t = pan.view as! Tile
        let storedSnapBehavior = t.snapBehavior // really being stotrd?
//        animator?.removeBehavior(t.snapBehavior!)
        //animator?.removeAllBehaviors()
        let location = pan.locationInView(self.view)
        
        switch pan.state {
        case .Began:
            animator?.removeBehavior(t.snapBehavior!)
            t.superview?.bringSubviewToFront(t) // Make this Tile float above the other tiles
            let center = t.center
            t.layer.shadowOpacity = 0.85
            let scale = CGAffineTransformMakeScale(1.25, 1.25)
            let move = CGAffineTransformMakeTranslation(0.0, -58.0)
            
            
                UIView.animateWithDuration(0.35, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                
                    t.transform = CGAffineTransformConcat(scale, move)
                
                }, completion: { (finished: Bool) -> Void in
                    
            })
            
      
        case .Changed:
//            let referenceBounds = self.bounds
//            let referenceWidth = referenceBounds.width
//            let referenceHeight = referenceBounds.height
//             
//            // Get item bounds.
//            let itemBounds = self.bounds
//            let itemHalfWidth = itemBounds.width / 2.0
//            let itemHalfHeight = itemBounds.height / 2.0
            
            //            // Apply the initial offset.
            //            location.x -= offset.x
            //            location.y -= offset.y
            
            // Bound the item position inside the reference view.
            //            location.x = max(itemHalfWidth, location.x)
            //            location.x = min(referenceWidth - itemHalfWidth, location.x)
            //            location.y = max(itemHalfHeight, location.y)
            //            location.y = min(referenceHeight - itemHalfHeight, location.y)
            
            t.center = location
            
        case .Ended:
            print("ended")
            //TODO: make a completion block where 1st this code, then when velocity is below a set point, add the snap behavior
//            let velocity = pan.velocityInView(self.view) // doesn't seem to be needed for a snap behavior
//
//            collisionBehavior = UICollisionBehavior(items: [t])
//            collisionBehavior.translatesReferenceBoundsIntoBoundary = true
//            
//            itemBehavior = UIDynamicItemBehavior(items: [t])
//            itemBehavior.resistance = 5.5
//            itemBehavior.angularResistance = 2
//            itemBehavior.elasticity = 1.1
//            animator?.addBehavior(itemBehavior)
//            animator?.addBehavior(collisionBehavior)
//            itemBehavior.addLinearVelocity(velocity, forItem: t)
            
            // interesting. is Position not an optional type, but then closestOpenPosition could still be a nil?
            // check for the nearest unoccipied position, and snap to that
            if let closestOpenPosition = model.findClosestPosition(location, positionArray: positions!) {
                swapTileToKnownPosition(t, pos: closestOpenPosition)
                checkUpperPositionsForWord()
            }
            animator.addBehavior(storedSnapBehavior!)
            t.layer.shadowOpacity = 0.0
            t.transform = CGAffineTransformIdentity
                        //storedSnapBehavior?.snapPoint = closestOpenPosition.position
            //            animator?.addBehavior(radialGravity)
            //            animator?.addBehavior(itemBehavior)
            //            animator?.addBehavior(collisionBehavior)
            //
            //            itemBehavior.addLinearVelocity(velocity, forItem: raft)
            
        default:
            print("in default")
            break
        }
    }
    
    //MARK:- Animations


    func animateTile(sender: AnyObject) {
        
        [UIView.animateWithDuration(5.0, delay: 0.0, options: [.CurveLinear, .AllowUserInteraction], animations: {
            //self.view.layoutIfNeeded()
            }, completion: nil)]
    }
    
    func animateStatusHeight(ht: CGFloat) {
        UIView.animateWithDuration(0.4) {
            self.statusBgHeight.constant = ht
            self.view.layoutIfNeeded()
        }
    }
    
    func animateNewListButton() {
        UIView.animateWithDuration(0.9) {
            self.startNewList.hidden = false
            self.startNewList.alpha = 1.0
            self.view.layoutIfNeeded()
        }
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


//
//  AtoZViewController.swift
//  Aah to Zzz
//
//  Created by David Fierstein on 2/18/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class AtoZViewController: UIViewController {
    
    //TODO: should weak optional vars be used for delegates? Probably yes, to avoid retain cycles
    // AtoZ VC is not releasing
    let tableViewsDelegate = AtoZTableViewDelegates()
    weak var uiDynamicsDelegate: AtoZUIDynamicsDelegate?
    weak var gestureDelegate: AtoZGestureDelegate?
    
    var model = AtoZModel.sharedInstance //why not let?
    var letters: [Letter]! //TODO: why not ? instead of !
    var wordlist = [String]()
    var positions: [Position]?
    var wordHolderCenter: CGPoint?
    var mainGradient: CAGradientLayer?
    var game: Game?
    var currentLetterSet: LetterSet?
    var currentWords: [Word]?
    
    var currentNumberOfWords: Int?
    var currentNumberOfActiveWords: Int?
    
    var fillingInBlanks: Bool = false // flag for configuring cells when Fill in the Blanks button is touched
    
    var lettertiles: [Tile]! // created in code so that autolayout done't interfere with UI Dynamcis
    var tilesToSwap: [Tile]? // an array to temporarilly hold the tiles waiting to be swapped
    var maxTilesToSwap: Int = 0 // temp. diagnostic
    var blurredViews: [BlurViewController] = []
    var animatingStatusHeight: Bool = false
    var arrowEndPoints: [CGPoint] = []
    
    //MARK:- IBOutlets
    @IBOutlet weak var progressLabl: UILabel!
    @IBOutlet weak var wordInProgress: UILabel!
    @IBOutlet weak var startNewList: UIButton!
    @IBOutlet weak var wordTableHolderView: UIView!
    @IBOutlet weak var wordTableHeaderView: UIView!
    @IBOutlet weak var wordTableHeaderCover: UIView!
    @IBOutlet weak var wordTableHeaderCoverHeight: NSLayoutConstraint!
    @IBOutlet weak var wordTableFooterCoverHeight: NSLayoutConstraint!
    @IBOutlet weak var wordTable: UITableView!
    @IBOutlet weak var proxyTable: ProxyTable!
    @IBOutlet weak var proxyTableArrow: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var inProgressLeading: NSLayoutConstraint!
    @IBOutlet weak var statusBgHeight: NSLayoutConstraint!
    @IBOutlet weak var blurredViewHeight: NSLayoutConstraint!
    
    //MARK:- IBActions
    // Unwind segue from Progress view
    @IBAction func cancelToProgressViewController(_ segue:UIStoryboardSegue) {
    }
    
    @IBAction func returnTiles(_ sender: AnyObject) {
        returnTiles()
    }
    
    @IBAction func fillWordList(_ sender: AnyObject) {
        fillInTheBlanks()
    }
    
    @IBAction func autoFillWords(_ sender: AnyObject) {
        fillInWords("Auto Found the words")
    }
    
    @IBAction func autoFillMultiple(_ sender: AnyObject) {
        for i in 0 ..< 100 {
            fillInWords("AutoFind x \(i+1)")
            generateNewWordlist()
        }
    }
    
    // helper for autoFill
    func fillInWords(_ message: String) {
        if fillingInBlanks == false {
            // For each word in the word list, mark each one as found, etc
            for wordObject: Word in currentWords! {
                if wordObject.active == true {
                    wordObject.found = true
                }
            }
            saveContext()
            updateProgress("Auto Found the words")
        }
    }

    //MARK:- vars for UIDynamics
    let gravity = UIGravityBehavior()
    
    lazy var center: CGPoint = {
        return CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
    }()
    
    fileprivate var animator: UIDynamicAnimator!
    
    // Two different collision behaviors being used (One of them seems to have different gravity?)
    fileprivate var collisionBehavior = UICollisionBehavior()
    lazy var collider:UICollisionBehavior = {
        let lazyCollider = UICollisionBehavior()
        // This line makes the boundaries of our reference view a boundary
        // for the added items to collide with.
        lazyCollider.translatesReferenceBoundsIntoBoundary = true
        return lazyCollider
    }()
    
    lazy var dynamicItemBehavior:UIDynamicItemBehavior = {
        let lazyBehavior = UIDynamicItemBehavior()

        lazyBehavior.elasticity = 0.5
        lazyBehavior.allowsRotation = true
        lazyBehavior.friction = 0.3
        lazyBehavior.resistance = 0.5
        
        return lazyBehavior
    }()
    
    lazy var uiDynamicItemBehavior:UIDynamicItemBehavior = {
        let lazyBehavior = UIDynamicItemBehavior()
        lazyBehavior.elasticity = 0.0
        lazyBehavior.allowsRotation = false
        lazyBehavior.density = 5500.0
        lazyBehavior.friction = 5110.00
        lazyBehavior.resistance = 5110.0

        return lazyBehavior
    }()

    
    @IBAction func jumbleTiles(_ sender: AnyObject) {
        
        //Find current positions of the letters. Randomize the positions of the letters. Later, snap to those positions
        let sevenRandomizedInts = model.randomize7()
        for j in 0 ..< 7 {
            
        // There are 10 Positions, not 7. Tiles in the upper positions (7,8,9) will be returned to lower positions
            letters[j].position = positions![sevenRandomizedInts[j]]
        }
        saveContext() // TODO: Need dispatch async?

        for tile in lettertiles {
            // To give a bit of a 3D effect, vary the tiles' scale, depending on how high they are in the view hierarchy. Their tags range from 1000 to 1007, so convert that to a range between 0.5 and 1. Numbers < 1 scale the tiles bigger.
            let scaleFactor = (CGFloat(tile.tag - 1000) / 14.0) + 0.5
            let s = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            
            tile.layer.shadowOpacity = 0.95
            tile.layer.shadowRadius = 24.0
            tile.layer.shadowColor = UIColor.black.cgColor
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                
                tile.transform = s
                
                }, completion: { (finished: Bool) -> Void in
                    tile.layer.shadowOpacity = 0.0 // remove the shadow when back in a box
            })
        }
        
        jumbleTiles()
    }
    
    func jumbleTiles() {
        
        //animator.setValue(true, forKey: "debugEnabled") // uncomment to see dynamics reference lines
        animator.removeAllBehaviors() // reset the animator
        
        uiDynamicItemBehavior.addItem(toolbar)
        animator.addBehavior(gravity)
        animator.addBehavior(collider)
        animator.addBehavior(dynamicItemBehavior)
        animator.addBehavior(uiDynamicItemBehavior)
        // add the scroll view that holds the word list as a collider
        collider.addItem(toolbar)
        
        // Need to turn off gravity after awhile, otherwise it moves the tiles out of position
        let gravityTimer = 1.0
        let gravityDelay = gravityTimer * Double(NSEC_PER_SEC)
        let gravityTime = DispatchTime.now() + Double(Int64(gravityDelay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: gravityTime) {
            self.animator.removeBehavior(self.gravity)
        }
        
        // Delay snapping tiles back to positions until after the tiles have departed
        var timer = 0.2
        let delay = timer * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            
            timer = 0.1
            for tile in self.lettertiles {
                timer += 0.1
                let delay = timer * Double(NSEC_PER_SEC)
                let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    tile.snapBehavior = UISnapBehavior(item: tile, snapTo: (tile.letter?.position?.position)!)
 
//                    // To do an action on every frame
//                    tile.snapBehavior?.action = {
//                        () -> Void in
//                        print("action")
//                    }
                    
                    self.animator.addBehavior(tile.snapBehavior!)
                    self.collider.removeItem(tile)  // keeps the letters from getting stuck on each other.
                    self.saveContext()
                }
            }
        }
        
        //        for tile in lettertiles {
        for i in 0 ..< lettertiles.count {
            
            // add a push in a random but up direction
            // taking into account that 0 (in radians) pushes to the right, and we want to vary between about 90 degrees (-1.57 radians) to the left, and to the right
            // direction should be between ~ -3 and 0. or maybe ~ -.5 and -2.5 (needs fine tuning)
            let direction = -1.5 * drand48() - 0.9
            let push = UIPushBehavior(items: [lettertiles[i]], mode: .instantaneous)
            push.angle = CGFloat(direction)
            push.magnitude = CGFloat(7.0 * drand48() + 7.0)
            animator.addBehavior(push)
            
            // add gravity to each tile
            collider.addItem(lettertiles[i])
            gravity.addItem(lettertiles[i])
            dynamicItemBehavior.addItem(lettertiles[i])
        }
    }
    
    // MARK: - NSFetchedResultsController vars
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
        fetchRequest.predicate = NSPredicate(format: "inCurrentList == %@", true as CVarArg)
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "word", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = tableViewsDelegate

        return fetchedResultsController
    }()
 
    // MARK:- Notifications
    
    // Present definition when a word is tapped
    @objc func presentDefinition(_ notification: Notification) {
        if let pop = notification.userInfo?["item"] as? DefinitionPopoverVC {
            self.present(pop, animated: true, completion: nil)
        }
    }
    
    @objc func updateCurrentNumberOfWords(_ notification: Notification) {
        if let cnow = notification.userInfo?["item"] as? Int {
            currentNumberOfWords = cnow
        }
    }
    
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //uiDynamicsDelegate = AtoZUIDynamicsDelegate()
        NotificationCenter.default.addObserver(self, selector: #selector (presentDefinition(_:)), name: NSNotification.Name(rawValue: "PresentDefinition"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (updateCurrentNumberOfWords(_:)), name: NSNotification.Name(rawValue: "UpdateCNOW"), object: nil)

        //tableViewsDelegate = AtoZTableViewDelegates()
        wordTable.delegate = tableViewsDelegate
        proxyTable.delegate = tableViewsDelegate
        wordTable.dataSource = tableViewsDelegate
        proxyTable.dataSource = tableViewsDelegate
        tableViewsDelegate.wordTable = wordTable
        tableViewsDelegate.wordTableHeaderCoverHeight = wordTableHeaderCoverHeight
        tableViewsDelegate.wordTableFooterCoverHeight = wordTableFooterCoverHeight
        tableViewsDelegate.proxyTable = proxyTable
        tableViewsDelegate.proxyTableArrow = proxyTableArrow
        tableViewsDelegate.fetchedResultsController = fetchedResultsController
        
        proxyTable.proxyTableArrow = proxyTableArrow
        
        //wordTable.tableHeaderView = wordTableHeaderView
        tableViewsDelegate.wordTableHeaderCover = wordTableHeaderCover
        tableViewsDelegate.gradient = mainGradient
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        game = model.game

        // save the center of the wordTableHolderView, so that it can be used as snap position, to keep the wordTableHolderView in place after it is jostled by moving tiles.
        wordHolderCenter = wordTableHolderView.center
        
        // constants allow the tiles to be anchored at desired location
        // vary vertiShift based on view height, to adjust per device
        // for 4s:      -475    480
        // for 5s:      -500    568
        // for 6:       -530    667
        // for 6s plus: -540    736
        // TODO: also fine tune horiz. position
        //let vertiShift = -475 - ((view.frame.size.height - 480) * 0.25)
        let vertiShift = (-0.25 * view.frame.size.height) - 355
        let tilesAnchorPoint = model.calculateAnchor(view.frame.size.width + 90.0, areaHeight: view.frame.size.height, vertiShift: vertiShift)
        model.updateLetterPositions() // needed to get the view bounds first, and then go back to the model to update the Positions
        // Set positions here, to the sorted array position from the model
        //(Confusing because model.game.positions is a Set
        positions = model.positions
        
        // Adjust the constraints for the Tile UI background elements
        topConstraint.constant = tilesAnchorPoint.y + CGFloat(120.0) - 0.5 * wordInProgress.frame.height
        inProgressLeading.constant = tilesAnchorPoint.x - 0.5 * wordInProgress.frame.width
        
        //scrollingSlider.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * 0.5))
        
        lettertiles = [Tile]()
        tilesToSwap = [Tile]()
        
        // Set Delegates
        animator = UIDynamicAnimator(referenceView: view)
        animator.delegate = uiDynamicsDelegate
        
        let bgImage = UIImage(named: "tile_bg") as UIImage?
        
        for i in 0 ..< 7 {
            //TODO: move some of this stuff to init for Tile
            //TODO: use the eventual tile positions
            if let tilePos = positions?[i].position {
                let tile = Tile(frame: CGRect(x: tilePos.x, y: tilePos.y * CGFloat(i), width: 50, height: 50))
                let bgView = UIImageView(image: bgImage)
                bgView.tag = 2000 + i
                bgView.center = tilePos
                
                tile.setTitle("Q", for: UIControlState()) // Q is placeholder value
                tile.tag = 1000 + i
                
                lettertiles.append(tile)
                setupGestureRecognizers(tile)
                view.addSubview(bgView)
                view.addSubview(tile)
            }
        }
        
        let upperPositionsBg = UIImage(named: "upper_positions_bg") as UIImage?
        let upperPositionsView = UIImageView(image: upperPositionsBg)
        upperPositionsView.alpha = 0.75
        upperPositionsView.center = CGPoint(x: tilesAnchorPoint.x, y: tilesAnchorPoint.y + 120)
        view.addSubview(upperPositionsView)
        // Make sure all tiles have higher z index than all bg's. Also when tapped
        for t in lettertiles {
            view.bringSubview(toFront: t)
        }
        // reference for memory leak bug, and fix:
        // http://stackoverflow.com/questions/34075326/swift-2-iboutlet-collection-uibutton-leaks-memory
        //TODO: check for memory leak here
        
        checkForExistingLetters()
        updateTiles()
        generateWordList()
        startNewList.alpha = 0
        startNewList.isHidden = true
        
        mainGradient = model.yellowPinkBlueGreenGradient()
        mainGradient?.frame = view.bounds
        mainGradient?.zPosition = -1
        mainGradient?.name = "mainGradientLayer"
        view.layer.addSublayer(mainGradient!)
        //tableViewsDelegate.gradient = mainGradient
        //let indexPath = IndexPath(row: 0, section: 0)
        //wordTableHeaderView.layer.addSublayer(mainGradient!)
        
        collisionBehavior = UICollisionBehavior(items: [])
        for tile in lettertiles {
            if (tile.boundingPath) != nil {
                collisionBehavior.addBoundary(withIdentifier: "tile" as NSCopying, for: tile.boundingPath!)
            }
        }
        animator.addBehavior(collisionBehavior)
    }
    
//    func updateSizeForHeaderView(inTableView tableView : UITableView) {
//        let size = wordTableHeaderView.systemLayoutSizeFitting(wordTable.frame.size, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
//        wordTableHeaderView.frame.size = size
//        print(size)
//    }
//
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        updateSizeForHeaderView(inTableView: wordTable)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uiDynamicsDelegate?.lettertiles = lettertiles
        
        //setUpProxyTable()
    }
    
    func setUpProxyTable () {
        let arrowImage = UIImage(named: "icon_newlist")
        let imageView = UIImageView(image: arrowImage)
        proxyTable.addSubview(imageView)
        imageView.contentMode = .redraw
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if game?.data?.fillingInBlanks == true {
            fillingInBlanks = true
            updateProgress("Filled")
            wordListCompleted()
        } else {
            updateProgress(nil)
        }
        // Thank you Aaron Douglas for showing how to turn on the cool fields of lines that visualize UIFieldBehaviors!
        // https://astralbodi.es/2015/07/16/uikit-dynamics-turning-on-debug-mode/
        //animator.setValue(true, forKey: "debugEnabled")
        
        // When first loading, add a basic info panel about the game, with a dismiss button
        // TODO: enable dismiss by tapping anywhere
        // TODO: customize the info vc animation
        // TODO: blur the background behind the info view controller
        if game?.data?.gameState == 0 {
            //animator.removeAllBehaviors()
            game?.data?.gameState = 1 // set to state where info window is not shown
            saveContext()
            

                let infoViewController = storyboard?.instantiateViewController(withIdentifier: "Intro") as! IntroViewController
            
                // pass end points of arrows in
                infoViewController.modalPresentationStyle = .overCurrentContext
                infoViewController.arrowEndPoints = arrowEndPoints
                // let time = DispatchTime.now() + 3.35
                //  DispatchQueue.main.asyncAfter(deadline: time) {
                self.present(infoViewController, animated: true)
       // }


           // }
        }
    }
    
    override func viewDidLayoutSubviews() {
        // create arrow end points here
        arrowEndPoints.append(wordInProgress.center)
        arrowEndPoints.append(wordTable.center)
        arrowEndPoints.append(toolbar.center)
    }
    
    // note: as of ios 9, supposed to be that observers will be removed automatically
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        saveContext()
    }
    
    deinit {
        print("AtoZ De-init")
    }
    
    //MARK:- Tile Swapping
    
    // Each letter should have a position
    func swapTile(_ tile: Tile) {
      
        animator.removeAllBehaviors()
        for anyTile in lettertiles {
            animator.addBehavior(anyTile.snapBehavior!)
        }
        
        // add slight delay to give time for the positions to be updated and saved to context
        // TODO: use completion handler instead of a delay every single time
        //delay(0.15) { // still sometimes moves to a lower pos when an upper is open, and should be moved to
            let newPosition = self.findVacancy(tile)
            
            
            if newPosition != nil { // if newPosition is nil, then all spaces are occupied, and nothing happens
                
                
                // update the Positions
                let previousPosition = tile.letter?.position
                
                previousPosition?.letter = nil // the previous position is now vacant
                
                tile.letter?.position = newPosition
                
                // Tiles drop slightly from gravity unless it's removed here. Gravity is added each time the tiles are jumbled anyway.
                self.animator.removeBehavior(self.gravity)
                
                //self.saveContext() // safest to save the context here, after every letter swap
                
                self.saveContext() { success in
                    if success {
                
                    tile.snapBehavior?.snapPoint = (newPosition?.position)!

                    self.checkUpperPositionsForWord() // moved here from tileTapped, so it runs after the delay
                }
            }
        }
    }
    
    // TODO:  safer unwrapping
    func swapTile() {
        let tile = tilesToSwap![0]
        tilesToSwap?.removeFirst()
        
        animator.removeAllBehaviors()
        for anyTile in lettertiles {
            animator.addBehavior(anyTile.snapBehavior!)
        }
        
        
        let newPosition = self.findVacancy(tile)
        
        if newPosition != nil { // if newPosition is nil, then all spaces are occupied, and nothing happens
            
            // update the Positions
            let previousPosition = tile.letter?.position
            
            previousPosition?.letter = nil // the previous position is now vacant
            
            tile.letter?.position = newPosition
            
            // Tiles drop slightly from gravity unless it's removed here. Gravity is added each time the tiles are jumbled anyway.
            self.animator.removeBehavior(self.gravity)
            
            //self.saveContext() // safest to save the context here, after every letter swap
            
            self.saveContext() { success in
                if success {
                    guard let pos = newPosition?.position else {
                        // handle error
                        return
                    }
                    tile.snapBehavior?.snapPoint = pos//(newPosition?.position)!
                    
                    self.checkUpperPositionsForWord()
                    
                    
                    if (self.tilesToSwap?.count)! > self.maxTilesToSwap {
                        self.maxTilesToSwap = (self.tilesToSwap?.count)!
                    }
                    // in case another tile is in the Q to swap, run this func again
                    //TODO: check whether this is ever called
                    if (self.tilesToSwap?.count)! > 0 {

                        self.swapTile()
                    }
                }
            }
        }
    }

    //TODO: refactor the 3 swap tile funcs to not repeat code
    // in the case that we already know the position
    func swapTileToKnownPosition(_ tile: Tile, pos: Position) {
        // update the Positions
        let previousPosition = tile.letter?.position
        
        previousPosition?.letter = nil // the previous position is now vacant
        tile.letter?.position = pos
        tile.snapBehavior?.snapPoint = pos.position

        saveContext() // safest to save the context here, after every letter swap
    }
    
    func findVacancy(_ tile: Tile) -> Position? {
            
            if tile.letter != nil { // tile.letter should never be nil, so this is an extra, possibly unneeded, safeguard. Which doesn't seem to work anyway.
                // tile is in lower position, so look for vacancy in the uppers
                if (tile.letter?.position!.index)! < 7 {
                    for i in 7 ..< 10 {
                        if self.positions![i].letter == nil {
                            self.collisionBehavior.addItem(tile) // enable collisions only for tiles when they are in 7 8 or 9
                            return positions![i]
                        }
                    }
                    return nil
                } else { // must be in the upper positions, so look for a vacancy in the lowers
                    
                    //TODO: verify that .stride is working correctly
                    // for var i=6; i>=0; i -= 1 {
                    for i in stride(from: 6, through: 0, by: -1) {
                        //for i in (0 ..< 6).reversed() {
                        
                        if self.positions![i].letter == nil {
                            self.collisionBehavior.removeItem(tile)
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
    
// added paramater 'first' only so #selector is recognized above - compiler can't disambiguate parameterless method
    @objc func dismiss(first: Bool) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:-Tests
    // print out a diagram to see the state of the Tiles and Positions
    
    func printTileDiagram() {
        for i in 0 ..< lettertiles.count {
            //print("\(i): \(lettertiles[i].titleLabel!.text!)    \(lettertiles[i].letter!.position!.index)   \(lettertiles[i].letter!.position!.position)    \(lettertiles[i].snapBehavior!.snapPoint)")
            print("   \(lettertiles[i].letter!.position!.index)   \(lettertiles[i].letter!.position!.position)    \(lettertiles[i].snapBehavior!.snapPoint)")
            
        }
        print("====================================")
        print("")
        print("")
    }
    
    // Progress update //TODO: should these vars be stored to avoid recalc each word?
    func updateProgress(_ message: String?) {
        progressLabl.alpha = 1.0
        if message != nil {
            progressLabl.text = message
        } else {
            let numFound = currentNumFound()
            if currentNumberOfWords != nil && model.inactiveCount != nil {
                if numFound == currentNumberOfWords! - model.inactiveCount! {
                    // TODO: make wordListCompleted func
                    wordListCompleted()
//                    animateStatusHeight(80.0)
//                    progressLabl.text = "Word List Completed!"
//                    animateNewListButton()
                } else {
                    progressLabl.text = "\(numFound) of \(currentNumberOfWords! - model.inactiveCount!) words found"
                }
            }
        }
        UIView.animate(withDuration: 2.35, delay: 0.25, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            
            self.progressLabl.alpha = 0.85
            
            }, completion: { (finished: Bool) -> Void in
                
        })
    }
    
    func wordListCompleted () {
        animateStatusHeight(80.0)
        progressLabl.text = "Word List Completed!"
        animateNewListButton()
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
    
    @IBAction func generateNewWordlist(_ sender: AnyObject) {
        generateNewWordlist()
    }
    
    // This is where stats for a word are tracked (numTimesFound, numTimesPlayed)
    //TODO:-- move tracking to separate func?
    func generateNewWordlist() {

        // still needed here? calling again later
        game?.data?.level = model.calculateLevel()
        // print("levelFromModel: \(String(describing: game?.data?.level))")
        
        startNewList.alpha = 0
        startNewList.isHidden = true
        returnTiles() // if any tiles are in the upper positions, return them
        // Generating a new list, so first, set all the previous Words 'found' property to false
        // and, if the found property is true, first add 1 to the numTimesFound property
        
        for i in 0 ..< fetchedResultsController.fetchedObjects!.count {
            let indexPath = IndexPath(row: i, section: 0)
            if let word = fetchedResultsController.object(at: indexPath) as? Word {
                
                // check for active or not
                if word.active == true {
                    word.numTimesPlayed += 1 // the # times the game has put that word into play
                    if word.found == true { // should work whether or no fillingInBlanks
                        word.numTimesFound += 1
                    }
                } else { // Word was inactive for this round
                    print("Word was inactive: Level for \(word.word!): \(word.level)")
                    // Inactive words add to neither numTimesPlayed nor numTimesFound
                    word.active = true // reset all inactive words to inactive -- changes with each round
                }
                // reset values as the previous words are removed from the current list
                word.found = false
                word.inCurrentList = false
            }
        }
        
        fillingInBlanks = false
        game?.data?.fillingInBlanks = fillingInBlanks
        saveContext()
        
        // TODO: needed to set here? // fillingInBlanks = false // reset to false
        
        // Now that the results of the previous round have been saved, create a new set of letters
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
        
        let levelFromModel = model.calculateLevel()
        game?.data?.level = levelFromModel
        print("levelFromModel: \(levelFromModel)")
        
        saveContext()

        let percentage = model.percentageFound()
        print("percentage: \(percentage)")
        let numListsPlayed = model.numListsPlayed()
        
        var numWordsFound = 0
        if let numWords = model.numWordsFound() {
            numWordsFound = numWords
        }
        
        reportScores(levelFromModel, percentage: percentage, numberOfLists: numListsPlayed, numberOfWords: numWordsFound)
        
    }

    //MARK:-Tile Tapped
    // replaces addLetterToWordInProgress(sender: Tile)
    
    //TODO: instead of swapping the tile right away, check if a flag for a previous tileTap is true, if so, save the tile, wait until the context has been saved in swapTile, and then swap this new tile
    
    // Create an array of Tiles to hold any tiles that are tapped, and waiting in line to be swapped
    
    @IBAction func tileTapped(_ gesture: UIGestureRecognizer) {
        if let tile = gesture.view as? Tile {
            
            tilesToSwap?.append(tile)
            
            // add the new letter to the word in progress
            
            // if the flag that last tile has been finished is true, then:
            //swapTile(tile) // swapping whichever tile is tapped
            // otherwise, add a very slight delay first
            
            swapTile()
            
            // then, check for a valid word
            // but iff 7 8 and 9 are occupado, then check for valid word
//            checkUpperPositionsForWord() // moved to findVacancy(), so it can be inside the delay
            // TODO: use a completion handler, so this line can be moved back to here
        }
    }
    
    // need to incorporate this into func above this one (and consolidate with checkForValidWord)
    func checkUpperPositionsForWord () {
        if fillingInBlanks == false { // Check if the user has tapped Fill in the Blanks button
            if positions![7].letter != nil && positions![8].letter != nil && positions![9].letter != nil {
                let wordToCheck = (positions![7].letter?.letter)! + (positions![8].letter?.letter)! + (positions![9].letter?.letter)!
                let wordIsValid = checkForValidWord(wordToCheck)
                
                if wordIsValid { // return the letters to the letter pool
                    let time = DispatchTime.now() + 0.35
                    DispatchQueue.main.asyncAfter(deadline: time) {
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
    }
    
    func checkForValidWord(_ wordToCheck: String) -> Bool {
        
        var wordIsNew = false
        guard let numberOfWords = currentNumberOfWords else {
            return false
        }
        for i in 0 ..< numberOfWords {
            let indexPath = IndexPath(row: i, section: 0)
            let aValidWord = fetchedResultsController.object(at: indexPath) as! Word
            if wordToCheck == aValidWord.word {
                // 3 cases:
                // 1. word is inactive word.found==false && word.active==false
                // 2. word has already been found  word.found==true && word.active==true
                // 3. word has been found for the first time   word.found==false && word.active==true
                
                if aValidWord.found == true { // case 2
                    updateProgress("Already found \(wordToCheck)")
                } else if aValidWord.active == false { // case 1
                    updateProgress("\(wordToCheck) – already mastered!")
                } else { // case 3
                    aValidWord.found = true
                    wordIsNew = true
                    saveContext()
                }
                
                // Needed to wait until after .found was set before updateProgress, otherwise the newly found word isn't counted
                // But conditional, so we don't overwrite the "Already found.." message
                if wordIsNew == true {
                    updateProgress(nil)
                }
                wordTable.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
                proxyTable.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
                
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
    

    // Pass text info to blurred background VC's
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let bubble = segue.destination as? BlurViewController else {
            return
        }

        if segue.identifier == "BlurredStatusBG" {
            blurredViews.append(bubble)
            // Since we do not know in which order the controllers are added to blurredViews,
            // set the index to the element just added to the array
            let index = blurredViews.count - 1
            blurredViews[index].shadowRadius    = 2.4
            blurredViews[index].shadowOpacity   = 0.6
            blurredViews[index].borderWidth     = 0.2
        }
    }
    
    func checkForExistingLetters () {
        // if there is a saved letterset, then use that instead of a new one
        game = model.fetchGame()
        if let fib = game?.data?.fillingInBlanks {
            fillingInBlanks = fib
        }
        if game?.data?.currentLetterSetID == nil {
            currentLetterSet = model.generateLetterSet()
        } else {
            // there is a currentLetterSet, so let's find it
            let lettersetURI = URL(string: (game?.data?.currentLetterSetID)!)
            let id = sharedContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: lettersetURI!)
            do {
                currentLetterSet = try sharedContext.existingObject(with: id!) as? LetterSet

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
        
        // Safeguard in case the correct number of letters has not been saved properly
        if letters.count != lettertiles.count {
            currentLetterSet = model.generateLetterSet()
            saveContext()
            letters = currentLetterSet?.letters?.allObjects as! [Letter]
        }
        
        // Possible fonts
        //BanglaSangamMN-Bold //EuphemiaUCAS-Bold //GillSans-SemiBold //Copperplate-Bold
        
        let attributes: [NSAttributedStringKey: Any] =  [.font: UIFont(name: "EuphemiaUCAS-Bold", size: 30.0)!,
                                                .foregroundColor: Colors.midBrown,
                                                .strokeWidth: -3.0 as AnyObject,
                                                .strokeColor: UIColor.black]

        for i in 0 ..< lettertiles.count {
            
            // TODO: set the attributed title in Tile.swift instead
            let title = NSAttributedString(string: letters[i].letter!, attributes: attributes)
            lettertiles[i].setAttributedTitle(title, for: UIControlState())
            lettertiles[i].letter = letters[i]
            lettertiles[i].position = letters[i].position?.position
            
            lettertiles[i].letter!.position = positions![i]
            
            if lettertiles[i].snapBehavior != nil {
                // update the snapPoint
                lettertiles[i].snapBehavior?.snapPoint = (lettertiles[i].letter?.position?.position)!
            } else { // Add snap behavior to Tile, but only if it doesn't already have one
            //if lettertiles[i].snapBehavior == nil {
                lettertiles[i].snapBehavior = UISnapBehavior(item: lettertiles[i], snapTo: lettertiles[i].letter!.position!.position)
                lettertiles[i].snapBehavior?.damping = 0.6
                animator.addBehavior(lettertiles[i].snapBehavior!)
            }
        }
        
        saveContext() // Tile is not in the context, but letter.position is
    }
    
    func fillInTheBlanks() {
        fillingInBlanks = true
        // 'Cheat' function, to fill in unanswered words
        //for var i=0; i<currentNumberOfWords; i += 1 {
        for i in 0 ..< currentNumberOfWords! { //TODO: unwrap currentNumberOfWords safely
            let indexPath = IndexPath(row: i, section: 0)
            let aValidWord = fetchedResultsController.object(at: indexPath) as! Word
            
            if aValidWord.found == false {
                // fill in the word with red tiles
                aValidWord.found = true // need to switch this to something else that will trigger configureCell
                aValidWord.found = false
            } else {
                
            }
        }
        animateStatusHeight(80.0)
        progressLabl.text = "\(currentNumFound()) of \(currentNumberOfWords! - model.inactiveCount!) words found"
        animateNewListButton()
        game?.data?.fillingInBlanks = true
        saveContext()
    }
    
//    //TODO: layout the Tiles which are not using autolayout
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//    }
    
    //MARK:- Tapping and Panning for Tiles
    func setupGestureRecognizers(_ tile: Tile) {
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tileTapped(_:)))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panTile(_:)))
        
        tapRecognizer.delegate = gestureDelegate
        panRecognizer.delegate = gestureDelegate
        
        tile.addGestureRecognizer(tapRecognizer)
        tile.addGestureRecognizer(panRecognizer)
        
        panRecognizer.require(toFail: tapRecognizer)
    }
    
    //TODO:-set up custom behaviors as separate classes
    @objc func panTile(_ pan: UIPanGestureRecognizer) {
        
        animator.removeAllBehaviors()
        
        let t = pan.view as! Tile
        let location = pan.location(in: self.view)
//        let startingLocation = location
//        let sensitivity: Float = 10.0
        
        switch pan.state {
        case .began:
            print("Began pan")
            //animator?.removeBehavior(t.snapBehavior!) //TODO: behavior not being removed, and fighting with pan.
            //TODO:-- each remove behavior, and/or, use attachment behavior instead of pan, as in WWDC video
            t.superview?.bringSubview(toFront: t) // Make this Tile float above the other tiles
            t.layer.shadowOpacity = 0.85
            let scale = CGAffineTransform(scaleX: 1.25, y: 1.25)
            let move = CGAffineTransform(translationX: 0.0, y: -58.0)

            UIView.animate(withDuration: 0.15, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                
                t.transform = scale.concatenating(move)
                
                }, completion: { (finished: Bool) -> Void in
                    //hasFinishedBeganAnimation = finished
                    //print("ani done")
            })

        case .changed:
            t.center = location
            
        case .ended:
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
            // check for the nearest unoccupied position, and snap to that
            
            //TODO:- if tile is moved only very very slightly, move it back to original position
            // but problem: no way to determine if user meant to move and let it snap back, or if user meant to tap
            // hypothesis: if movement is tiny, user meant to tap, so should move to upper/lower position
            // if movement is small but not tiny, indicates intention to start to pan, and then decided to stop
            // so move back to original position

            if let closestOpenPosition = model.findClosestPosition(location, positionArray: positions!) {
                swapTileToKnownPosition(t, pos: closestOpenPosition)
                checkUpperPositionsForWord()
            }
            
            // seemed to have extra snapping behaviors interfering, so removed all behaviors, and added back here.
            for tile in lettertiles {
                animator.addBehavior(tile.snapBehavior!)
            }
            t.layer.shadowOpacity = 0.0
            t.transform = CGAffineTransform.identity
            
        default:
            break
        }
    }
    
    //MARK:- Animations

    func animateTile(_ sender: AnyObject) {
        
        _ = [UIView.animate(withDuration: 5.0, delay: 0.0, options: [.curveLinear, .allowUserInteraction], animations: {
            }, completion: nil)]
    }
    
    func animateStatusHeight(_ ht: CGFloat) {
        animatingStatusHeight = true
//        if self.blurredViews.count > 0 {
//            blurredViews[0].animatingStatusHeight = true
//        }
        UIView.animate(withDuration: 0.4 , animations: {
            self.statusBgHeight.constant = ht
            self.blurredViewHeight.constant = ht
            self.view.layoutIfNeeded()
        }, completion: {completion in
//            self.animatingStatusHeight = false
//            print(self.animatingStatusHeight)
//            if self.blurredViews.count > 0 {
//                self.blurredViews[0].animatingStatusHeight = false
//            }
        })
    }
    
    func animateNewListButton() {
        UIView.animate(withDuration: 0.9, animations: {
            self.startNewList.isHidden = false
            self.startNewList.alpha = 1.0
            self.view.layoutIfNeeded()
        }) 
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
    
    // save context with completion handler
    func saveContext (_ completion: (_ success: Bool)-> Void) {
        if sharedContext.hasChanges {
            do {
                try sharedContext.save()
                completion(true)
            } catch {
                let nserror = error as NSError
                print("Could not save the Managed Object Context")
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                completion(false)
            }
        }
    }
    
    // MARK:- Delay function
    //http://www.globalnerdy.com/2015/09/30/swift-programming-tip-how-to-execute-a-block-of-code-after-a-specified-delay/
    func delay(_ delay: Double, closure: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
}



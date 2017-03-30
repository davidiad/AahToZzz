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

class AtoZViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, UICollisionBehaviorDelegate, UIDynamicAnimatorDelegate {
    
    private func testAlamoFire() {
        print (" Alamofire version: \(AlamofireVersionNumber)")
           }

    
    // MARK: - Unwind segue from Progress view
    @IBAction func cancelToProgressViewController(segue:UIStoryboardSegue) {
    }
    
    //TODO: When proxy scroll (invisible scrolling table on right, synced to table on left) is touched, show custom scroll indicator. Also show vertical bar with progress?
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == proxyTable {
            wordTable.setContentOffset(proxyTable.contentOffset, animated: false)
        }
//        if scrollView == wordTable {
//            proxyTable.setContentOffset(wordTable.contentOffset, animated: false)
//        }
    }
    
    let gravity = UIGravityBehavior()
    
    var model = AtoZModel.sharedInstance //why not let?
    var letters: [Letter]! //TODO: why not ? instead of !
    var wordlist = [String]()
    var positions: [Position]?
    var wordHolderCenter: CGPoint?
    var tileBackgrounds = [UIView]?()
    
    @IBOutlet weak var progressLabl: UILabel!
    
    var game: Game?
    var currentLetterSet: LetterSet?
    var currentWords: [Word]?
    
    var currentNumberOfWords: Int?
    var currentNumberOfActiveWords: Int?
    
    var fillingInBlanks: Bool = false // flag for configuring cells when Fill in the Blanks button is touched
    
    @IBOutlet weak var wordTableHolderView: UIView!
    @IBOutlet weak var wordTable: UITableView!
    @IBOutlet weak var proxyTable: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var lettertiles: [Tile]! // created in code so that autolayout done't interfere with UI Dynamcis
    var tilesToSwap: [Tile]? // an array to temporarilly hold the tiles waiting to be swapped
    var maxTilesToSwap: Int = 0 // temp. diagnostic
    @IBOutlet weak var wordInProgress: UILabel!
    @IBOutlet weak var startNewList: UIButton!
    
    
    @IBAction func returnTiles(sender: AnyObject) {
        returnTiles()
    }
    
    @IBAction func fillWordList(sender: AnyObject) {
        fillInTheBlanks()
    }
    
    @IBAction func autoFillWords(sender: AnyObject) {
        fillInWords("Auto Found the words")
    }
    
    @IBAction func autoFillMultiple(sender: AnyObject) {
        for i in 0 ..< 100 {
            fillInWords("AutoFind x \(i+1)")
            generateNewWordlist()
        }
    }
    
    // helper for autoFill
    func fillInWords(message: String) {
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

    lazy var collider:UICollisionBehavior = {
        let lazyCollider = UICollisionBehavior()
        lazyCollider.collisionDelegate = self
        // This line, makes the boundaries of our reference view a boundary
        // for the added items to collide with.
        lazyCollider.translatesReferenceBoundsIntoBoundary = true
        return lazyCollider
    }()
    
    // This function will be called with every and each collision starts between all the views added to our collision behavior.
//    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint){
//        
//        // We're only interested in collisions with the black circle (snappingCircle).
//        if (item1 as? UIView)?.tag >= 2000 {
//            print("Collides!: \((item1 as? UIView)?.tag) and \((item2 as? UIView)?.tag)")
//        }
//    }
    
    lazy var dynamicItemBehavior:UIDynamicItemBehavior = {
        let lazyBehavior = UIDynamicItemBehavior()
        // Let's make our square elastic
        // 0 = no elacticity, 1.0 = max elacticity
        lazyBehavior.elasticity = 0.5
        
        // Other configurations
        lazyBehavior.allowsRotation = true
        // lazyBehavior.density
        lazyBehavior.friction = 0.3
        lazyBehavior.resistance = 0.5
        
        return lazyBehavior
    }()
    
    lazy var uiDynamicItemBehavior:UIDynamicItemBehavior = {
        let lazyBehavior = UIDynamicItemBehavior()
        // Let's make our square elastic
        // 0 = no elacticity, 1.0 = max elacticity
        lazyBehavior.elasticity = 0.0
        
        // Other configurations
        lazyBehavior.allowsRotation = false
        lazyBehavior.density = 5500.0
        lazyBehavior.friction = 5110.00
        lazyBehavior.resistance = 5110.0
        
        return lazyBehavior
    }()
    
//    lazy var dynamicItemBehavior_tile0:UIDynamicItemBehavior = {
//        let lazyBehavior = UIDynamicItemBehavior()
//        // Let's make our square elastic
//        // 0 = no elacticity, 1.0 = max elacticity
//        lazyBehavior.elasticity = 1.0
//        
//        // Other configurations
//        lazyBehavior.allowsRotation = true
//        lazyBehavior.density = 300.0
//        lazyBehavior.friction = 0.0
//        lazyBehavior.resistance = 0.0
//        
//        return lazyBehavior
//    }()
    
    @IBAction func jumbleTiles(sender: AnyObject) {
        
        // find the current positions of the letters
        // randomize the positions of the letters
        // later, snap to those positions
        let sevenRandomizedInts = model.randomize7()
        for j in 0 ..< 7 {
            
            // There are 10 Positions, not 7. Tiles in the upper positions (7,8,9) will be returned to lower positions
            letters[j].position = positions![sevenRandomizedInts[j]]
        }
        saveContext() // TODO: Need dispatch async?
        for tile in lettertiles {
            let s = CGAffineTransformMakeScale(0.75, 0.75)
            print("ZPos: \(tile.layer.zPosition) and tag: \(tile.tag)")
//            tile.transform = s
        
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            tile.transform = s//CGAffineTransformConcat(scale, move)
            
            }, completion: { (finished: Bool) -> Void in
                //hasFinishedBeganAnimation = finished
                //print("ani done")
        })
        }
        jumbleTiles()
        
//        // Jumble a 2nd time, after a slight delay
//        let timer = 1.5
//        let delay = timer * Double(NSEC_PER_SEC)
//        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//        dispatch_after(time, dispatch_get_main_queue()) {
//            for tile in self.lettertiles {
////                tile.snapBehavior?.snapPoint = (tile.letter?.position?.position)!
//                //tile.frame = CGRect(origin: (tile.letter?.position?.position)!, size: tile.frame.size)
//            }
//            //self.jumbleTiles()
//        }
        
        /*
        // find the current positions of the letters
        // randomize the positions of the letters
        // later, snap to those positions
        let sevenRandomizedInts = model.randomize7()
        for j in 0 ..< 7 {

            // There are 10 Positions, not 7. Tiles in the upper positions (7,8,9) will be returned to lower positions
            letters[j].position = positions![sevenRandomizedInts[j]]

        }
        saveContext() // TODO: Need dispatch async?
        
        // animator.setValue(true, forKey: "debugEnabled") // uncomment to see dynamics reference lines
        animator.removeAllBehaviors() // reset the animator
        
        uiDynamicItemBehavior.addItem(toolbar)
        animator.addBehavior(gravity)
        animator.addBehavior(collider)
        animator.addBehavior(dynamicItemBehavior)
        animator.addBehavior(uiDynamicItemBehavior)
        // add the scroll view that holds the word list as a collider
        //collider.addItem(wordTableHolderView)
        collider.addItem(toolbar)

        // Delay snapping tiles back to positions until after the tiles have departed
        var timer = 0.2
        let delay = timer * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {

            timer = 0.1
            for tile in self.lettertiles {
                timer += 0.1
                let delay = timer * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue()) {
                    tile.snapBehavior = UISnapBehavior(item: tile, snapToPoint: (tile.letter?.position?.position)!)
                    self.animator.addBehavior(tile.snapBehavior!)
                    self.collider.removeItem(tile)
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
            let push = UIPushBehavior(items: [lettertiles[i]], mode: .Instantaneous)
            //push.pushDirection = CGVectorMake(0, CGFloat(direction))
            push.angle = CGFloat(direction)
            push.magnitude = CGFloat(7.0 * drand48() + 7.0)
            animator.addBehavior(push)
            print(animator.running)
            
            // add gravity to each tile
            collider.addItem(lettertiles[i])
            gravity.addItem(lettertiles[i])
            dynamicItemBehavior.addItem(lettertiles[i])

        }
         */
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
        //collider.addItem(wordTableHolderView)
        collider.addItem(toolbar)
        
        // Need to turn off gravity after awhile, otherwise it moves the tiles out of position
        let gravityTimer = 1.0
        let gravityDelay = gravityTimer * Double(NSEC_PER_SEC)
        let gravityTime = dispatch_time(DISPATCH_TIME_NOW, Int64(gravityDelay))
        dispatch_after(gravityTime, dispatch_get_main_queue()) {
            self.animator.removeBehavior(self.gravity)
        }
        
        // Delay snapping tiles back to positions until after the tiles have departed
        var timer = 0.2
        let delay = timer * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            
            timer = 0.1
            for tile in self.lettertiles {
                timer += 0.1
                let delay = timer * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue()) {
                    tile.snapBehavior = UISnapBehavior(item: tile, snapToPoint: (tile.letter?.position?.position)!)
 
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
//            let scale = CGAffineTransformMakeScale(3.0, 3.0)
//            lettertiles[i].transform = scale
            
            // add a push in a random but up direction
            // taking into account that 0 (in radians) pushes to the right, and we want to vary between about 90 degrees (-1.57 radians) to the left, and to the right
            // direction should be between ~ -3 and 0. or maybe ~ -.5 and -2.5 (needs fine tuning)
            let direction = -1.5 * drand48() - 0.9
            let push = UIPushBehavior(items: [lettertiles[i]], mode: .Instantaneous)
            //push.pushDirection = CGVectorMake(0, CGFloat(direction))
            push.angle = CGFloat(direction)
            push.magnitude = CGFloat(7.0 * drand48() + 7.0)
            animator.addBehavior(push)
            print(animator.running)
            
            // add gravity to each tile
            collider.addItem(lettertiles[i])
            gravity.addItem(lettertiles[i])
            dynamicItemBehavior.addItem(lettertiles[i])
        }
    }
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var inProgressLeading: NSLayoutConstraint!
    
    @IBOutlet weak var statusBgHeight: NSLayoutConstraint!
    
    //MARK:- vars for UIDynamics
    
    lazy var center: CGPoint = {
        return CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
    }()


    
    private var animator: UIDynamicAnimator!
    private var attachmentBehavior: UIAttachmentBehavior!
    private var pushBehavior: UIPushBehavior!
    private var itemBehavior: UIDynamicItemBehavior!
    private var gravityBehavior = UIGravityBehavior()
    private var collisionBehavior = UICollisionBehavior()
    //private var blackhole = UIFieldBehavior!(nil) //for Swift 3, add nil inside parens
    
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
        
        animator = UIDynamicAnimator(referenceView: view)
        animator.delegate = self
        lettertiles = [Tile]()
        tilesToSwap = [Tile]()
        tileBackgrounds = [UIView]() // putting the tile bg's into an array so as to refer to them in collision detection
        let image = UIImage(named: "tile") as UIImage?
        let bgImage = UIImage(named: "tile_bg") as UIImage?
        
        for i in 0 ..< 7 {
            
            //let button   = UIButton(type: UIButtonType.Custom) as UIButton
            //TODO: move some of this stuff to init for Tile
            //TODO: use the eventual tile positions
            //lettertiles[i].letter!.position!.position
            if let tilePos = positions?[i].position {
                let tile = Tile(frame: CGRectMake(tilePos.x, tilePos.y * CGFloat(i), 50, 50))
                let bgView = UIImageView(image: bgImage)
                bgView.tag = 2000 + i
                tileBackgrounds?.append(bgView)
                bgView.center = tilePos
                tile.setBackgroundImage(image, forState: .Normal)
                tile.setTitleColor(UIColor.blueColor(), forState: .Normal)
                
                tile.setTitle("Q", forState: .Normal) // Q is placeholder value
                //tile.addTarget(self, action: "addLetterToWordInProgress:", forControlEvents:.TouchUpInside)
                tile.tag = 1000 + i
                
                lettertiles.append(tile)
                setupGestureRecognizers(tile)
                view.addSubview(bgView)
                view.addSubview(tile)
            }
        }
        let upperPositionsBg = UIImage(named: "upper_positions_bg") as UIImage?
        let upperPositionsView = UIImageView(image: upperPositionsBg)
        upperPositionsView.center = CGPointMake(tilesAnchorPoint.x, tilesAnchorPoint.y + 120)
        view.addSubview(upperPositionsView)
        // Make sure all tiles have higher z index than all bg's. Also when tapped
        for t in lettertiles {
            view.bringSubviewToFront(t)
        }
        // reference for memory leak bug, and fix:
        // http://stackoverflow.com/questions/34075326/swift-2-iboutlet-collection-uibutton-leaks-memory
        //TODO: check for memory leak here
        
        checkForExistingLetters()
        updateTiles()
        generateWordList()
        startNewList.alpha = 0
        startNewList.hidden = true
        
        
        let mainGradient = model.yellowPinkBlueGreenGradient()
        
        mainGradient.frame = view.bounds
        mainGradient.zPosition = -1
        mainGradient.name = "mainGradientLayer"
        view.layer.addSublayer(mainGradient)
        
        collisionBehavior = UICollisionBehavior(items: [])
        //collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        for tile in lettertiles {
            if (tile.boundingPath) != nil {
                collisionBehavior.addBoundaryWithIdentifier("tile", forPath: tile.boundingPath!)
            }
        }
        
        animator.addBehavior(collisionBehavior)
        
        testAlamoFire()
    }
    
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

    }
    

    
    // Each letter should have a position
    func swapTile(tile: Tile) {
        
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
                       // print("successful save")
                    //}
                
                    tile.snapBehavior?.snapPoint = (newPosition?.position)!

                    self.checkUpperPositionsForWord() // moved here from tileTapped, so it runs after the delay
                }
            }
        }
    }
    
    
    func swapTile() {
        print("In NEW SWAP TILE")
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

                    tile.snapBehavior?.snapPoint = (newPosition?.position)!
                    
                    self.checkUpperPositionsForWord()
                    if self.tilesToSwap?.count > self.maxTilesToSwap {
                        self.maxTilesToSwap = (self.tilesToSwap?.count)!
                    }
                    print("maxTilesToSwap: \(self.maxTilesToSwap)")
                    // in case another tile is in the Q to swap, run this func again
                    //TODO:- check whether this is ever called
                    if self.tilesToSwap?.count > 0 {

                        self.swapTile()
                    }
                }
            }
        }
        
    }

    
    
    
    //TODO: refactor the 3 swap tile funcs to not repeat code
    // in the case that we already know the position
    func swapTileToKnownPosition(tile: Tile, pos: Position) {
        print("in swapTileToKnownPosition")
        // update the Positions
        let previousPosition = tile.letter?.position
        
        previousPosition?.letter = nil // the previous position is now vacant
        tile.letter?.position = pos
        tile.snapBehavior?.snapPoint = pos.position

        saveContext() // safest to save the context here, after every letter swap
    }
    
    //MARK:- dynamic animator delegate
    var animatorBeganPause: Bool = false
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator){
        if !animatorBeganPause { // otherwise this is called continually
            print("Stasis! The universe stopped moving.")
            for tile in lettertiles {
                checkTilePosition(tile)
            }
            animatorBeganPause = true
        }
    }
    
    
    func dynamicAnimatorWillResume(animator: UIDynamicAnimator) {
        animatorBeganPause = false // reset
    }
    
    // Helper to see if tile has reached its position after dynamic animator has paused
    func checkTilePosition(tile: Tile) {
        // TODO: check if the position checking is working
        //animator.removeBehavior(tile.snapBehavior!)
        
        let tolerance: Float = 0.1
        guard let tilePosX = tile.letter!.position?.xPos else {
            return
        }
        let checkX = abs(Float(tile.frame.origin.x) - tilePosX)
        
        guard let tilePosY = tile.letter!.position?.yPos else {
            return
        }
        let checkY = abs(Float(tile.frame.origin.y) - tilePosY)
        
        
        if checkX > tolerance || checkY > tolerance {
            // The tile is not at its correct position, so move it to correct position
            
//            if let snap = tile.snapBehavior {
//                animator.addBehavior(snap)
//            }

            
//            tile.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
//                    tile.frame.origin = tile.position
//                    self.view.layoutIfNeeded()
//                }, completion: nil)
            
            
            
            
//            let animation = CABasicAnimation(keyPath: "position")
//            animation.fromValue = [tile.frame.origin.x, tile.frame.origin.y]
//            animation.toValue = [tilePosX, tilePosY]
//            
//            tile.layer.addAnimation(animation, forKey: "position")
            
            
            //let move = CGAffineTransformMakeTranslation(0.0, -90.0)
            
            UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                
                //t.transform = CGAffineTransformConcat(scale, move)
                //tile.transform = CGAffineTransformTranslate(move, 90, 90)
                //print("In Animation")
                
                
                //tile.transform = CGAffineTransformIdentity // this line is a safeguard in case tiles get rotated after a jumble. However, may not be needed, and was preventing enlarging the tiles during a pan (to make them appear raised above the others while panning)
                
                tile.center = (tile.letter?.position?.position)!
                
                }, completion: { (finished: Bool) -> Void in
            })
            
            
            
            
            //tile.center = (tile.letter?.position?.position)!
            
            
            
            
        }
        
    }
    //MARK:-
//    
//    func test (v: UIView) {
//        view.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
//            tile.frame.origin = tile.position
//            self.view.layoutIfNeeded()
//            }, completion: nil)
//    }
    
    func findVacancy(tile: Tile) -> Position? {
//        var position: Position?
//        let delay = 0.2 * Double(NSEC_PER_SEC)
//        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//        
//        dispatch_after(time, dispatch_get_main_queue()) {
            // delay, just so the previous one has time to finish
            
            
            if tile.letter != nil { // tile.letter should never be nil, so this is an extra, possibly unneeded, safeguard. Which doesn't seem to work anyway.
                // tile is in lower position, so look for vacancy in the uppers
                if tile.letter?.position!.index < 7 {
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
                    for i in 6.stride(through: 0, by: -1) {
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
//            return position
//        }
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
            if fillingInBlanks == true {
                
                if word.found == false && word.inCurrentList == true {
                    
                    setWordListCellProperties(cell, colorCode: -1, textcolor: Colors.reddish_white, text: word.word!)
                    
                    // hack for now TODO:-- single line outlines need to have a different shadow image than doubled lines
                    cell.outlineShadowView.image = UIImage(named: "outline_thick")
                    cell.outlineShadowView.alpha = 0.2
                }
            }
            
            if word.found == true && word.inCurrentList == true {
                if cell.word != nil { // may be unneeded safeguard
                    
                    setWordListCellProperties(cell, colorCode: word.level, textcolor: UIColor.blackColor(), text: word.word!)
                    
                    print("In configureCell: \(cell.word.text) at level \(word.level)")
                    
                    
                }
            }
            //TODO:-- Ensure that inactive words are being counted (or not counted) correctly
            if word.active == false {
                setWordListCellProperties(cell, colorCode: -2, textcolor: Colors.gray_text, text: word.word!)
                // hack for now TODO:-- single line outlines need to have a different shadow image than doubled lines
                cell.outlineShadowView.image = UIImage(named: "outline_thick")
                cell.outlineShadowView.alpha = 0.2
                print("INACTIVE, in configureCell: \(cell.word.text) at level \(word.level)")
                print(word)
                
            }

            
        }
    }
    
    //TODO: helper func for setting cell attributes
    func setWordListCellProperties(cell: WordListCell, colorCode: Int, textcolor: UIColor, text: String) {
        cell.colorCode = ColorCode(code: colorCode)
        cell.firstLetter.textColor = textcolor
        cell.secondLetter.textColor = textcolor
        cell.thirdLetter.textColor = textcolor
        cell.word.text = text // cell.word is a UILabel
        cell.wordtext = text // triggers didSet to add image and letters
        
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
        let btnDone = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(AtoZViewController.dismiss))
        navigationController.topViewController!.navigationItem.leftBarButtonItem = btnDone
        return navigationController
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    func updateProgress(message: String?) {
        progressLabl.alpha = 1.0
        if message != nil {
            progressLabl.text = message
        } else {
            let numFound = currentNumFound()
            if currentNumberOfWords != nil && model.inactiveCount != nil {
                if numFound == currentNumberOfWords! - model.inactiveCount! {
                    // TODO: make wordListCompleted func
                    animateStatusHeight(80.0)
                    progressLabl.text = "Word List Completed!"
                    animateNewListButton()
                } else {
                    progressLabl.text = "\(numFound) of \(currentNumberOfWords! - model.inactiveCount!) words found"
                }
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
        generateNewWordlist()
    }
    
    // This is where stats for a word are tracked (numTimesFound, numTimesPlayed)
    //TODO:-- move tracking to separate func?
    func generateNewWordlist() {
        model.findGameLevel()
        startNewList.alpha = 0
        startNewList.hidden = true
        returnTiles() // if any tiles are in the upper positions, return them
        // Generating a new list, so first, set all the previous Words 'found' property to false
        // and, if the found property is true, first add 1 to the numTimesFound property
        
        for i in 0 ..< fetchedResultsController.fetchedObjects!.count {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            if let word = fetchedResultsController.objectAtIndexPath(indexPath) as? Word {
                
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
        
        saveContext()
        
        fillingInBlanks = false // reset to false
        
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
    }

    
//    func requireGestureRecognizerToFail(otherGR: UIGestureRecognizer) {
//        
//    }
    //MARK:-Tile Tapped
    // replaces addLetterToWordInProgress(sender: Tile)
    
    //TODO: instead of swapping the tile right away, check if a flag for a previous tileTap is true, if so, save the tile, wait until the context has been saved in swapTile, and then swap this new tile
    
    // Create an array of Tiles to hold any tiles that are tapped, and waiting in line to be swapped
    
    @IBAction func tileTapped(gesture: UIGestureRecognizer) {
        print("in TileTapped")
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

//    // being replaced by tileTapped GR
//    //TODO:- remove this func if no longer being used
//    @IBAction func addLetterToWordInProgress(sender: Tile) {
//        swapTile(sender) // swapping whichever tile is tapped
//        // then, check for a valid word
//        // but iff 7 8 and 9 are occupado, then check for valid word
//        checkUpperPositionsForWord()
//    }
    
 
    // need to incorporate this into func above this one (and consolidate with checkForValidWord)
    func checkUpperPositionsForWord () {
        if fillingInBlanks == false { // Check if the user has tapped Fill in the Blanks button
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
    }
    
    func checkForValidWord(wordToCheck: String) -> Bool {
        
        var wordIsNew = false
        guard let numberOfWords = currentNumberOfWords else {
            return false
        }
        for i in 0 ..< numberOfWords {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let aValidWord = fetchedResultsController.objectAtIndexPath(indexPath) as! Word
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
        game = model.fetchGame()
        if game?.data?.currentLetterSetID == nil {
            //letters = model.generateLetters()
            currentLetterSet = model.generateLetterSet()
        } else {
            // there is a currentLetterSet, so let's find it
            let lettersetURI = NSURL(string: (game?.data?.currentLetterSetID)!)
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
        
        // Safeguard in case the correct number of letters has not been saved properly
        if letters.count != lettertiles.count {
            currentLetterSet = model.generateLetterSet()
            saveContext()
            letters = currentLetterSet?.letters?.allObjects as! [Letter]
        }
        for i in 0 ..< lettertiles.count {
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
    
    func fillInTheBlanks() {
        fillingInBlanks = true
        // 'Cheat' function, to fill in unanswered words
        //for var i=0; i<currentNumberOfWords; i += 1 {
        for i in 0 ..< currentNumberOfWords! { //TODO: unwrap currentNumberOfWords safely
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let aValidWord = fetchedResultsController.objectAtIndexPath(indexPath) as! Word
            
            if aValidWord.found == false {
                // fill in the word with red tiles
                aValidWord.found = true // need to switch this to something else that will trigger configureCell
                aValidWord.found = false
            } else {
                
            }
//                let currentWord = fetchedResultsController.objectAtIndexPath(indexPath) as! Word
//                currentWord.found = true
                saveContext()
            
        }
        animateStatusHeight(80.0)
        progressLabl.text = "\(currentNumFound()) of \(currentNumberOfWords! - model.inactiveCount!) words found"
        animateNewListButton()
    }
    
    /* obj -c version
     // 'Cheat' function, to fill in unanswered words
     - (IBAction) fillInTheBlanks {
     if (!wordlistCompleted) {
     [self animateStatus:NO]; // NO meaning the status box grows, not shrinks
     wordlistCompleted = YES;
     }
     filledInTheBlanks = YES;
     for (NSString *checkString in currentWordList) {
     int indexOfCurrentWord = [currentWordList indexOfObject:checkString];
     
     UILabel *currentLabel = (UILabel *)[self.view viewWithTag:100 + indexOfCurrentWord];
     UIView *thisView = (UIView *)[self.view viewWithTag:200 + indexOfCurrentWord];
     //NSString * blankString = [[NSString alloc] initWithFormat:@""];
     NSString * blankString = @"";
     if ([currentLabel.text isEqualToString: blankString]) {
     [currentLabel setText:checkString];
     [currentLabel setTextColor:[UIColor redColor]];
     currentLabel.hidden = YES;
     [self fillInTheBlanksByLetter:indexOfCurrentWord :checkString :[UIColor whiteColor] : 0.6];
     thisView.hidden = NO;
     [thisView setOpaque:NO];
     thisView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"merged_small_tiles_red.png"]];
     }
     }
     }
     
     */
    
//    //TODO: layout the Tiles which are not using autolayout
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UITapGestureRecognizer) {
            return true
        } else {
            return false
        }
    }
    
    //MARK:- Tapping and Panning for Tiles
    func setupGestureRecognizers(tile: Tile) {
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tileTapped(_:)))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panTile(_:)))
        
        tapRecognizer.delegate = self
        panRecognizer.delegate = self
        
        tile.addGestureRecognizer(tapRecognizer)
        tile.addGestureRecognizer(panRecognizer)
        
        panRecognizer.requireGestureRecognizerToFail(tapRecognizer)

        
//        if let gestureRecognizers = tile.gestureRecognizers {
//            for tap in gestureRecognizers {
//                if tap.isKindOfClass(UITapGestureRecognizer) {
//                    tap.requireGestureRecognizerToFail(panRecognizer)
//                }
//            }
//            print("In setup pan: GR's: \(tile.gestureRecognizers!.count)")
//        }
    }
    
    //TODO:-set up custom behaviors as separate classes
    func panTile(pan: UIPanGestureRecognizer) {
        
        animator.removeAllBehaviors()
        
        let t = pan.view as! Tile
        let location = pan.locationInView(self.view)
//        let startingLocation = location
//        let sensitivity: Float = 10.0
        
        switch pan.state {
        case .Began:
            print("Began pan")
            //animator?.removeBehavior(t.snapBehavior!) //TODO: behavior not being removed, and fighting with pan.
            //TODO:-- each remove behavior, and/or, use attachment behavior instead of pan, as in WWDC video
            t.superview?.bringSubviewToFront(t) // Make this Tile float above the other tiles
            //let center = t.center
            t.layer.shadowOpacity = 0.85
            let scale = CGAffineTransformMakeScale(1.25, 1.25)
            let move = CGAffineTransformMakeTranslation(0.0, -58.0)

            
            UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                
                t.transform = CGAffineTransformConcat(scale, move)
                
                }, completion: { (finished: Bool) -> Void in
                    //hasFinishedBeganAnimation = finished
                    //print("ani done")
            })

      
        case .Changed:
            t.center = location
            
        case .Ended:
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
            //if model.calculateDistance(startingLocation, p2: location) > sensitivity {
            
            if let closestOpenPosition = model.findClosestPosition(location, positionArray: positions!) {
                swapTileToKnownPosition(t, pos: closestOpenPosition)
                checkUpperPositionsForWord()
            }
            //}
            
            // seemed to have extra snapping behaviors interfering, so removed all behaviors, and added back here.
            for tile in lettertiles {
                animator.addBehavior(tile.snapBehavior!)
            }
            t.layer.shadowOpacity = 0.0
            t.transform = CGAffineTransformIdentity
            
            
           
            
            
        default:
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
    
    // save context with completion handler
    func saveContext (completion: (success: Bool)-> Void) {
        if sharedContext.hasChanges {
            do {
                try sharedContext.save()
                completion(success: true)
            } catch {
                let nserror = error as NSError
                print("Could not save the Managed Object Context")
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                completion(success: false)
            }
        }
    }
    
    // MARK:- Delay function
    //http://www.globalnerdy.com/2015/09/30/swift-programming-tip-how-to-execute-a-block-of-code-after-a-specified-delay/
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }
    
    

}




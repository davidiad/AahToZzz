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

/*
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}
*/

class AtoZViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate{//, UICollisionBehaviorDelegate {
    
//    fileprivate func testAlamoFire() {
//        print (" Alamofire version: \(AlamofireVersionNumber)")
//           }
    
    //TODO: When proxy scroll (invisible scrolling table on right, synced to table on left) is touched, show custom scroll indicator. Also show vertical bar with progress?
    let uiDynamicsDelegate = AtoZUIDynamicsDelegate();
    let popoverDelegate = AtoZPopoverDelegate();
    
    var model = AtoZModel.sharedInstance //why not let?
    var letters: [Letter]! //TODO: why not ? instead of !
    var wordlist = [String]()
    var positions: [Position]?
    var wordHolderCenter: CGPoint?
    
    var game: Game?
    var currentLetterSet: LetterSet?
    var currentWords: [Word]?
    
    var currentNumberOfWords: Int?
    var currentNumberOfActiveWords: Int?
    
    var fillingInBlanks: Bool = false // flag for configuring cells when Fill in the Blanks button is touched
    
    var lettertiles: [Tile]! // created in code so that autolayout done't interfere with UI Dynamcis
    var tilesToSwap: [Tile]? // an array to temporarilly hold the tiles waiting to be swapped
    var maxTilesToSwap: Int = 0 // temp. diagnostic
    
    //MARK:- IBOutlets
    @IBOutlet weak var progressLabl: UILabel!
    @IBOutlet weak var wordInProgress: UILabel!
    @IBOutlet weak var startNewList: UIButton!
    @IBOutlet weak var wordTableHolderView: UIView!
    @IBOutlet weak var wordTable: UITableView!
    @IBOutlet weak var proxyTable: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var inProgressLeading: NSLayoutConstraint!
    @IBOutlet weak var statusBgHeight: NSLayoutConstraint!
    
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
        //lazyCollider.collisionDelegate = self  // delegate may ot even be needed
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
    
    
    // MARK: - NSFetchedResultsController
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
        uiDynamicsDelegate.lettertiles = lettertiles // Will these need to be updated on the delegate?
        
        let bgImage = UIImage(named: "tile_bg") as UIImage?
        
        for i in 0 ..< 7 {
            
            //let button   = UIButton(type: UIButtonType.Custom) as UIButton
            //TODO: move some of this stuff to init for Tile
            //TODO: use the eventual tile positions
            //lettertiles[i].letter!.position!.position
            if let tilePos = positions?[i].position {
                let tile = Tile(frame: CGRect(x: tilePos.x, y: tilePos.y * CGFloat(i), width: 50, height: 50))
                let bgView = UIImageView(image: bgImage)
                bgView.tag = 2000 + i
                /*tileBackgrounds?.append(bgView) remove tileBackgrounds 3 of 3*/
                bgView.center = tilePos
                
//                tile.setBackgroundImage(image, forState: .Normal)
                //tile.setTitleColor(UIColor.blueColor(), forState: .Normal)
                
                tile.setTitle("Q", for: UIControlState()) // Q is placeholder value
                
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
        
        
        let mainGradient = model.yellowPinkBlueGreenGradient()
        
        mainGradient.frame = view.bounds
        mainGradient.zPosition = -1
        mainGradient.name = "mainGradientLayer"
        view.layer.addSublayer(mainGradient)
        
        collisionBehavior = UICollisionBehavior(items: [])
        for tile in lettertiles {
            if (tile.boundingPath) != nil {
                collisionBehavior.addBoundary(withIdentifier: "tile" as NSCopying, for: tile.boundingPath!)
            }
        }
        animator.addBehavior(collisionBehavior)
        
        //testAlamoFire()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateProgress(nil)
        // Thank you Aaron Douglas for showing how to turn on the cool fields of lines that visualize UIFieldBehaviors!
        // https://astralbodi.es/2015/07/16/uikit-dynamics-turning-on-debug-mode/
        //animator.setValue(true, forKey: "debugEnabled")
        
        // When first loading, add a basic info panel about the game, with a dismiss button
        // TODO: enable dismiss by tapping anywhere
        // TODO: customize the info vc animation
        let infoViewController = self.storyboard?.instantiateViewController(withIdentifier: "Intro") as! IntroViewController
        infoViewController.modalPresentationStyle = .overCurrentContext
        
        self.present(infoViewController, animated: true) {
            
        }
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
                    print("maxTilesToSwap: \(self.maxTilesToSwap)")
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
        print("in swapTileToKnownPosition")
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
    

    // MARK:- FetchedResultsController delegate protocol
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        wordTable.beginUpdates()
        proxyTable.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        wordTable.endUpdates()
        proxyTable.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                wordTable.insertRows(at: [indexPath], with: .fade)
                proxyTable.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                wordTable.deleteRows(at: [indexPath], with: .fade)
                proxyTable.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = wordTable.cellForRow(at: indexPath) as? WordListCell {
                configureCell(cell, atIndexPath: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                wordTable.deleteRows(at: [indexPath], with: .fade)
                proxyTable.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                wordTable.insertRows(at: [newIndexPath], with: .fade)
                proxyTable.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }

    
    //MARK:- Table View Data Source Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = fetchedResultsController.sections {
            return 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            currentNumberOfWords = sectionInfo.numberOfObjects
            return currentNumberOfWords!
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == proxyTable {
            let proxyCell = tableView.dequeueReusableCell(withIdentifier: "proxycell", for: indexPath) as? ProxyTableCell
            configureProxyCell(proxyCell!, atIndexPath: indexPath)
            return proxyCell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? WordListCell
            configureCell(cell!, atIndexPath: indexPath)
            return cell!
        }
        
    }
    
    func configureProxyCell(_ cell: ProxyTableCell, atIndexPath indexPath: IndexPath) {
        //
    }
    
    func configureCell(_ cell: WordListCell, atIndexPath indexPath: IndexPath) {
        
        // Fetch Word
        if let word = fetchedResultsController.object(at: indexPath) as? Word {
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
                    // TODO: consider setting word text color per level. Consider outlining text. Consider moving this code to WordListCell.swift
                    setWordListCellProperties(cell, colorCode: word.level, textcolor: Colors.darkBrown, text: word.word!)
                    
                    
                }
            }
            //TODO:-- Ensure that inactive words are being counted (or not counted) correctly
            if word.active == false {
                setWordListCellProperties(cell, colorCode: -2, textcolor: Colors.gray_text, text: word.word!)
                // hack for now TODO:-- single line outlines need to have a different shadow image than doubled lines
                cell.outlineShadowView.image = UIImage(named: "outline_thick")
                cell.outlineShadowView.alpha = 0.2
                print("INACTIVE, in configureCell: \(String(describing: cell.word.text)) at level \(word.level)")
                print(word)
                
            }

            
        }
    }
    
    //TODO: helper func for setting cell attributes
    func setWordListCellProperties(_ cell: WordListCell, colorCode: Int, textcolor: UIColor, text: String) {
        cell.colorCode = ColorCode(code: colorCode)
        cell.firstLetter.textColor = textcolor
        cell.secondLetter.textColor = textcolor
        cell.thirdLetter.textColor = textcolor
        cell.word.text = text // cell.word is a UILabel
        cell.wordtext = text // triggers didSet to add image and letters
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let wordCell = tableView.cellForRow(at: indexPath) as? WordListCell {
            // only if false to prevent the same Popover being called again while it's already up for that word
            if wordCell.isSelected == false {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "definition") as! DefinitionPopoverVC
                vc.modalPresentationStyle = UIModalPresentationStyle.popover
                if let wordObject = fetchedResultsController.object(at: indexPath) as? Word {
                    vc.sometext = wordObject.word
                    vc.definition = model.getDefinition(wordObject.word!)
                }
                let popover: UIPopoverPresentationController = vc.popoverPresentationController!
                popover.delegate = popoverDelegate
//                popover.permittedArrowDirections = UIPopoverArrowDirection.left
                // tell the popover that it should point from the cell that was tapped
                popover.sourceView = tableView.cellForRow(at: indexPath)
                // make the popover arrow point from the sourceRect, further to the right than default
                let sourceRect = CGRect(x: 10, y: 10, width: 170, height: 25)
                popover.sourceRect = sourceRect
                present(vc, animated: true, completion:nil)
            }
        } else {
            print("no word cell here")
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: prevent popover from attempting to present twice in a row
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == proxyTable {
            wordTable.setContentOffset(proxyTable.contentOffset, animated: false)
        }
    }

    
//    //MARK:- Popover Delegate functions  /**** Moved to Delegate ****/
//
//    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//        //return UIModalPresentationStyle.FullScreen
//        // allows popever style on iPhone as opposed to Full Screen
//        return UIModalPresentationStyle.none
//    }
//
//    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
//        let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
//        let btnDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(AtoZViewController.dismiss(first:)))
//        navigationController.topViewController!.navigationItem.leftBarButtonItem = btnDone
//        return navigationController
//    }
//
//    // added paramater 'first' only so #selector is recognized above - compiler can't disambiguate parameterless method
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
                    animateStatusHeight(80.0)
                    progressLabl.text = "Word List Completed!"
                    animateNewListButton()
                } else {
                    progressLabl.text = "\(numFound) of \(currentNumberOfWords! - model.inactiveCount!) words found"
                }
            }
        }
        UIView.animate(withDuration: 2.35, delay: 0.25, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            
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

    
//    func requireGestureRecognizerToFail(otherGR: UIGestureRecognizer) {
//        
//    }
    //MARK:-Tile Tapped
    // replaces addLetterToWordInProgress(sender: Tile)
    
    //TODO: instead of swapping the tile right away, check if a flag for a previous tileTap is true, if so, save the tile, wait until the context has been saved in swapTile, and then swap this new tile
    
    // Create an array of Tiles to hold any tiles that are tapped, and waiting in line to be swapped
    
    @IBAction func tileTapped(_ gesture: UIGestureRecognizer) {
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
                    
//                    let time = DispatchTime( uptimeNanoseconds: DispatchTime.now()) + Double(Int64(0.35 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC) //Int64(NSEC_PER_SEC))
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    func checkForExistingLetters () {
        // if there is a saved letterset, then use that instead of a new one
        game = model.fetchGame()
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
            
            //lettertiles[i].setTitle(letters[i].letter, forState: UIControlState.Normal)
//            let attributes: [String : AnyObject] = [NSFontAttributeName : UIFont(name: "BanglaSangamMN-Bold", size: 42.0)!, NSForegroundColorAttributeName : UIColor.darkGrayColor()]
//            lettertiles[i].titleLabel?.attributedText = NSAttributedString(string: "A", attributes: attributes)
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
            saveContext()
        }
        animateStatusHeight(80.0)
        progressLabl.text = "\(currentNumFound()) of \(currentNumberOfWords! - model.inactiveCount!) words found"
        animateNewListButton()
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            return true
        } else {
            return false
        }
    }
    
    //MARK:- Tapping and Panning for Tiles
    func setupGestureRecognizers(_ tile: Tile) {
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tileTapped(_:)))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panTile(_:)))
        
        tapRecognizer.delegate = self
        panRecognizer.delegate = self
        
        tile.addGestureRecognizer(tapRecognizer)
        tile.addGestureRecognizer(panRecognizer)
        
        panRecognizer.require(toFail: tapRecognizer)
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
        UIView.animate(withDuration: 0.4, animations: {
            self.statusBgHeight.constant = ht
            self.view.layoutIfNeeded()
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

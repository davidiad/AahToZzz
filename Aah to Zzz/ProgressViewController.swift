//
//  ProgressViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 10/16/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit
import CoreData

class ProgressViewController: UIViewController, NSFetchedResultsControllerDelegate//, UITableViewDataSource, UITableViewDelegate,
    {
    
    // hidden but saved for example @IBOutlet weak var table_00: UITableView!
    @IBOutlet weak var graphBgView: UIView!
    @IBOutlet weak var graphStackView: UIStackView! // not working to add bars to stack view, so remove if can't get to work
    
    @IBOutlet weak var numberOfWordsLabel: UILabel!
    
    let model = AtoZModel.sharedInstance
    
    // Constants for graph layout
    let BAR_WIDTH: CGFloat = 32.0
    let SIDE_PADDING: CGFloat = 110.0
    let MIN_BAR_PADDING: CGFloat = 2.0
    let VERTICAL_PADDING: CGFloat = 300.0
    
    var graphHeight: CGFloat = 100.0
    var graphWidth: CGFloat = 100.0
    
    
    
//    var levelArrays: [[Word]?] = [[Word]?]()
    var levelArrays: [[String]?] = [[String]?]()
    var highestLevel: Int = 4 // the highest level that will be in the graph. Min set here to 4, could be higher. Up to 8 will fit in iPhone 6 and 6s, about 5 in iPhone 5.
    var maxNumberOfBars: Int = 4
    var numberOfBars: Int = 0 // used to check when the maxNumberOfBars has been reached
    var tableHt: Int = 0
    var unplayedWordsExist: Bool = false
    var unplayedWordsArray = [String]()
    var levelText: String?
    
    // addLevelsContainers() is called in viewWillLayoutSubviews, so that the info needed for it, has first been obtained (inViewDidLoad). However, viewWillLayoutSubviews may be called multiple times. Therefore, adding a flag to ensure that addLevelsContainers is called only once.
    var viewWillLayoutSubviewsHasBeenCalled: Bool = false
    
    // MARK: - NSFetchedResultsController
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Word")
        //fetchRequest.predicate = NSPredicate(format: "inCurrentList == %@", true)
        //fetchRequest.predicate = NSPredicate(format: "numTimesFound > 0")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "word", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    //TODO:- calculate # words *not* found, add that as level 0, and add a bar with the words
    // - Get # words in dictionary
    // - Make an array of all the words that have *not* been found
    // - make a 0 level array (may have to create Word objects to store them)
    
    // helper to add a level array
    func addLevelArray() {
        let newLevelArray = [String]()
        levelArrays.append(newLevelArray)
        
        print("NUMBER OF BARS: \(numberOfBars) MAX NUMBER OF BARS: \(maxNumberOfBars)")
    }
    
    // Go thru the fetched results and and put each Word into its level array
    func addWordsToLevels() {
        
        // Init the minimum, default # of level arrays
        for _ in 0 ... highestLevel {
            addLevelArray()
            numberOfBars += 1 // tracking the number of bars we have so far
        }
        
        for result in fetchedResultsController.fetchedObjects! {
            
            if let word = result as? Word {
                // level is a computed property, so store it in a constant
                let level = word.level
                // if the level is higher than the count of arrays, add the level to avoid index out of range error
                if level >= levelArrays.count {
                    // go thru each possible level, because a level could be lower than this one, and not yet be init'd
                    for _ in levelArrays.count ... level {
                            //TODO: what to do in the case that more bars are added than fit here?
                            //Once a level is reached, don't allow words to go below that level, would eliminate the likelihood of a lot of not quite empties on the left
                            numberOfBars += 1 // tracking the number of bars we have so far
                            addLevelArray()
                    }
                    // Check if we need to increase the highest level to include in the graph
                    if level > highestLevel { highestLevel = level }
                }
                
                // add the word to the array
                levelArrays[level]!.append(word.word!) // forced unwraps -- look into
                
            }
        }
        // Now that we've added the words to the levels,
        // check for empty levels on the left
        // each empty level on left won't be added, so add one more to the right so the graph is full
        // only if there are no unplayed words to add to a left-most bar,
        // check to see if there are any levels with 0 words on the left, to replace with new levels on the right
        if unplayedWordsExist == false { // unplayed words adds a column on left, so don't remove empties to right
            var foundNotEmptyLevel = false
            if levelArrays.count > 0 {
                let highestBar = highestLevel
                for i in 0 ..< highestBar {
                    if foundNotEmptyLevel == false {
                        
                        guard let level = levelArrays[i] else { // will still crash if levelsArray is empty
                            return
                        }
                        if level.count == 0 {
                            highestLevel += 1 // not using highestLevel again, but to keep it accurate
                            numberOfBars -= 1 // removing the empty bar
                            if numberOfBars < maxNumberOfBars {
                                addLevelArray() // add an empty level to the right to fill out the graph
                            }
                        } else {
                            foundNotEmptyLevel = true // flag to escape from this loop. Because we keep empty levels if they are in the middle of the graph, and only remove the empties if they're on the left
                        }
                    }
                }
            }
        }
        
        
        //TODO:- Add all the not yet played words to Level 0
        // Get a set of all the dictionary words
        // Get a set of all the played words
        // subtract played words from dictionary words, leaving a set of all unplayed words
        // create an array of Word objects from those unplayed words (but don't save to Managed Object Context)
        // Add that array to levelArrays[0]
        // sort in alphabetical order (possibly don't sort, just add on). Possibly make the unplayed a different color
        // in the same level bar. Would that be too confusing? Possibly label each section as played or unplayed
        // OR: Make a different level bar for the unplayed.
        
    }
    
    // find the lowest level with any words and return a string formatted to one decimal (e.g. 1.2)
    // TODO:- if there are any words in the 0 level, the level should be 0.x
    // What happens if you are at a higher level (eg 2), and some words are reduced to 0?
    // Should a word keep it's mastered status, even if it is missed later?
    // Increase the percentage of mastered words that are grayed out?
    // TODO: consider whether this should be a calculated, or lazy var, instead of a func
    
    // TODO:- Determine of to differentiate between level 1 count going up, and level 1 count going down because now adding to level 2, and so forth
    func calculateLevel() -> String {
        var levelString = "0"
        
        // skip 0, because we start by looking at the # of words found once (not the # found 0 times)
        
        // need to find the *first* level that has not been filled
        // need a stopping condition, when we find that
        
        for i in 1 ..< levelArrays.count {
            guard let currentLevelArray = levelArrays[i] else {
                return levelString
            }
            // if 0 words in level, then that level is finished (or else not started)
            // so don't do anything with it, just go on to the next
            if currentLevelArray.count > 0 {
                // What if there are some words in level 0?
                // Need to count all the words in this level and above
                var levelWordCount = 0
                for j in i ..< levelArrays.count {
                    levelWordCount += levelArrays[j]!.count
                }
                
                if levelWordCount < model.wordsDictionary.count {
                    
                    let levelFloat = Float(i - 1) + Float(levelWordCount) / Float(model.wordsDictionary.count)
                    // To avoid rounding x.5 and greater numbers up to the next level,
                    // Convert to Int and back to Float
                    let levelInt = Int(10 * levelFloat) // Drop (floor) all digits past the tenths by converting to Int
                    let level = Float(levelInt)/10.0 // Convert back to a Float with a tenths place
                    // Will display level in tenth point increments
                    // TODO: display as fraction 3 7/10 etc
                    levelString = String(format: "%.1f", level)
                    print ("Level Word Count : \(i) : \(levelWordCount)")
                    return levelString // the level is the first one with some words, so return here
                    // (you don't move to the next level until all are found)
                }
            }
            //TODO: Why does levelString get returned twice?
        }
        // no levels had any words so return 0
        return levelString
    }
    
    
    //TODO: Save how many rounds have been played (In game managed object). Make sure dictionary can be switched (requires new game). Possibly save details needed to show an animation of progress. Calculate levels to tenth digit, eg, Level 0.3, level 2.1, to give more of a sense of progress.
    // Add tips, e.g., if you miss a word, or fill in the blanks, you will go down a level for that/those word(s)
    
    // Is this func needed? or just replace with addWordsToLevels() directly
    func analyzeWords() {
        addWordsToLevels()
        
        
        if unplayedWordsExist { // need to find these words and make an array to put into the graph
            // make a set of all the strings that have been fetched
            var fetchedWordsSet: Set<String> = Set<String>()
            //TODO: examine use of forced unwrapping below
            for fetched in fetchedResultsController.fetchedObjects! {
                if let word = fetched as? Word {
                    fetchedWordsSet.insert(word.word!)
                }
            }
            
            let allWordsSet = AtoZModel.sharedInstance.wordsSet
            let unplayedWordsSet = allWordsSet.subtract(fetchedWordsSet)
            for wordString in unplayedWordsSet {
                //let wordObject = Word(wordString: wordString, context: sharedContext)
                //wordObject.word = wordString
                unplayedWordsArray.append(wordString)
                // now we have an array of word objects to use to create the level table.
                // Note: not saving these Word object to the context. They are only for a one time use in this view.
                // TODO: find a way to do this using just strings instead of Word objects
            }
        }
    }
    
    // helper/diagnostic to view the number of words in each level
    func printLevelArrays() {
        for i in 0 ..< levelArrays.count {
            print("Level \(i) has \(levelArrays[i]?.count) words")
        }
    }
    
    // helper to find the level with greatest number of words
    func findMaxLevelCount() -> Float {
        var maxLevelCount: Int = 0
        for i in 0 ..< levelArrays.count {
            // level might have 0 words, in which case, don't check for maxLevelCount
            if let levelCount = levelArrays[i]?.count {
                if levelCount > maxLevelCount {
                    maxLevelCount = levelCount
                }
            }
        }
        // Compare to the unplayed words, in case that should be the tallest bar
        if unplayedWordsExist {
            if unplayedWordsArray.count > maxLevelCount {
                maxLevelCount = unplayedWordsArray.count
            }
        }
        return Float(maxLevelCount)
    }
    
    
    //MARK:- View Lifecycle
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "segueToInfo" {
//            if let infoVC = segue.destinationViewController as? ProgressInfoViewController {
//                infoVC.levelByTenths = calculateLevel()
//            }
//        }
//    }
    
    // helper for view layout – determines how many bars to add to the graph initially
    // calculating the initial highest level, and the number of bars to add to the graph
    func calculateHighestLevel(viewWidth: CGFloat) {
        
        maxNumberOfBars = Int((viewWidth - SIDE_PADDING) / (BAR_WIDTH + MIN_BAR_PADDING))
        
        // subtract 1 because the levels are counted from 0
        highestLevel = maxNumberOfBars - 1
        
        // the unplayed words need a bar, so reduce the number of level bars by 1 to make room
        if unplayedWordsExist {
            highestLevel -= 1
        }
        print("CALCULATE HIGH LEVEL: \(highestLevel)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        unplayedWordsExist = model.wordsDictionary.count > fetchedResultsController.fetchedObjects?.count
        
        automaticallyAdjustsScrollViewInsets = false
        
        // hiding table_00 
        /*
        table_00.backgroundColor = UIColor.yellowColor()
        table_00.layoutMargins = UIEdgeInsets.init(top: 1, left: 0, bottom: 1, right: 0)
        */
        
        calculateHighestLevel(view.bounds.width)
        analyzeWords()
        
    }
    
    // get the graph height after viewDidLoad – otherwise, the views have not yet adapted to the device screen size
    // but causes a visible delay in displaying the graphs
    
    override func viewWillLayoutSubviews() {
        //super.viewWillLayoutSubviews() //needed?
        
        // only call the first time viewWillLayoutSubviews() is called
        if viewWillLayoutSubviewsHasBeenCalled == false {
            //graphHeight = graphStackView.superview!.frame.size.height
            graphHeight = view.bounds.height - VERTICAL_PADDING
            graphWidth = graphStackView.superview!.frame.size.width
            addLevelContainers()
            levelText = calculateLevel()
        }
        viewWillLayoutSubviewsHasBeenCalled = true
        
    }
    
    //causes a delay when bar graphs load, so moved to viewWillLayoutSubviews()
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        graphHeight = graphStackView.superview!.frame.size.height
//        graphWidth = graphStackView.superview!.frame.size.width
//        addLevelContainers()
//        levelText = calculateLevel()
//        
//    }
    
    // Add an array of container views containing the level bars
    //TODO: Set the height of the container by the relative number of words in the level
    func addLevelContainers() {
        var levelContainingWordsHasBeenFound = false
        //graphStackView.axis = .Horizontal
        //graphStackView.distribution = .EqualCentering
        //graphStackView.alignment = .Center
        //graphStackView.spacing = 5
        //graphStackView.translatesAutoresizingMaskIntoConstraints = false
        // rotate the graph label
        numberOfWordsLabel.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        numberOfWordsLabel.frame = CGRect(x: 0, y: 0, width: 30, height: 230)
        
        
        //graphStackView.addArrangedSubview(numberOfWordsLabel)
        
        // offset bars to the right to make room for the unplayed words bar – if it exists
//        let shiftRight: CGFloat = unplayedWordsExist ? 40.0 : 0.0
//        let leftLeading: CGFloat = graphWidth * 0.5 - 133.0
        
        // var containerArray = [UIView]()
        
        for i in -1 ..< levelArrays.count {
            if unplayedWordsExist || i >= 0 { // Don't allow the case where i = -1, but there are no unplayed words
                // (-1 is being used for the unplayed words array, which sometimes exists and sometimes not)
                let containerView = UIView()
                var numWordsInLevel: Int = 0
                var colorCode = ColorCode(code: i)
                
                containerView.translatesAutoresizingMaskIntoConstraints = false
                
                // set the background color per level
                let bg_image = UIImage(named:"graph_bg")
                let insets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
                bg_image!.resizableImageWithCapInsets(insets, resizingMode: .Tile)
                
                containerView.backgroundColor = UIColor(patternImage: bg_image!)
                
                
                //graphStackView.addSubview(containerView)
                
                
                if i < 0 {
                    numWordsInLevel = unplayedWordsArray.count
                } else {
                    numWordsInLevel = levelArrays[i]!.count
                }
                
                if numWordsInLevel > 0 || levelContainingWordsHasBeenFound == true { // don't add the bar if it has no words in it -- unless it's to the right of a populated level
                    
                    graphStackView.addArrangedSubview(containerView)
                    
                    levelContainingWordsHasBeenFound = true
                    // to be modified to only remove bars with 0 on the left, not in the middle or on the right
                    // top constraint measures from top of screen,
                    // bottom constraint from bottom
                    // graphStackView.leadingAnchor
                    // Adding 22 to height to account for bottom starting from -20, and having a thin bar of 2 even where there are 0 words
                    let height = graphHeight * CGFloat((Float(numWordsInLevel) / findMaxLevelCount())) + 22
                    
                    // if there are no words in the level, adjust height so that just a thin colored bar appears at the bottom
                    // height needs to be at least 22 so that the top is never lower than the bottom
                    //                if height < 22 {
                    //                    height += 22
                    //                }
                    
                    // move bottom constraint down by 20 to be even with bottom(because margin?)
                    NSLayoutConstraint.activateConstraints([
                        
                        containerView.widthAnchor.constraintEqualToConstant(BAR_WIDTH),
                        
                        containerView.topAnchor.constraintEqualToAnchor(graphStackView.superview!.bottomAnchor, constant: CGFloat(-1 * height)),
                        containerView.bottomAnchor.constraintEqualToAnchor(graphStackView.superview!.bottomAnchor, constant: CGFloat(-20)),
                        ])
                    //                NSLayoutConstraint.activateConstraints([
                    //
                    //                    containerView.leadingAnchor.constraintEqualToAnchor(graphStackView.leadingAnchor, constant: 40 * CGFloat(i) + leftLeading + shiftRight),
                    //                    containerView.widthAnchor.constraintEqualToConstant(32.0),
                    //
                    //                    containerView.topAnchor.constraintEqualToAnchor(graphStackView.superview!.bottomAnchor, constant: CGFloat(-1 * height)),
                    //                    containerView.bottomAnchor.constraintEqualToAnchor(graphStackView.superview!.bottomAnchor, constant: CGFloat(-20)),
                    //                    ])
                    
                    //was working, but not with stack view
                    /*
                     containerView.topAnchor.constraintEqualToAnchor(graphStackView.topAnchor, constant: CGFloat(522 - ( 3 * height) )  ),
                     */
                    // add child view controller view to container
                    
                    let controller = storyboard!.instantiateViewControllerWithIdentifier("level") as! LevelTableViewController
                    controller.level = i
                    if i < 0 {
                        // handle the case of -1, the unplayed words
                        for word in unplayedWordsArray {
                            controller.wordsInLevel.append(word)
                        }
                    } else {
                        /* // Why go thru the entire result each loop? The Words are already put into their levels
                         for result in fetchedResultsController.fetchedObjects! {
                         if let word = result as? Word {
                         if word.level == controller.level {
                         controller.wordsInLevel.append(word)
                         }
                         }
                         }
                         */
                        for word in levelArrays[i]! { // forced unwrap. OK cause we know there will be a levelArrays[i]?
                            controller.wordsInLevel.append(word)
                        }
                    }
                    
                    
                    addChildViewController(controller) // Was this line necessary?
                    controller.view.translatesAutoresizingMaskIntoConstraints = false
                    containerView.addSubview(controller.view)
                    
                    NSLayoutConstraint.activateConstraints([
                        controller.view.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor),
                        controller.view.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor),
                        controller.view.topAnchor.constraintEqualToAnchor(containerView.topAnchor),
                        controller.view.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor)
                        ])
                    
                    controller.didMoveToParentViewController(self)
                    
                    // create mask to round the corners of the graph bar
                    let barFrame: CGRect = CGRectMake(0, 0, 32, CGFloat(height - 20) )
                    let mask: UIView = UIView(frame: barFrame)
                    let maskImageView = UIImageView(frame: barFrame)
                    maskImageView.image = UIImage(named: "bar_graph_mask")
                    mask.addSubview(maskImageView)
                    
                    //mask.layer.cornerRadius = 0 //6
                    containerView.maskView = mask
                    
                    
                    // Add the outline image on top of the level bar table controller
                    // first, the shadow image beneath to help the outline stand out
                    let outlineShadowImage = UIImage(named: "outline_shadow")
                    let outlineShadowView = UIImageView(image: outlineShadowImage)
                    outlineShadowView.alpha = 0.5
                    outlineShadowView.frame = barFrame
                    //CGRect(x: 0.0, y: 0.0, width: 32.0, height: Double(CGFloat(height - 20)))
                    
                    // create the outline view
                    //TODO: seems like the outline image is being scaled up
                    //  Q1`let outlineImage = UIImage(named: "outline_double_flatbottom")
                    let outlineView = UIImageView(frame: barFrame)//UIImageView(image: outlineImage)
                    
                    // TODO:- specify cases more clearly. 0 words vs. height is small enough that the rounded top doesn't fit without squishing
                    if height < 22.0 || numWordsInLevel == 0 {
                        outlineView.image = UIImage(named: "outline_graph_double_unstretched")
                        //outlineView.image!.resizableImageWithCapInsets(insets, resizingMode: .Stretch)
                        outlineView.contentMode = .BottomLeft
                    } else {
                        outlineView.image = UIImage(named: "outline_double_flatbottom")
                    }
                    
                    outlineView.frame = barFrame
                    //CGRect(x: 0.0, y: 0.0, width: 32.0, height: Double(height - 20))
                    outlineView.image = outlineView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                    // set the outlineView tintcolor per level
                    outlineView.tintColor = colorCode.tint
                    
                    containerView.addSubview(outlineShadowView)
                    containerView.addSubview(outlineView)
                    
                    // Create a text label for the number of words that floats above the container
                    if numWordsInLevel > 0 { // don't add the label for empty levels
                        let topLabel = UILabel()
                        topLabel.textColor = colorCode.tint
                        topLabel.font = UIFont.systemFontOfSize(9)
                        topLabel.text = String(controller.wordsInLevel.count)
                        view.addSubview(topLabel)
                        topLabel.translatesAutoresizingMaskIntoConstraints = false
                        topLabel.bottomAnchor.constraintEqualToAnchor(containerView.topAnchor, constant: -3.0).active = true
                        topLabel.centerXAnchor.constraintEqualToAnchor(containerView.centerXAnchor).active = true
                    }
                    
                    // Create a text label for the word level that floats below the container
                    let bottomLabel = UILabel()
                    bottomLabel.textColor = colorCode.tint
                    bottomLabel.font = UIFont.systemFontOfSize(11)
                    
                    if i < 0 {
                        bottomLabel.text = "Words not yet played"
                        bottomLabel.lineBreakMode = .ByWordWrapping
                        bottomLabel.numberOfLines = 4
                        bottomLabel.textAlignment = .Center
                        bottomLabel.widthAnchor.constraintEqualToConstant(40).active = true
                        
                    } else {
                        bottomLabel.text = String(controller.level!)
                    }
                    view.addSubview(bottomLabel)
                    
                    bottomLabel.translatesAutoresizingMaskIntoConstraints = false
                    bottomLabel.topAnchor.constraintEqualToAnchor(containerView.bottomAnchor, constant: 9.0).active = true
                    bottomLabel.centerXAnchor.constraintEqualToAnchor(containerView.centerXAnchor).active = true
                }
            }
        }
        
        graphStackView.setNeedsLayout()
        
    }
    
    
        //let stackView = UIStackView(arrangedSubviews: containerArray)
        //stackView.axis = .Horizontal
        //stackView.distribution = .FillEqually
        //stackView.alignment = .Fill
        //stackView.spacing = 5
        //stackView.translatesAutoresizingMaskIntoConstraints = false
        //graphBgView.addSubview(stackView)
        
        //        for cv in containerArray {
        //            graphStackView.addSubview(cv)
        //            NSLayoutConstraint.activateConstraints([
        //                //containerView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 40 * CGFloat(i) + 120.0),
        //                cv.widthAnchor.constraintEqualToConstant(36.0),
        //                
        //                cv.topAnchor.constraintEqualToAnchor(graphStackView.topAnchor, constant: CGFloat(200)  ),
        //                cv.bottomAnchor.constraintEqualToAnchor(graphStackView.bottomAnchor, constant: CGFloat(-10)),
        //                ])
        //        }
}

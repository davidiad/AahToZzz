//
//  ProgressViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 10/16/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit
import CoreData
import GameKit
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


class ProgressViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    // hidden but saved for example @IBOutlet weak var table_00: UITableView!
    @IBOutlet weak var graphBgView: UIView!
    @IBOutlet weak var graphStackView: UIStackView! // not working to add bars to stack view, so remove if can't get to work
    @IBOutlet weak var sideBar: UIImageView!
    
    @IBOutlet weak var numberOfWordsLabel: UILabel!
    
    let model = AtoZModel.sharedInstance
    
    // Constants for graph layout
    let BAR_WIDTH: CGFloat = 32.0
    let SIDE_PADDING: CGFloat = 110.0
    let MIN_BAR_PADDING: CGFloat = 2.0
    let VERTICAL_PADDING: CGFloat = 300.0
    
    var graphHeight: CGFloat = 100.0
    var graphWidth: CGFloat = 100.0
    
    @IBOutlet weak var graphLowerCaptionConstraint: NSLayoutConstraint!
    
    
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
    
    var score = Int()
    
    // MARK: - NSFetchedResultsController
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
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
    }
    
    // find the lowest level with any words and return a string formatted to one decimal (e.g. 1.2)
    // TODO:- if there are any words in the 0 level, the level should be 0.x
    // What happens if you are at a higher level (eg 2), and some words are reduced to 0?
    // Should a word keep it's mastered status, even if it is missed later?
    // Increase the percentage of mastered words that are grayed out?
    // TODO: consider whether this should be a calculated, or lazy var, instead of a func
    
    // TODO:- Determine of to differentiate between level 1 count going up, and level 1 count going down because now adding to level 2, and so forth
    // change to a calculated var?
    func calculateLevel() -> Float {
        var level: Float = 0.0
        
        // skip 0, because we start by looking at the # of words found once (not the # found 0 times)
        
        // need to find the *first* level that has not been filled
        // need a stopping condition, when we find that
        
        for i in 1 ..< levelArrays.count {
            print("Counting the levels: \(i)")
            guard let currentLevelArray = levelArrays[i] else {
                return level
            }
            // if 0 words in level, then that level is finished (or else not started)
            // so don't do anything with it, just go on to the next
            if currentLevelArray.count > 0 {
                // What if there are some words in level 0?
                // Need to count all the words in this level and above. Because words in higher levels should count towards the Level calculation.
                var levelWordCount = 0
                for j in i ..< levelArrays.count {
                    levelWordCount += levelArrays[j]!.count
                    print("Progress LWC: \(j) : \(levelWordCount)")
                }
                
                // The number of words at or above the current level has been calculated
                // The level is not calculated if all the words have been found for that level.
                // The loop continues, until the first level where the level before it had some words.
                // Therefore the current level has less than the total # of possible words,
                // The level is calculated, and then returned
                // If there a more straightforward stop condition for the loop?
                if levelWordCount < model.wordsDictionary.count { // why would this line be needed? levelWordCount can't be > wordDictionary.count (all the words). And if it was ==, that means no words have been found for that level. I guess it could happen?
                    
                    let levelFloat = Float(i - 1) + Float(levelWordCount) / Float(model.wordsDictionary.count)
                    // To avoid rounding x.5 and greater numbers up to the next level,
                    // Convert to Int and back to Float
                    let levelInt = Int(10 * levelFloat) // Drop (floor) all digits past the tenths by converting to Int
                    level = Float(levelInt)/10.0 // Convert back to a Float with a tenths place
                    // Will display level in tenth point increments
                    // TODO: display as fraction 3 7/10 etc
                    //levelString = String(format: "%.1f", level)
                    //print ("Level Word Count : \(i) : \(levelWordCount)")
                    return level // the level is the first one with some words, so return here
                    // (you don't move to the next level until all are found)
                }
            }
            //TODO: Why does levelString get returned twice?
        }
        // no levels had any words so return 0
        return level
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
            let unplayedWordsSet = allWordsSet.subtracting(fetchedWordsSet)
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
            print("Level \(i as Optional) has \(levelArrays[i]?.count as Optional) words")
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
    func calculateHighestLevel(_ viewWidth: CGFloat) {
        
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
        
        
        calculateHighestLevel(view.bounds.width)
        analyzeWords()
        
        // rotate the graph label at left
//        numberOfWordsLabel.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        numberOfWordsLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        numberOfWordsLabel.frame = CGRect(x: 0, y: 0, width: 30, height: 230)
        addGradientBar()
        
        //authPlayer() // for Game Center
        
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
            let level = calculateLevel()
            levelText = String(format: "%.1f", level)
        }
        viewWillLayoutSubviewsHasBeenCalled = true
        
    }
    
    
    // Add an array of container views containing the level bars
    func addLevelContainers() {
        var levelContainingWordsHasBeenFound = false

        
        for i in -1 ..< levelArrays.count {
            if unplayedWordsExist || i >= 0 { // Don't allow the case where i = -1, but there are no unplayed words
                // (-1 is being used for the unplayed words array, which sometimes exists and sometimes not)
//                let containerView = UIView()
//                //let barContainer = GraphBarView()
                var numWordsInLevel: Int = 0
                var colorCode = ColorCode(code: i - 1)
                
//                containerView.translatesAutoresizingMaskIntoConstraints = false
//                
//                // set the background color per level
//                let bg_image = UIImage(named:"graph_bg")
//                let insets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
//                bg_image!.resizableImageWithCapInsets(insets, resizingMode: .Tile)
//                
//                containerView.backgroundColor = UIColor(patternImage: bg_image!)
//                
//                
//                //graphStackView.addSubview(containerView)
                
                
                if i < 0 {
                    numWordsInLevel = unplayedWordsArray.count
                } else {
                    numWordsInLevel = levelArrays[i]!.count
                }
                
                if numWordsInLevel > 0 || levelContainingWordsHasBeenFound == true { // don't add the bar if it has no words in it -- unless it's to the right of a populated level
                    
                    //graphStackView.addArrangedSubview(containerView)
                    
                    
                    levelContainingWordsHasBeenFound = true
                    // to be modified to only remove bars with 0 on the left, not in the middle or on the right
                    // top constraint measures from top of screen,
                    // bottom constraint from bottom
                    // graphStackView.leadingAnchor
                    // Adding 22 to height to account for bottom starting from -20, and having a thin bar of 2 even where there are 0 words
                    let height = graphHeight * CGFloat((Float(numWordsInLevel) / findMaxLevelCount())) + 22
                    let isEmpty = numWordsInLevel == 0
                    let barFrame: CGRect = CGRect(x: 0, y: 0, width: 32, height: CGFloat(height - 20) )
                    let barContainerView = GraphBarView(frame: barFrame, level: i, graphHeight: height, isEmpty: isEmpty)
                    
                    graphStackView.addArrangedSubview(barContainerView)
                    
                    // if there are no words in the level, adjust height so that just a thin colored bar appears at the bottom
                    // height needs to be at least 22 so that the top is never lower than the bottom
                    //                if height < 22 {
                    //                    height += 22
                    //                }
                    
                    // move bottom constraint down by 20 to be even with bottom(because margin?)
                    NSLayoutConstraint.activate([
                        
                        barContainerView.widthAnchor.constraint(equalToConstant: BAR_WIDTH),
                        
                        barContainerView.topAnchor.constraint(equalTo: graphStackView.superview!.bottomAnchor, constant: CGFloat(-1 * height)),
                        barContainerView.bottomAnchor.constraint(equalTo: graphStackView.superview!.bottomAnchor, constant: CGFloat(-20)),
                        ])

                    // add child view controller view to container
                    
                    let levelTableController = storyboard!.instantiateViewController(withIdentifier: "level") as! LevelTableViewController
                    levelTableController.level = i
                    if i < 0 {
                        // handle the case of -1, the unplayed words
                        for word in unplayedWordsArray {
                            levelTableController.wordsInLevel.append(word)
                        }
                    } else {
                        for word in levelArrays[i]! { // forced unwrap. OK cause we know there will be a levelArrays[i]?
                            levelTableController.wordsInLevel.append(word)
                        }
                    }
                    
                    addChildViewController(levelTableController) // Was this line necessary?
                    levelTableController.view.translatesAutoresizingMaskIntoConstraints = false
//                    containerView.addSubview(controller.view)
                    barContainerView.addSubview(levelTableController.view)
                    //TODO: set Z order so table is in back
                    
                    NSLayoutConstraint.activate([
                        levelTableController.view.leadingAnchor.constraint(equalTo: barContainerView.leadingAnchor),
                        levelTableController.view.trailingAnchor.constraint(equalTo: barContainerView.trailingAnchor),
                        levelTableController.view.topAnchor.constraint(equalTo: barContainerView.topAnchor),
                        levelTableController.view.bottomAnchor.constraint(equalTo: barContainerView.bottomAnchor)
                        ])
                    
                    levelTableController.didMove(toParentViewController: self)
                    
                    
                    // Create a text label for the number of words that floats above the container
                    if numWordsInLevel > 0 { // don't add the label for empty levels
                        let topLabel = UILabel()
                        topLabel.textColor = colorCode.tint
                        topLabel.font = UIFont.systemFont(ofSize: 9)
                        topLabel.text = String(levelTableController.wordsInLevel.count)
                        view.addSubview(topLabel)
                        topLabel.translatesAutoresizingMaskIntoConstraints = false
                        topLabel.bottomAnchor.constraint(equalTo: barContainerView.topAnchor, constant: -3.0).isActive = true
                        topLabel.centerXAnchor.constraint(equalTo: barContainerView.centerXAnchor).isActive = true
                    }
                    
                    // Create a text label for the word level that floats below the container
                    let bottomLabel = UILabel()
                    bottomLabel.textColor = colorCode.tint
                    bottomLabel.font = UIFont.systemFont(ofSize: 11)
                    
                    if i < 0 {
                        bottomLabel.text = "Unplayed"//"Words not yet played"
                        bottomLabel.lineBreakMode = .byWordWrapping
                        //bottomLabel.numberOfLines = 4
                        bottomLabel.textAlignment = .center
                        bottomLabel.widthAnchor.constraint(equalToConstant: 56).isActive = true
                        //graphLowerCaptionConstraint.constant = 32 // This line added space for when needed 4 lines for "Words not yet played"
                        
                    } else {
                        bottomLabel.text = String(levelTableController.level!)
                    }
                    view.addSubview(bottomLabel)
                    
                    bottomLabel.translatesAutoresizingMaskIntoConstraints = false
                    bottomLabel.topAnchor.constraint(equalTo: barContainerView.bottomAnchor, constant: 9.0).isActive = true
                    bottomLabel.centerXAnchor.constraint(equalTo: barContainerView.centerXAnchor).isActive = true
                }
            }
        }
        
        graphStackView.setNeedsLayout()
        
    }
    
    func addGradientBar() {
        let gradient = model.yellowPinkBlueGreenGradient()
        //gradient.frame = sideBar.bounds
        gradient.frame = CGRect(x: 0, y: 0, width: 3, height: view.bounds.height)
        sideBar.layer.addSublayer(gradient)
    }
    
    //MARK:- Game Center
    
//    func authPlayer() {
//        let localPlayer = GKLocalPlayer.localPlayer()
//        localPlayer.authenticateHandler = {
//            (view, error) in
//            if view != nil {
//                self.presentViewController(view!, animated: true, completion: nil)
//            } else {
//                print("Game Center authenticated?: \(GKLocalPlayer.localPlayer().authenticated)")
//            }
//        }
//    }
    
//    func addScore() {
//        score += 1
//    }
    
//    func saveHighScore(number: Int, levelNumber: Float) {
//        if GKLocalPlayer.localPlayer().authenticated {
//            let scoreReporter = GKScore(leaderboardIdentifier: "atozleaderboard")
//            scoreReporter.value = Int64(number)
//            let scoreArray: [GKScore] = [scoreReporter]
//            GKScore.reportScores(scoreArray, withCompletionHandler: nil)
//            
//            let levelReporter = GKScore(leaderboardIdentifier: "level_leaderboard")
//            // Game Center only allows Int64, but with format with 1 decimal point, so multiply by 10
//            levelReporter.value = Int64(levelNumber * 10)
//            let levelArray: [GKScore] = [levelReporter]
//            GKScore.reportScores(levelArray, withCompletionHandler: nil)
//        }
//    }
   /*
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showLeaderboard() {
        let viewController = self//self.view.window?.rootViewController
        let gamecenterVC = GKGameCenterViewController()
        gamecenterVC.gameCenterDelegate = self
        viewController.presentViewController(gamecenterVC, animated: true, completion: nil)
        
    }
    */
    @IBAction func openLeaderboards(_ sender: AnyObject) {
       // addScore()
        //let levelScore = calculateLevel()
        //saveHighScore(score, levelNumber: levelScore)
        
        showLeaderboard()
        //TODO:- Add a conditional -- if GameCenter not available, show local stats instead
        
    }
    
    deinit {
        print("Progress De-init")
    }
}

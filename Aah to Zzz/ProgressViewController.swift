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
    @IBOutlet weak var numWordsLabel: UILabel!
    
    let model = AtoZModel.sharedInstance
    let graphHeight: Float = 100.0
    
    var levelArrays: [[Word]?] = [[Word]?]()
    var highestLevel: Int = 6 // the highest level that will be in the graph. Min set here to 6, could be higher.
    var tableHt: Int = 0
    var unplayedWordsExist: Bool = false
    var unplayedWordsArray = [Word]()
    
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
        let newLevelArray = [Word]()
        levelArrays.append(newLevelArray)
    }
    
    // Go thru the fetched results and and put each Word into its level array
    func addWordsToLevels() {
        
        // Init the minimum, default # of level arrays
        for _ in 0 ..< highestLevel {
            addLevelArray()
        }
        
        for result in fetchedResultsController.fetchedObjects! {
            
            if let word = result as? Word {
                // level is a computed property, so store it in a constant
                let level = word.level
                // if the level is higher than the count of arrays, add the level to avoid index out of range error
                if level >= levelArrays.count {
                    // go thru each possible level, because a level could be lower than this one, and not yet be init'd
                    for _ in levelArrays.count ... level {
                        addLevelArray()
                    }
                    // Check if we need to increase the highest level to include in the graph
                    if level > highestLevel { highestLevel = level }
                }
                
                // add the word to the array
                levelArrays[level]!.append(word)
                
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
    
    //TODO: Save how many rounds have been played (In game managed object). Make sure dictionary can be switched (requires new game). Possibly save details needed to show an animation of progress. Calculate levels to tenth digit, eg, Level 0.3, level 2.1, to give more of a sense of progress.
    // Add tips, e.g., if you miss a word, or fill in the blanks, you will go down a level for that/those word(s)
    
    // Is this func needed? or just replace with addWordsToLevels() directly
    func analyzeWords() {
        addWordsToLevels()
        
        unplayedWordsExist = model.wordsDictionary.count > fetchedResultsController.fetchedObjects?.count
        
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
                let wordObject = Word(wordString: wordString, context: sharedContext)
                wordObject.word = wordString
                unplayedWordsArray.append(wordObject)
                // now we have an array of word objects to use to create the level table.
                // Note: not saving these Word object to the context. They are only for a one time use in this view.
                // TODO: find a way to do this using just strings instead of Word objects
            }
        }
        
        printLevelArrays()
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
        return Float(maxLevelCount)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    
        automaticallyAdjustsScrollViewInsets = false
        
        // hiding table_00 
        /*
        table_00.backgroundColor = UIColor.yellowColor()
        table_00.layoutMargins = UIEdgeInsets.init(top: 1, left: 0, bottom: 1, right: 0)
        */
        
        analyzeWords()
        
        //TODO:- 
        // 1. Go thru fetched objects and determine how many levels will need a bar. And their relative heights
        // 2. refactor the container code to create an array of containers with level bars
        // 3. Cont. with customizing the look of the bars
        // 4. Add text labels to the layout
        
        //Swift add container view in code
        // add container
        
//        let containerView = UIView()
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.backgroundColor = Colors.orange
//        view.addSubview(containerView)
//        NSLayoutConstraint.activateConstraints([
//            containerView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 100),
//            containerView.widthAnchor.constraintEqualToConstant(30.0),
//            
//            containerView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 100),
//            containerView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -100),
//            ])
//        //myView.widthAnchor.constraintEqualToConstant(50.0).active = true
//        //containerView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -200),
//        
//        // add child view controller view to container
//        
//        let controller = storyboard!.instantiateViewControllerWithIdentifier("level") as! LevelTableViewController
//        controller.level = 1
//        
//        for result in fetchedResultsController.fetchedObjects! {
//            if let word = result as? Word {
//                
//                if word.level == controller.level {
//                    controller.wordsInLevel.append(word)
//                }
//            }
//        }
//        
//        addChildViewController(controller)
//        controller.view.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(controller.view)
//        
//        NSLayoutConstraint.activateConstraints([
//            controller.view.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor),
//            controller.view.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor),
//            controller.view.topAnchor.constraintEqualToAnchor(containerView.topAnchor),
//            controller.view.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor)
//            ])
//        
//        controller.didMoveToParentViewController(self)
//        
//
//        // Add another container view
//        let containerView2 = UIView()
//        containerView2.translatesAutoresizingMaskIntoConstraints = false
//
//        view.addSubview(containerView2)
//        NSLayoutConstraint.activateConstraints([
//            containerView2.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 200),
//            containerView2.widthAnchor.constraintEqualToConstant(30.0),
//            containerView2.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 140),
//            containerView2.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -100),
//            ])
//        
//        // add child view controller view to container
//        
//        let controller2 = storyboard!.instantiateViewControllerWithIdentifier("level") as! LevelTableViewController
//        addChildViewController(controller2)
//        
//        // pass the data
//        controller2.level = 0
//        for result in fetchedResultsController.fetchedObjects! {
//            if let word = result as? Word {
//                
//                if word.level == controller2.level {
//                    controller2.wordsInLevel.append(word)
//                }
//            }
//        }
//        
//        
//        
//        controller2.view.translatesAutoresizingMaskIntoConstraints = false
//        containerView2.addSubview(controller2.view)
//        
//        NSLayoutConstraint.activateConstraints([
//            controller2.view.leadingAnchor.constraintEqualToAnchor(containerView2.leadingAnchor),
//            controller2.view.trailingAnchor.constraintEqualToAnchor(containerView2.trailingAnchor),
//            controller2.view.topAnchor.constraintEqualToAnchor(containerView2.topAnchor),
//            controller2.view.bottomAnchor.constraintEqualToAnchor(containerView2.bottomAnchor)
//            ])
//        
//        controller2.didMoveToParentViewController(self)
        addLevelContainers()
    }
    
    // Add an array of container views containing the level bars
    //TODO: Set the height of the container by the relative number of words in the level
    func addLevelContainers() {

        let shiftRight: CGFloat = unplayedWordsExist ? 40.0 : 0.0

        
        
        // var containerArray = [UIView]()
        for i in 0 ..< levelArrays.count {
            var colorCode = ColorCode(code: i)
            let containerView = UIView()
            
            containerView.translatesAutoresizingMaskIntoConstraints = false
            // set the background color per level
            containerView.backgroundColor = colorCode.tint
            graphStackView.translatesAutoresizingMaskIntoConstraints = false
            graphStackView.addSubview(containerView)
            
            
            // for now, hardcoding in a value of 640 for screen size (iPhone 6 plus size of 1920 / by 3x retina resolution)
            // top constraint measures from top of screen,
            // bottom constraint from bottom
            let height = Float(graphHeight) * ( Float(levelArrays[i]!.count)  / findMaxLevelCount()  )
            print("height: \(height * graphHeight)")
            NSLayoutConstraint.activateConstraints([
                containerView.leadingAnchor.constraintEqualToAnchor(graphStackView.leadingAnchor, constant: 40 * CGFloat(i) + 10.0 + shiftRight),
                containerView.widthAnchor.constraintEqualToConstant(36.0),
                
                containerView.topAnchor.constraintEqualToAnchor(graphStackView.topAnchor, constant: CGFloat(340 - (3 * height) )  ),
                containerView.bottomAnchor.constraintEqualToAnchor(graphBgView.bottomAnchor, constant: CGFloat(-10)),
                ])
            
            //was working, but not with stack view
            /*
  containerView.topAnchor.constraintEqualToAnchor(graphStackView.topAnchor, constant: CGFloat(522 - ( 3 * height) )  ),
 */
            // add child view controller view to container
            
            let controller = storyboard!.instantiateViewControllerWithIdentifier("level") as! LevelTableViewController
            controller.level = i
            
            for result in fetchedResultsController.fetchedObjects! {
                if let word = result as? Word {
                    
                    if word.level == controller.level {
                        controller.wordsInLevel.append(word)
                    }
                }
            }
            
            addChildViewController(controller)
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
            let rect: CGRect = CGRectMake(0, 0, 32, CGFloat((3 * height) + 10) )
            let mask: UIView = UIView(frame: rect)
            mask.backgroundColor = UIColor.whiteColor()
            mask.layer.cornerRadius = 6
            containerView.maskView = mask
            
            // Add the outline image on top of the level bar table controller
            // first, the shadow image beneath to help the outline stand out
            let outlineShadowImage = UIImage(named: "outline_shadow")
            let outlineShadowView = UIImageView(image: outlineShadowImage)
            outlineShadowView.alpha = 0.65
            outlineShadowView.frame = CGRect(x: 0.0, y: 0.0, width: 32.0, height: Double(3 * height + 10.0))
            
            // create the outline view
            //TODO: seems like the outline image is being scaled up
            let outlineImage = UIImage(named: "outline_double")
            let outlineView = UIImageView(image: outlineImage)
            outlineView.frame = CGRect(x: 0.0, y: 0.0, width: 32.0, height: Double(3 * height + 10.0))
            outlineView.image = outlineView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            // set the outlineView tintcolor per level
            outlineView.tintColor = colorCode.tint
            
            containerView.addSubview(outlineShadowView)
            containerView.addSubview(outlineView)
            //containerArray.append(containerView)
            numWordsLabel.text = String(Int(findMaxLevelCount()))
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
    
    // to add a bar for the unplayed words
    func addUnplayedLevel() {
        
        let shiftRight: CGFloat = unplayedWordsExist ? 40.0 : 0.0
        
        
        
        // var containerArray = [UIView]()
        for i in 0 ..< levelArrays.count {
            var colorCode = ColorCode(code: i)
            let containerView = UIView()
            
            containerView.translatesAutoresizingMaskIntoConstraints = false
            // set the background color per level
            containerView.backgroundColor = colorCode.tint
            graphStackView.translatesAutoresizingMaskIntoConstraints = false
            graphStackView.addSubview(containerView)
            
            
            // for now, hardcoding in a value of 640 for screen size (iPhone 6 plus size of 1920 / by 3x retina resolution)
            // top constraint measures from top of screen,
            // bottom constraint from bottom
            let height = Float(graphHeight) * ( Float(levelArrays[i]!.count)  / findMaxLevelCount()  )
            print("height: \(height * graphHeight)")
            NSLayoutConstraint.activateConstraints([
                containerView.leadingAnchor.constraintEqualToAnchor(graphStackView.leadingAnchor, constant: 40 * CGFloat(i) + 10.0 + shiftRight),
                containerView.widthAnchor.constraintEqualToConstant(36.0),
                
                containerView.topAnchor.constraintEqualToAnchor(graphStackView.topAnchor, constant: CGFloat(340 - (3 * height) )  ),
                containerView.bottomAnchor.constraintEqualToAnchor(graphBgView.bottomAnchor, constant: CGFloat(-10)),
                ])
            
            //was working, but not with stack view
            /*
             containerView.topAnchor.constraintEqualToAnchor(graphStackView.topAnchor, constant: CGFloat(522 - ( 3 * height) )  ),
             */
            // add child view controller view to container
            
            let controller = storyboard!.instantiateViewControllerWithIdentifier("level") as! LevelTableViewController
            controller.level = i
            
            for result in fetchedResultsController.fetchedObjects! {
                if let word = result as? Word {
                    
                    if word.level == controller.level {
                        controller.wordsInLevel.append(word)
                    }
                }
            }
            
            addChildViewController(controller)
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
            let rect: CGRect = CGRectMake(0, 0, 32, CGFloat((3 * height) + 10) )
            let mask: UIView = UIView(frame: rect)
            mask.backgroundColor = UIColor.whiteColor()
            mask.layer.cornerRadius = 6
            containerView.maskView = mask
            
            // Add the outline image on top of the level bar table controller
            // first, the shadow image beneath to help the outline stand out
            let outlineShadowImage = UIImage(named: "outline_shadow")
            let outlineShadowView = UIImageView(image: outlineShadowImage)
            outlineShadowView.alpha = 0.65
            outlineShadowView.frame = CGRect(x: 0.0, y: 0.0, width: 32.0, height: Double(3 * height + 10.0))
            
            // create the outline view
            //TODO: seems like the outline image is being scaled up
            let outlineImage = UIImage(named: "outline_double")
            let outlineView = UIImageView(image: outlineImage)
            outlineView.frame = CGRect(x: 0.0, y: 0.0, width: 32.0, height: Double(3 * height + 10.0))
            outlineView.image = outlineView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            // set the outlineView tintcolor per level
            outlineView.tintColor = colorCode.tint
            
            containerView.addSubview(outlineShadowView)
            containerView.addSubview(outlineView)
            //containerArray.append(containerView)
            numWordsLabel.text = String(Int(findMaxLevelCount()))
        }
    }

    
    //MARK:- Table View stuff (hidden saved for example)
    /*
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let _ = fetchedResultsController.sections {
            return 1
        }
        
        return 0
    }
    
    // set height for cells
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 10.0;
    }
//    Swift 3 version
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return 10.0;//Choose your custom row height
//    }

    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
//        guard let numRows = fetchedResultsController.fetchedObjects?.count else {
//            return 20
//        }
//        print("NUM: \(numRows)")
        for result in fetchedResultsController.fetchedObjects! {
            if let word = result as? Word {
                
//                print("\(word.word): level is: \(word.level)")
                if word.level == 0 {
                    tableHt += 1
                }
            }
        }
        //TODO:being called multiple times. put somewhere else?
        print("TH: \(tableHt)")
        return tableHt
    }
    
    //TODO:-- The tables will be populated by the words found at each level. There will be a table for each level (up to a reasonable limit, like 10 or 20 for now)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("level0", forIndexPath: indexPath) as? ProgressTableCell
        
        if let word = fetchedResultsController.objectAtIndexPath(indexPath) as? Word {
            cell?.label.font = UIFont(name: "Courier", size: 9)
            cell?.label.text = word.word
            cell?.label.textColor = UIColor.blueColor()
           
            cell?.backgroundView?.backgroundColor = UIColor.clearColor()
            cell?.layoutMargins = UIEdgeInsetsZero;
            cell?.preservesSuperviewLayoutMargins = false;
        }
        
        
        return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        print("in PFS")
    }
    */
}

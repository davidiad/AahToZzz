//
//  ProgressViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 10/16/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit
import CoreData

class ProgressViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var table_00: UITableView!
    
    let model = AtoZModel.sharedInstance
    let graphHeight: Float = 500.0
    
    var levelArrays: [[Word]?] = [[Word]?]()
    var highestLevel: Int = 6 // the highest level that will be in the graph. Min set here to 6, could be higher.
    var tableHt: Int = 0
    
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
    }
    
    func analyzeWords() {
        addWordsToLevels()
        var numWordsInDictionary = model.wordsDictionary.count
        let maxLevelCount = findMaxLevelCount()
        for i in 0 ..< levelArrays.count {
            print("Level \(i) has \(levelArrays[i]?.count) words")
        }
    }
    
    // helper to find the level with greatest number of words
    func findMaxLevelCount() -> Int {
        var maxLevelCount: Int = 0
        for i in 0 ..< levelArrays.count {
            // level might have 0 words, in which case, don't check for maxLevelCount
            if let levelCount = levelArrays[i]?.count {
                if levelCount > maxLevelCount {
                    maxLevelCount = levelCount
                }
            }
        }
        return maxLevelCount
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
        table_00.backgroundColor = UIColor.yellowColor()
        table_00.layoutMargins = UIEdgeInsets.init(top: 1, left: 0, bottom: 1, right: 0)
        
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
        for i in 0 ..< levelArrays.count {
            
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(containerView)
            NSLayoutConstraint.activateConstraints([
                containerView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 40 * CGFloat(i) + 100.0),
                containerView.widthAnchor.constraintEqualToConstant(30.0),
                
                containerView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 100),
                containerView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -100),
                ])
            
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
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {

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
        //let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "mycell") as! ProgressTableCell
        
        let cell = tableView.dequeueReusableCellWithIdentifier("level0", forIndexPath: indexPath) as? ProgressTableCell
        
        //cell.textLabel!.text="row#\(indexPath.row)"
        //cell.detailTextLabel!.text="subtitle#\(indexPath.row)"
        
        if let word = fetchedResultsController.objectAtIndexPath(indexPath) as? Word {
           // if word.level == 1 {
//            print("\(word.word): level is: \(word.level)")
            cell?.label.font = UIFont(name: "Courier", size: 9)
            cell?.label.text = word.word
            cell?.label.textColor = UIColor.blueColor()
           
            cell?.backgroundView?.backgroundColor = UIColor.clearColor()
            //cell.layoutMargins = UIEdgeInsets.init(top: 1, left: 0, bottom: 1, right: 0)
            cell?.layoutMargins = UIEdgeInsetsZero;
            cell?.preservesSuperviewLayoutMargins = false;
           // }
        }
        
        
        return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        print("in PFS")
    }

}

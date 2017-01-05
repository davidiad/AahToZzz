//
//  LevelTableViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 10/26/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit

class LevelTableViewController: UITableViewController {

    var level: Int?
    var colorCode: ColorCode?
//    var wordsInLevel = [Word]()
    var wordsInLevel = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let colorCodeLevel = level {
            colorCode = ColorCode(code: colorCodeLevel)
        }
            return
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        tableView.backgroundColor = UIColor.clearColor()
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let numRows = wordsInLevel.count else {
//            return 0
//        }
        return wordsInLevel.count
    }
    
    // set height for cells
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 8.0;
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("levelcell", forIndexPath: indexPath) as? LevelTableCell
        
        
      //  if let word = fetchedResultsController.objectAtIndexPath(indexPath) as? Word {

            cell?.label.font = UIFont(name: "Courier", size: 7)
            cell?.label.text = "ABC"//word.word
            cell?.label.textColor = UIColor.blueColor()
            cell?.backgroundColor = UIColor.clearColor()//   colorCode?.tint
            //cell?.backgroundView?.backgroundColor = UIColor.clearColor()
            
            //cell?.layoutMargins = UIEdgeInsetsZero;
            //cell?.preservesSuperviewLayoutMargins = false;
        
       // var word: Word = wordsInLevel[1] as? Word {
            
        cell?.label.text = wordsInLevel[indexPath.row]
        
    
        return cell!

    }

}

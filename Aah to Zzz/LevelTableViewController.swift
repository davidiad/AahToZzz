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

    override func numberOfSections(in tableView: UITableView) -> Int {
        tableView.backgroundColor = UIColor.clear
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let numRows = wordsInLevel.count else {
//            return 0
//        }
        return wordsInLevel.count
    }
    
    // set height for cells
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 8.0;
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "levelcell", for: indexPath) as? LevelTableCell
        
        
      //  if let word = fetchedResultsController.objectAtIndexPath(indexPath) as? Word {

            cell?.label.font = UIFont(name: "Courier", size: 7)
            cell?.label.text = "ABC"//word.word
            cell?.label.textColor = UIColor.blue
            cell?.backgroundColor = UIColor.clear//   colorCode?.tint
            //cell?.backgroundView?.backgroundColor = UIColor.clearColor()
            
            //cell?.layoutMargins = UIEdgeInsetsZero;
            //cell?.preservesSuperviewLayoutMargins = false;
        
       // var word: Word = wordsInLevel[1] as? Word {
            
        cell?.label.text = wordsInLevel[indexPath.row]
        
    
        return cell!

    }

}

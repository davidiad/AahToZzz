//
//  LevelTableViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 10/26/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit

class LevelTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    // set height for cells
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 10.0;
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("levelcell", forIndexPath: indexPath) as? LevelTableCell
        
        
      //  if let word = fetchedResultsController.objectAtIndexPath(indexPath) as? Word {

            cell?.label.font = UIFont(name: "Courier", size: 9)
            cell?.label.text = "ABC"//word.word
            cell?.label.textColor = UIColor.blueColor()
            
            //cell?.backgroundView?.backgroundColor = UIColor.clearColor()
            
            //cell?.layoutMargins = UIEdgeInsetsZero;
            //cell?.preservesSuperviewLayoutMargins = false;
            
       // }
        
        
        return cell!

    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

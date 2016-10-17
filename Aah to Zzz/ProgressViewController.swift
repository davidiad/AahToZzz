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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        //needed?
        //game = model.game

    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let _ = fetchedResultsController.sections {
            return 1
        }
        
        return 0
    }

    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "mycell")
        cell.textLabel!.text="row#\(indexPath.row)"
        //cell.detailTextLabel!.text="subtitle#\(indexPath.row)"
        
        if let word = fetchedResultsController.objectAtIndexPath(indexPath) as? Word {
            cell.detailTextLabel!.text = word.word
        }
        
        return cell
    }

}

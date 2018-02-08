//
//  AtoZTableViewDelegates.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/8/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//
import CoreData
import UIKit

class AtoZTableViewDelegates: NSObject, NSFetchedResultsControllerDelegate, WordTables {
    // Do we really need WordTables as a protocol, or just the vars?
    var wordTable: UITableView!
    var proxyTable: UITableView!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    // MARK: - NSFetchedResultsController
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext
    }()

//    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Word")
//        fetchRequest.predicate = NSPredicate(format: "inCurrentList == %@", true as CVarArg)
//        // Add Sort Descriptors
//        let sortDescriptor = NSSortDescriptor(key: "word", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
//
//        fetchedResultsController.delegate = self
//
//        return fetchedResultsController
//    }()
    
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
    
    func configureCell(_ cell: WordListCell, atIndexPath indexPath: IndexPath) {
        
        // Fetch Word
        if let word = fetchedResultsController?.object(at: indexPath) as? Word {
            //TODO: can i use cell.wordtext property instead and eliminate the uilabel?
            //TODO: use the word.numTimesFound property to send the correctly colored tiles to the cell
            
            /* Set aside for now. Need a way to pass fillingInBlanks from the view controller
            if fillingInBlanks == true {
                
                if word.found == false && word.inCurrentList == true {
                    
                    setWordListCellProperties(cell, colorCode: -1, textcolor: Colors.reddish_white, text: word.word!)
                    
                    // hack for now TODO:-- single line outlines need to have a different shadow image than doubled lines
                    cell.outlineShadowView.image = UIImage(named: "outline_thick")
                    cell.outlineShadowView.alpha = 0.2
                }
            }
            
            */
            
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
    
    func configureProxyCell(_ cell: ProxyTableCell, atIndexPath indexPath: IndexPath) {
        //
    }
    
    // helper func for setting cell attributes
    func setWordListCellProperties(_ cell: WordListCell, colorCode: Int, textcolor: UIColor, text: String) {
        cell.colorCode = ColorCode(code: colorCode)
        cell.firstLetter.textColor = textcolor
        cell.secondLetter.textColor = textcolor
        cell.thirdLetter.textColor = textcolor
        cell.word.text = text // cell.word is a UILabel
        cell.wordtext = text // triggers didSet to add image and letters
    }
}

protocol WordTables {
    var wordTable: UITableView! {get}
    var proxyTable: UITableView! {get}
}
//
//  AtoZTableViewDelegates.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/8/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//
import CoreData
import UIKit

class AtoZTableViewDelegates: NSObject, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, WordTables {
    var gradient: CAGradientLayer!
    // Do we really need WordTables as a protocol, or just the vars?
    var wordTable: UITableView!
    var wordTableHeaderCover: UIView!
    var wordTableHeaderCoverHeight: NSLayoutConstraint!
    var wordTableFooterCoverHeight: NSLayoutConstraint!
    var footerGapHeight: CGFloat = 0 // The footer gap to fill, varies with word list length and screen height
    var proxyTable: ProxyTable!
    var proxyTableArrow: UIImageView!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    let popoverDelegate = AtoZPopoverDelegate()
    //var fillingInBlanks: Bool = false
    
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
    
    // update and apply the footerGapHeight
    func updateFooterGapHeight() {
        let heightOfCells = 36 * CGFloat(tableView(wordTable, numberOfRowsInSection: 0))
        if heightOfCells > 0.001 { // conditional to prevent calculation after all rows removed
            footerGapHeight = wordTable.bounds.height - heightOfCells
            wordTableFooterCoverHeight.constant = footerGapHeight
        }
    }
    
    // animation to hide the gap when changing # of cells
    func animateBackground (_ tableview: UITableView) {
        UIView.animate(withDuration: 0.2, delay: 0.25, options: [.transitionCrossDissolve, .allowAnimatedContent], animations: {
            tableview.backgroundColor = .clear
        }) { (_) in
            UIView.animate(withDuration: 1.0, animations: {
                //cell.contentView.backgroundColor = self.color1
                // TODO: need this completion handler or set to nil?
            })
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        wordTable.endUpdates()
        proxyTable.endUpdates()
        updateFooterGapHeight()
        // animate the bg color to back to transparent
        animateBackground(wordTable)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                wordTable.insertRows(at: [indexPath], with: .bottom)
                proxyTable.insertRows(at: [indexPath], with: .none)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                // when deleting cells (in prep for a new list), hide the gap below the
                // cells by temp. setting table bg to a matching dark color
                wordTable.backgroundColor = Colors.darkBackground
//                if let cell = wordTable.cellForRow(at: indexPath) as? WordListCell {
//                    cell.outlineView.tintColor = Colors.darkBackground
//                }
                wordTable.deleteRows(at: [indexPath], with: .top)
                proxyTable.deleteRows(at: [indexPath], with: .left)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = wordTable.cellForRow(at: indexPath) as? WordListCell {
                configureCell(cell, atIndexPath: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                wordTable.deleteRows(at: [indexPath], with: .left)
                proxyTable.deleteRows(at: [indexPath], with: .left)
            }
            
            
            if let newIndexPath = newIndexPath {
                wordTable.insertRows(at: [newIndexPath], with: .left)
                proxyTable.insertRows(at: [newIndexPath], with: .left)
            }
            break;
        }
    }
    
    // MARK:- Table View Delegate
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let wordCell = tableView.cellForRow(at: indexPath) as? WordListCell {
            // only if false to prevent the same Popover being called again while it's already up for that word
            if wordCell.isSelected == false {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "definition") as! DefinitionPopoverVC
                vc.modalPresentationStyle = UIModalPresentationStyle.popover
                if let wordObject = fetchedResultsController?.object(at: indexPath) as? Word {
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
                let userInfo = ["item": vc]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PresentDefinition"), object: nil, userInfo: userInfo)
            }
        } else {
            print("no word cell here")
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: prevent popover from attempting to present twice in a row
    }
    
    //MARK:- Scrollview delegate
    //(Tableview inherits from scrollview
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == proxyTable {
            wordTable.setContentOffset(proxyTable.contentOffset, animated: false)
            
        }
        // cover the ends of the tranparent table with the "background' color. Any
        // transparent parts will show the gradient underneath
        let offset = wordTable.contentOffset.y
        wordTableHeaderCoverHeight.constant = -1 * offset
        wordTableFooterCoverHeight.constant = footerGapHeight + offset
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == proxyTable {
            proxyTable.arrowFade(amount: 0.5)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == proxyTable {
            proxyTable.arrowFade(amount: 0.0)
        }
    }
    

    
    
    
    // MARK:- Helpers
    func configureCell(_ cell: WordListCell, atIndexPath indexPath: IndexPath) {
        
        // Fetch Word
        if let word = fetchedResultsController?.object(at: indexPath) as? Word {
            //TODO: can i use cell.wordtext property instead and eliminate the uilabel?
            //TODO: use the word.numTimesFound property to send the correctly colored tiles to the cell
            
            // Set aside for now. Need a way to pass fillingInBlanks from the view controller. Use Core Data?
            if word.game?.fillingInBlanks == true {
            //if fillingInBlanks == true {
                
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
    
    //MARK:- Table View Data Source Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = fetchedResultsController?.sections {
            return 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections {
            let sectionInfo = sections[section]
            /**** When data source was in the view controller, these 2 lines worked ***/
//            currentNumberOfWords = sectionInfo.numberOfObjects
//            return currentNumberOfWords!
            // Send the currentNumberOfWords to AtoZViewController
            let userInfo = ["item": sectionInfo.numberOfObjects]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCNOW"), object: nil, userInfo: userInfo)
            
            return sectionInfo.numberOfObjects
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
            
//            gradient = model.yellowPinkBlueGreenGradient()
//            gradient.frame = (cell?.bounds)!
            //mainGradient?.zPosition = -1
            //mainGradient?.name = "mainGradientLayer"
           
            //cell?.backgroundView?.layer.addSublayer(gradient)
//            let rainbow = UIView()
//            rainbow.layer.addSublayer(gradient)
//            cell?.addSubview(rainbow)
//            gradient = model.yellowPinkBlueGreenGradient()
//            gradient.frame = tableView.bounds
//            cell?.bg.layer.addSublayer(gradient)
            
            
            configureCell(cell!, atIndexPath: indexPath)
            return cell!
        }
        
    }
}

protocol WordTables {
    var wordTable: UITableView! {get}
    var proxyTable: ProxyTable! {get}
    var proxyTableArrow: UIImageView! {get}
    var gradient: CAGradientLayer! {get}
    var wordTableHeaderCover: UIView! {get}
    var wordTableHeaderCoverHeight: NSLayoutConstraint! {get}
    var wordTableFooterCoverHeight: NSLayoutConstraint! {get}
}

//extension Notification.Name {
//
//    static let PresentDefinition = Notification.Name(rawValue: "PresentDefinition")
//
//}


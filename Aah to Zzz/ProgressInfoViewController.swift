//
//  ProgressInfoViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 1/6/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

import UIKit

class ProgressInfoViewController: UIViewController {
    
    let model = AtoZModel.sharedInstance
    
    var numWordsPlayed: Int?
    var numWordsFound: Int?
    var numUniqueWordsPlayed: Int?
    var numUniqueWordsFound: Int?
    var percentageFound: Int?
    var levelByTenths: String?
    var levelFloat: Float?
    
    //var parentVC: ProgressViewController?
    
    @IBOutlet weak var playedWordsLabel: UILabel!
    
    @IBOutlet weak var uniqueWordsLabel: UILabel!
    
    @IBOutlet weak var percentageLabel: UILabel!
    
    @IBOutlet weak var levelLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //TODO: when level is <1, don't display "0 or more times"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        levelFloat = model.calculateLevel()
        view.layer.cornerRadius = 12.0
        //view.layer.mask?.cornerRadius = 12.0
        view.layer.masksToBounds = true
        //TODO: add in init?
        
        print ("TURNS: \(model.numListsPlayed())")
        
        if let numWordsPlayed = model.numWordsPlayed(), numWordsFound = model.numWordsFound() {
            var pluralize = ""
            if numWordsFound > 1 {
                pluralize = "s"
            }
            guard let numWordsFoundString = formatInt(numWordsFound), numWordsPlayedString = formatInt(numWordsPlayed) else {
                playedWordsLabel.text = ""
                return
            }
            playedWordsLabel.text = "\(numWordsFoundString) word" + pluralize + " out of \(numWordsPlayedString) words played"
        }
        
        if let numUniqueWordsFound = model.numUniqueWordsFound() {
            /* no longer need currentData  - get info from model.calculateLevel instead
             
            guard let currentGame = model.game else {
                return
            }
            guard let currentData = currentGame.data else {
                return
            }
            */
            
//            var pluralize = ""
//            
//            if currentData.level > 1 {
//                pluralize = "s"
//            }
            //uniqueWordsLabel.text = "You found \(numUniqueWordsFound) out of the \(numUniqueWordsPlayed) unique words played from a dictionary of \(model.wordsArray.count) three letter words"

            guard let levelFloatIn = levelFloat else {
            //String(format: "%.2d", model.calculateLevel())
                return
            }
            let baseLevel = Int(levelFloatIn)
            
            uniqueWordsLabel.text = "\(numUniqueWordsFound) of the \(model.wordsArray.count) words in the dictionary \(baseLevel) or more times"
        }
        
        
//        //if let percentageFound = model.percentageFound() {
//            percentageLabel.text = "Your percentage: \(model.percentageFound())%"
//        //}
        
        
    }

    override func viewWillAppear(animated: Bool) {
        /* Move calculate level to model, so no need now to call parent VC
        guard let parentVC = parentViewController as? ProgressViewController else {
            return
        }
        let levelFloat = parentVC.calculateLevel()
        */
//        let levelFloat = model.calculateLevel()
        //TODO: ought to be able to eliminate either levelString or levelbyTenths
        //TODO: can levelFloat be non-optional? Used twice, has to be unwrapped twice
        guard let levelFloatIn = levelFloat else {
            return
        }
        let levelString = String(format: "%.1f", levelFloatIn)
        levelByTenths = levelString //parentVC.calculateLevel()
        guard let levelText = levelByTenths else {
            return
        }
        levelLabel.text = "Level: " + levelText
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Add comma separators to large Int's
    // example to format by locale (e.g. France)
    // fmt.locale = NSLocale(localeIdentifier: "fr_FR")
    func formatInt(number: Int) -> String? {
        let numberFormat = NSNumberFormatter()
        numberFormat.numberStyle = .DecimalStyle
        return numberFormat.stringFromNumber(number)
    }
    


}

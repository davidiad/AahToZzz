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
    //var parentVC: ProgressViewController?
    
    @IBOutlet weak var playedWordsLabel: UILabel!
    
    @IBOutlet weak var uniqueWordsLabel: UILabel!
    
    @IBOutlet weak var percentageLabel: UILabel!
    
    @IBOutlet weak var levelLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            playedWordsLabel.text = "\(numWordsFound) word" + pluralize + " out of \(numWordsPlayed) words played"
        }
        
        if let numUniqueWordsFound = model.numUniqueWordsFound() {
            guard let currentGame = model.game else {
                return
            }
            guard let currentData = currentGame.data else {
                return
            }
//            var pluralize = ""
//            
//            if currentData.level > 1 {
//                pluralize = "s"
//            }
            //uniqueWordsLabel.text = "You found \(numUniqueWordsFound) out of the \(numUniqueWordsPlayed) unique words played from a dictionary of \(model.wordsArray.count) three letter words"
            uniqueWordsLabel.text = "\(numUniqueWordsFound) of the \(model.wordsArray.count) words in the dictionary \(currentData.level) or more times"
        }
        
        
//        //if let percentageFound = model.percentageFound() {
//            percentageLabel.text = "Your percentage: \(model.percentageFound())%"
//        //}
        
        
    }

    override func viewWillAppear(animated: Bool) {
        guard let parentVC = parentViewController as? ProgressViewController else {
            return
        }
        let levelFloat = parentVC.calculateLevel()
        //TODO: ought to be able to eliminate either levelString or levelbyTenths
        let levelString = String(format: "%.1f", levelFloat)
        levelByTenths = levelString //parentVC.calculateLevel()
        guard let levelText = levelByTenths else {
            return
        }
        levelLabel.text = "Overall Level: " + levelText
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

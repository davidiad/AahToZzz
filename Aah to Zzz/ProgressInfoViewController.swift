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
        //TODO: add in init?
        
        if let numWordsPlayed = model.numWordsPlayed(), numWordsFound = model.numWordsFound() {
            var pluralize = ""
            if numWordsFound > 1 {
                pluralize = "s"
            }
            playedWordsLabel.text = "You found \(numWordsFound) word" + pluralize + " out of \(numWordsPlayed) words played"
        }
        
        if let numUniqueWordsFound = model.numUniqueWordsFound() {
            guard let currentGame = model.game else {
                return
            }
            guard let currentData = currentGame.data else {
                return
            }
            var pluralize = ""
            
            if currentData.level > 1 {
                pluralize = "s"
            }
            //uniqueWordsLabel.text = "You found \(numUniqueWordsFound) out of the \(numUniqueWordsPlayed) unique words played from a dictionary of \(model.wordsArray.count) three letter words"
            uniqueWordsLabel.text = "Found \(numUniqueWordsFound) of the \(model.wordsArray.count) words in the dictionary at least \(currentData.level) time\(pluralize) each"
        }
        
        
        if let percentageFound = model.percentageFound() {
            percentageLabel.text = "Your percentage: \(percentageFound)%"
        }
        
        
    }

    override func viewWillAppear(animated: Bool) {
        guard let parentVC = parentViewController as? ProgressViewController else {
            return
        }
        levelByTenths = parentVC.calculateLevel()
        guard let levelText = levelByTenths else {
            return
        }
        levelLabel.text = "Your Level: " + levelText
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

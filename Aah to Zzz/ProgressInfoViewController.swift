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
    
    @IBOutlet weak var playedWordsLabel: UILabel!
    
    @IBOutlet weak var uniqueWordsLabel: UILabel!
    
    @IBOutlet weak var percentageLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: add in init?
        numWordsPlayed = model.numWordsPlayed()
        numWordsFound = model.numWordsFound()
        numUniqueWordsPlayed = model.numUniqueWordsPlayed()
        numUniqueWordsFound = model.numUniqueWordsFound()
        percentageFound = model.percentageFound()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

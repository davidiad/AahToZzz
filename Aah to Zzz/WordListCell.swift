//
//  WordListCell.swift
//  Aah to Zzz
//
//  Created by David Fierstein on 2/18/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit

class WordListCell: UITableViewCell {
    
    @IBOutlet weak var word: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
//    //MARK:- Cell delegate
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        word.text = "*  *  *"
//        word.backgroundColor = UIColor.yellowColor()
//    }

}

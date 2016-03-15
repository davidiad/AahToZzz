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
    @IBOutlet weak var bg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bg.image = UIImage(named: "merged_small_tiles")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}

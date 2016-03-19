//
//  WordListCell.swift
//  Aah to Zzz
//
//  Created by David Fierstein on 2/18/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit

class WordListCell: UITableViewCell {
    
    //TODO: create a wordInfo struct? or a subclass of UIView to hold the letter and small tile image?
    
    @IBOutlet weak var word: UILabel! // should really be named something less confusing like wordLabel
    // do i even still need 'word', the UILabel?
    @IBOutlet weak var bg: UIImageView!
    
    @IBOutlet weak var firstLetter: UILabel!
    @IBOutlet weak var secondLetter: UILabel!
    @IBOutlet weak var thirdLetter: UILabel!
    @IBOutlet weak var firstLetterBg: UIImageView!
    @IBOutlet weak var secondLetterBg: UIImageView!
    @IBOutlet weak var thirdLetterBg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bg.image = UIImage(named: "merged_small_tiles")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    var wordtext: String? {
        didSet {
            firstLetterBg.image = UIImage(named: "small_tile_yellow")
            firstLetter.text = wordtext?.substringToIndex(wordtext!.startIndex.successor())
            secondLetterBg.image = UIImage(named: "small_tile_yellow")
            secondLetter.text = wordtext?.substringWithRange(Range<String.Index>(start: wordtext!.startIndex.successor(), end: wordtext!.endIndex.predecessor()))
            thirdLetterBg.image = UIImage(named: "small_tile_yellow")
            thirdLetter.text = wordtext?.substringFromIndex(wordtext!.endIndex.predecessor())
        }

    }
    
    //MARK:- Cell delegate
    override func prepareForReuse() {
        super.prepareForReuse()
        wordtext = nil
        firstLetterBg.image = nil
        firstLetter.text = nil
        secondLetterBg.image = nil
        secondLetter.text = nil
        thirdLetterBg.image = nil
        thirdLetter.text = nil
        
        word.text = ""
    }

}

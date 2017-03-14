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
    @IBOutlet weak var outlineView: UIImageView!
    @IBOutlet weak var outlineShadowView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bg.image = UIImage(named: "merged_small_tiles")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    var colorCode: ColorCode?
    
    var wordtext: String? {
        didSet {
            firstLetterBg.image = colorCode?.tile_bg!
            firstLetter.text = wordtext?.substringToIndex(wordtext!.startIndex.successor())
            secondLetterBg.image = colorCode?.tile_bg!
            
            // Fix warning: 'init(start:end:)' is deprecated: it will be removed in Swift 3.  Use the '..<' operator.
            //secondLetter.text = wordtext?.substringWithRange(Range<String.Index>(start: wordtext!.startIndex.successor(), end: wordtext!.endIndex.predecessor()))
            secondLetter.text = wordtext?.substringWithRange( wordtext!.startIndex.successor() ..< wordtext!.endIndex.predecessor() )
                
                
            
            thirdLetterBg.image = colorCode?.tile_bg!//UIImage(named: "small_tile_yellow")
            thirdLetter.text = wordtext?.substringFromIndex(wordtext!.endIndex.predecessor())
            // set the image (if any) to use as an outline for the cell
            if let outline = colorCode?.outline {
                outlineView.image = outline
                //TODO: Set this once, elsewhere?
                if outlineView.image != nil {
                    outlineView.image = outlineView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                    //TODO: SHOULD BE SET IN COLORCODE
                    outlineView.tintColor = colorCode?.tint
//                    outlineShadowView.image = UIImage(named: "outline_shadow_unstretched")
//                    outlineShadowView.alpha = 0.45
                }
            }
            guard let shadow = colorCode?.shadow else {
                return
            }
            outlineShadowView.image = shadow
            outlineShadowView.alpha = 0.45
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
        outlineView.image = nil
        outlineShadowView.image = nil
        
        word.text = ""
        
        colorCode = nil
    }

}

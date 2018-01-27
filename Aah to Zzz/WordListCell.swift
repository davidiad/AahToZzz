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
    @IBOutlet weak var outlineTripleStripe: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bg.image = UIImage(named: "merged_small_tiles")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    var colorCode: ColorCode?
    
    var wordtext: String? {
        didSet {
            guard let wordtext = wordtext else {
                // TODO: handle error
                return
            }
            /* //Swift 3 version
            firstLetterBg.image = colorCode?.tile_bg!
            firstLetter.text = wordtext?.substring(to: wordtext!.characters.index(after: wordtext!.startIndex))
            secondLetterBg.image = colorCode?.tile_bg!
            secondLetter.text = wordtext?.substring( with: wordtext!.characters.index(after: wordtext!.startIndex) ..< wordtext!.characters.index(before: wordtext!.endIndex) )
            thirdLetterBg.image = colorCode?.tile_bg!//UIImage(named: "small_tile_yellow")
            thirdLetter.text = wordtext?.substring(from: wordtext!.characters.index(before: wordtext!.endIndex))
            //END */
            
            // Swift 4 version
            let index2 = wordtext.index(after: wordtext.startIndex)
            let index3 = wordtext.index(after: index2)
            firstLetter.text = String(wordtext.prefix(1))
            secondLetter.text = String(wordtext[index2 ..< index3])
            thirdLetter.text = String(wordtext[index3 ..< wordtext.endIndex])
            
            firstLetterBg.image = colorCode?.tile_bg!
            secondLetterBg.image = colorCode?.tile_bg!
            thirdLetterBg.image = colorCode?.tile_bg!
            // END

            // set the image (if any) to use as an outline for the cell
            if let outline = colorCode?.outline {
                outlineView.image = outline
                //TODO: Set this once, elsewhere?
                if outlineView.image != nil {
                    outlineView.image = outlineView.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
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
            
            // set the color of the inner stripe, but only if there is a tripled line
            if let tripleStripe = colorCode?.tripleStripe {
                
                outlineTripleStripe.image = tripleStripe
                if outlineTripleStripe.image != nil {
                    outlineTripleStripe.image = outlineTripleStripe.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                    if colorCode?.colorCode == 10 { // yellow is already fully saturated, so the inner stripe is desaturated and darker
                        outlineTripleStripe.tintColor = Colors.desat_yellow
                    } else {
                        outlineTripleStripe.tintColor = colorCode?.saturatedColor
                    }
                }
            }
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
        outlineTripleStripe.image = nil
        
        word.text = ""
        
        colorCode = nil
    }

}

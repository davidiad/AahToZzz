//
//  Tile.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/4/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit

//TODO: add to model: LetterPositions (10); TileInfo - 7 (?) -- or add to Letter? or, add location(or position) or LetterPosition to Letter, and from there, add to tile

class Tile: UIButton {
    var snapBehavior: UISnapBehavior?
    //TODO: this property is confusing, as there is also a position property in Letter which is a Position
    // check whether it's really needed? The Tile should get its position from its letter.position property
    var position: CGPoint? // when this is updated, need to also update the letter position
    var letter: Letter? // letter.position.position would remove the need for the CGPoint position
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
    }
    
}
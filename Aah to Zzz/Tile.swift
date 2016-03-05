//
//  Tile.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/4/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit

class Tile: UIButton {
    var snapBehavior: UISnapBehavior?
    var location: CGPoint?
    
    
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
//
//  StatusView.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/10/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//

import UIKit

class StatusView: UIView {

    override var bounds: CGRect {
        didSet {
            print("BOUNDS CHANGED")
            print(bounds)
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

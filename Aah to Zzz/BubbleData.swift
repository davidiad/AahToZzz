//
//  BubbleData.swift
//  AahToZzz
//
//  Created by David Fierstein on 5/7/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//
import UIKit

struct BubbleData {
    var startPoint: CGPoint
    var endPoint:   CGPoint
    var text:       [String]
}

// startPoint (where the arrow starts on the bubble) could be generated from endPoint (what the arrow is pointing to), with options, including customization
// Could also be adjusted after a check to see if the entire bubble fits on screen

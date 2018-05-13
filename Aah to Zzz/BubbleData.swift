//
//  BubbleData.swift
//  AahToZzz
//
//  Created by David Fierstein on 5/7/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//
import UIKit

struct BubbleData {
    let xShift:       CGFloat = 45
    let yShift:       CGFloat = 60
    var adjustFactor: (x: CGFloat, y: CGFloat) = (1.0, 1.0)
    var offset:       (CGFloat, CGFloat)       = (-1.0,-1.0) // default is arrow points down and right
    var text:         [String]
    var endPoint:     CGPoint
    var direction:    ArrowDirection
    var startPoint:   CGPoint?


// startPoint (where the arrow starts on the bubble) could be generated from endPoint (what the arrow is pointing to), with options, including customization
// Could also be adjusted after a check to see if the entire bubble fits on screen

    init(text: [String], endPoint: CGPoint, direction: ArrowDirection, adjustFactor: (CGFloat,CGFloat) = (x: 1, y: 1)) {
    
        self.text         = text
        self.endPoint     = endPoint
        self.direction    = direction
        self.adjustFactor = adjustFactor
        // the start point is calculated relative to end point, so directions are opposite from the way it's pointing
        switch direction {
        case .up:
            offset = (0, 1)
        case .down:
            offset = (0, -1)
        case .upright:
            offset = (-1, 1)
        case .downright:
            offset = (-1, -1)
        case .upleft:
            offset = (1,1)
        case .downleft:
            offset = (1, -1)
        }
        
        startPoint = CGPoint(x: endPoint.x + (offset.0 * xShift * adjustFactor.0),
                             y: endPoint.y + (offset.1 * yShift * adjustFactor.1))
        
    }
    
    //TODO: an init where startPt is given, but direction is not
}

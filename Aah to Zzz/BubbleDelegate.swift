//
//  BubbleDelegate.swift
//  AahToZzz
//
//  Created by David Fierstein on 5/3/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//
import UIKit

class BubbleDelegate: Bubble {
    var bubbleText: [String] = ["Tap or drag tiles",
                                "to create a beautiful formation",
                                "of three letter words"]
    
    
    //TODO:- Put stackivew/label functionality into a protocol
    func addStackView() -> UIStackView {
        
        let inset: CGFloat = 8.0
        var corner = CGPoint()
        if quadCorners.count > 3 { // need to ensure we don't try to access out of array bounds
            if d > 0 { corner = quadCorners[2] } // arrow points down, upper left corner is quadCorners[2]
            else     { corner = quadCorners[3] } // arrow points up, upper left corner is quadCorners[3]
        }
        
        let stackViewFrame = CGRect(x: corner.x + inset, y: corner.y + inset, width: bubbleWidth + 2 * startWth - (2 * inset), height: bubbleHeight - 2 * inset)
        let sv = UIStackView(frame: stackViewFrame.insetBy(dx: inset, dy: inset))
        sv.spacing          = 8.3
        sv.axis             = .vertical
        sv.alignment        = .center
        sv.distribution     = .fillEqually
        
        for s in bubbleText {
            let label = UILabel()
            label.text = s
            label.backgroundColor = UIColor.purple
            label.textAlignment = .center
            label.numberOfLines = 1
            sv.addArrangedSubview(label)
            
        }
        
        //addSubview(sv)
        return sv  // add the subview in ArrowView
    }
    
    // wrapper with no parameters
    func getBubbleSize() -> CGSize {
        return calculateBubbleSizeFromText(textArray: bubbleText)
    }
    
    func calculateBubbleSizeFromText (textArray: [String]) -> CGSize {
        let lineHeightFactor: CGFloat   = 27.0
        let textWidthFactor:  CGFloat   =  5.0
        let bubbleHeight = CGFloat(textArray.count + 1) * lineHeightFactor
        // assuming the largest strings have been put in the middle, shorts on the outside (to fit in a bubble)
        var maxLength = 0
        for s in textArray {
            if s.count > maxLength {
                maxLength = s.count
            }
        }
        let bubbleWidth = CGFloat(maxLength + 6) * textWidthFactor
    
        return CGSize(width: bubbleWidth, height: bubbleHeight)
    }
}

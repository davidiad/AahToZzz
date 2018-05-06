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
                                "of three letter words",
                                "three letter words",
                                "3 letters"]
    
    var startPoint: CGPoint?
    var startWth:   CGFloat     = 3.0
    var d:          CGFloat     = 1.0
    
    var bubbleSize: CGSize?
    var corner:     CGPoint     = CGPoint(x: 0, y: 0)
    
    //TODO:- Put stackivew/label functionality into a protocol
    func addStackView() -> UIStackView {
        
        let inset: CGFloat = 8.0
        
        guard let bubbleWidth = bubbleSize?.width, let bubbleHeight = bubbleSize?.height else {
            return UIStackView()
        }
//        if quadCorners.count > 3 { // need to ensure we don't try to access out of array bounds
//            if d > 0 { corner = quadCorners[2] } // arrow points down, upper left corner is quadCorners[2]
//            else     { corner = quadCorners[3] } // arrow points up, upper left corner is quadCorners[3]
//        }
        
        let stackViewFrame = CGRect(x: corner.x + inset, y: corner.y + inset, width: bubbleWidth - (2 * inset), height: bubbleHeight - 2 * inset)
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
        bubbleSize = calculateBubbleSizeFromText(textArray: bubbleText)
        guard let bubbleSize = bubbleSize else {
            return CGSize(width: 100, height: 100) // default values
        }
        return bubbleSize
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
    
    func getQuadCorners() -> [CGPoint] {
        guard let startPoint = startPoint, let bubbleSize = bubbleSize else {
            return []
        }
        let bx = bubbleSize.width  * 0.5
        let by = bubbleSize.height * 0.5 * d // d is -1.0 when arrow points up
        // points for quad curve bubble
        let cornerLowerRight = CGPoint(x: startPoint.x  + bx, y: startPoint.y         )
        let cornerUpperRight = CGPoint(x: startPoint.x  + bx, y: startPoint.y - by * 2)
        let cornerUpperLeft  = CGPoint(x: startPoint.x  - bx, y: startPoint.y - by * 2)
        let cornerLowerLeft  = CGPoint(x: startPoint.x  - bx, y: startPoint.y          )
//        let cornerLowerRight = CGPoint(x: startRight.x + bx, y: startRight.y         )
//        let cornerUpperRight = CGPoint(x: startRight.x + bx, y: startRight.y - by * 2)
//        let cornerUpperLeft  = CGPoint(x: startLeft.x  - bx, y: startLeft.y  - by * 2)
//        let cornerLowerLeft  = CGPoint(x: startLeft.x  - bx, y: startLeft.y          )
        
        var quadCorners: [CGPoint] = []
        quadCorners.append(cornerLowerRight)
        quadCorners.append(cornerUpperRight)
        quadCorners.append(cornerUpperLeft)
        quadCorners.append(cornerLowerLeft)
        if quadCorners.count > 3 { // need to ensure we don't try to access out of array bounds
            if d > 0 { corner = quadCorners[2] } // arrow points down, upper left corner is quadCorners[2]
            else     { corner = quadCorners[3] } // arrow points up,   upper left corner is quadCorners[3]
        }
        return quadCorners
        
    }
    
    func getQuadPoints() -> [CGPoint] { // return quadPoints
        guard let startPoint = startPoint, let bubbleSize = bubbleSize else {
            return []
        }
        let bx = bubbleSize.width  * 0.5
        let by = bubbleSize.height * 0.5 * d // d is -1.0 when arrow points up
        let bubbleRight      = CGPoint(x: startPoint.x + bx,       y: startPoint.y - by    )
        let bubbleTop        = CGPoint(x: startPoint.x,            y: startPoint.y - by * 2)
        let bubbleLeft       = CGPoint(x: startPoint.x - bx,       y: startPoint.y - by    )
        let startLeft        = CGPoint(x: startPoint.x - startWth, y: startPoint.y)
        
        var quadPoints: [CGPoint] = []
        quadPoints.append(bubbleRight)
        quadPoints.append(bubbleTop)
        quadPoints.append(bubbleLeft)
        quadPoints.append(startLeft) // last quad point is back at beginning
        
        return quadPoints
    }
}
//    func Bubble-points-code() {
//
//        // points for corners of Rectangle bubbles are same as quadcurve control pts
//        if bubbleType == .quadcurve || bubbleType == .rectangle {
//            let bx = bubbleWidth  * 0.5
//            let by = bubbleHeight * 0.5 * d // d is -1.0 when arrow points up
//            // points for quad curve bubble
//            let cornerLowerRight = CGPoint(x: startRight.x + bx, y: startRight.y         )
//            let cornerUpperRight = CGPoint(x: startRight.x + bx, y: startRight.y - by * 2)
//            let cornerUpperLeft  = CGPoint(x: startLeft.x  - bx, y: startLeft.y  - by * 2)
//            let cornerLowerLeft  = CGPoint(x: startLeft.x  - bx, y: startLeft.y          )
//            quadCorners.append(cornerLowerRight)
//            quadCorners.append(cornerUpperRight)
//            quadCorners.append(cornerUpperLeft)
//            quadCorners.append(cornerLowerLeft)
//
//            if bubbleType == .quadcurve {
//                let bubbleRight      = CGPoint(x: startRight.x + bx, y: startRight.y - by    )
//                let bubbleTop        = CGPoint(x: startPoint.x,      y: startPoint.y - by * 2)
//                let bubbleLeft       = CGPoint(x: startLeft.x  - bx, y: startPoint.y - by    )
//                quadPoints.append(bubbleRight)
//                quadPoints.append(bubbleTop)
//                quadPoints.append(bubbleLeft)
//                quadPoints.append(startLeft) // last quad point is back at beginning
//            }

        /*** END Bubble points code ***/
        
        
        



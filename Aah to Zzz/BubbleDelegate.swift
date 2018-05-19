//
//  BubbleDelegate.swift
//  AahToZzz
//
//  Created by David Fierstein on 5/3/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//
import UIKit

class BubbleDelegate: Bubble {
    
    // to replace with bubbleData.text
//    var bubbleText: [String] = ["Tap or drag tiles",
//                                "to create a beautiful formation",
//                                "of three letter words",
//                                "three letter words",
//                                "3 letters"]
    var bubbleData: BubbleData?
    //var startPoint: CGPoint? // to replace with bubbleData.startPoint
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
        sv.spacing          = 1.3
        sv.axis             = .vertical
        sv.alignment        = .center
        sv.distribution     = .fillEqually
        
        guard let bubbleData = bubbleData else {
            return UIStackView()
        }
        for s in bubbleData.text {
            let label = UILabel()
            label.attributedText = formatText(textToFormat: s)
            label.clipsToBounds = false
            //label.text = s
            //let unconstrainedSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            //label.heightAnchor.constraint(equalToConstant: label.sizeThatFits(unconstrainedSize).height).isActive = true
            //label.lineBreakMode = .byCharWrapping
            //label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 700), for: .vertical)
//            label.backgroundColor = UIColor.cyan
//            label.textAlignment = .center
//            label.numberOfLines = 1
            sv.addArrangedSubview(label)
            
        }
        
        //addSubview(sv)
        return sv  // add the subview in ArrowView
    }
    
    // wrapper with no parameters
    func getBubbleSize() -> CGSize {
        guard let bt = bubbleData else {
            return CGSize.zero
        }
        bubbleSize = calculateBubbleSizeFromText(textArray: bt.text)
        print (bt.text)
        guard let bubbleSize = bubbleSize else {
            return CGSize(width: 100, height: 100) // default values
        }
        return bubbleSize
    }
    
    func calculateBubbleSizeFromText (textArray: [String]) -> CGSize {
        let lineHeightFactor: CGFloat   = 29.0
        let textWidthFactor:  CGFloat   =  7.5
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
    
    // Format the text
    func formatText(textToFormat: String) -> NSAttributedString {
        
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 3
        shadow.shadowOffset = CGSize(width: 0, height: 3)
        shadow.shadowColor = UIColor.gray
        
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .center
        
        let multipleAttributes: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.font: UIFont(name: "Noteworthy-Bold", size: 18.0)!,
            NSAttributedStringKey.paragraphStyle: paraStyle,
            NSAttributedStringKey.shadow: shadow,
            NSAttributedStringKey.strokeColor: Colors.lighterDarkBrown,
            NSAttributedStringKey.strokeWidth: -4.0,
            NSAttributedStringKey.foregroundColor: Colors.darkBackground]
        
        return NSAttributedString(string: textToFormat, attributes: multipleAttributes)
    }
    
    func getQuadCorners() -> [CGPoint] {
        guard let startPoint = bubbleData?.startPoint, let bubbleSize = bubbleSize else {
            return []
        }
        let bx = bubbleSize.width  * 0.5
        let by = bubbleSize.height * 0.5 * d // d is -1.0 when arrow points up
        // points for quad curve bubble
        var cornerLowerRight = CGPoint(x: startPoint.x  + bx, y: startPoint.y         )
        var cornerUpperRight = CGPoint(x: startPoint.x  + bx, y: startPoint.y - by * 2)
        var cornerUpperLeft  = CGPoint(x: startPoint.x  - bx, y: startPoint.y - by * 2)
        var cornerLowerLeft  = CGPoint(x: startPoint.x  - bx, y: startPoint.y         )
        
        // check if bubble is near or over the edge of the screen.
        // if so, shift the startPoint  and reset the corners
        var shift: CGPoint? = shiftIfOutOfBounds(corners: [cornerLowerRight, cornerUpperLeft])
        if shift != nil {
            if let sx = shift?.x, let sy = shift?.y {
                let shiftStart = CGPoint(x: startPoint.x + sx, y: startPoint.y + sy)
                // reset the shifted corner points
                cornerLowerRight = CGPoint(x: shiftStart.x  + bx, y: shiftStart.y         )
                cornerUpperRight = CGPoint(x: shiftStart.x  + bx, y: shiftStart.y - by * 2)
                cornerUpperLeft  = CGPoint(x: shiftStart.x  - bx, y: shiftStart.y - by * 2)
                cornerLowerLeft  = CGPoint(x: shiftStart.x  - bx, y: shiftStart.y         )
                
                bubbleData?.startPoint = shiftStart
            }
        }
        
        var quadCorners: [CGPoint] = []
        quadCorners.append(cornerLowerRight)
        quadCorners.append(cornerUpperRight)
        quadCorners.append(cornerUpperLeft)
        quadCorners.append(cornerLowerLeft)
        if quadCorners.count > 3 { // ensure we don't try to access out of array bounds
            if d > 0 { corner = quadCorners[2] } // arrow points down, upper left corner is quadCorners[2]
            else     { corner = quadCorners[3] } // arrow points up,   upper left corner is quadCorners[3]
        }
        
        return quadCorners
        
    }
    
    // To adjust so bubble never runs offscreen
    func shiftIfOutOfBounds(corners: [CGPoint]) -> CGPoint? {

        var isShift = false // test to return nil if no shift is needed
        let bufferX: CGFloat = 12
        let bufferY: CGFloat = 50
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        var shiftX: CGFloat = 0 // amount to shift the startPoint in x
        var shiftY: CGFloat = 0 // amount to shift the startPoint in y

        // check opposite corners
        if corners[1].x < bufferX {
            // get the shiftX (positive)
            shiftX = -corners[1].x + bufferX
            isShift = true
        }
        let maxX = w - bufferX
        if corners[0].x > maxX {
            // Add the negative shiftX (note that if both sides are past the buffer, the bubble may still go past buffer)
            shiftX += maxX - corners[0].x
            isShift = true
        }
        // If both are true, the bubble might extend pass edge of screen on both sides)
        
        if corners[1].y < bufferY {
            // get the shiftX (positive)
            shiftY = -corners[1].y + bufferY
            isShift = true
        }
        let maxY = h - bufferY
        if corners[0].y > maxY {
            // Add the negative shiftX (note that if both sides are past the buffer, the bubble may still go past buffer)
            shiftY += maxY - corners[0].y
            isShift = true
        }
        
        if (isShift == true) {
            return CGPoint(x: shiftX, y: shiftY)
        }
        return nil

        
    // Adjust startPoint, and bubbleData.startPoint, by that amount, plus a buffer
    // Proceed to calculating the corners and points
    }
    
//    func getMin(value1: CGFloat, value2: CGFloat) -> CGFloat {
//        if value1 < value2 {
//            return value1
//        } else {
//            return value2
//        }
//    }
    
    
    func getQuadPoints() -> [CGPoint] { // return quadPoints
        guard let startPoint = bubbleData?.startPoint, let bubbleSize = bubbleSize else {
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
        
        
        



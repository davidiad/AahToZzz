//
//  ArrowBlurView.swift
//  AahToZzz
//
//  Created by David Fierstein on 4/18/18.
//  Copyright © 2018 David Fierstein. All rights reserved.

import UIKit

class ArrowView: ShapeView {
    
    let bubbleText1: [String] = ["Tap or drag tiles",
                                 "to form",
                                 "three letter words"]
    
    //MARK: Arrow const's and vars
    //Wth == WIDTH, Ht == HEIGHT

    let TANGENTLIMIT:   CGFloat     = 5.0  // prevents control pt adjustments when close to vertical
    let CPMULTIPLIER:   CGFloat     = 0.4  // empirical const for amount of control pt adjustment
    
    var startWth:       CGFloat     = 17.0
    var endWth:         CGFloat     = 9.0
    var arrowWth:       CGFloat     = 24.0
    var arrowHt:        CGFloat     = 19.0
    // TODO:- add text bubble size vars (ht and width), with defaults
    // add init's that allow adding text bubble and choosing its shape
    var bubbleWidth:    CGFloat     = 100.0
    var bubbleHeight:   CGFloat     = 100.0
    
    var cpValue1:       CGFloat     = 36.0
    var cpValue2:       CGFloat     = 36.0

    var arrowType:      ArrowType   = .curved
    var bubbleType:     BubbleType  = .none
    var arrowPoints:    [CGPoint]   = []
    var quadPoints:     [CGPoint]   = []
    var quadCorners:    [CGPoint]   = [] //Control pts for Quadcurve bubbles, same as pts for Rectangle
    var bezierPoints:   [[CGPoint]] = []
    
    //MARK:- Convenience init's
    // Get start/end points from frame
    convenience init(arrowType: ArrowType, frame: CGRect, blurriness: CGFloat, shadowWidth: CGFloat) {
        self.init(frame: frame)
        self.arrowType      = arrowType
        self.blurriness     = blurriness
        self.shadowWidth    = shadowWidth
        useFrameForPoints()
        addViews()
    }
    
    // use default blur and shadow
    convenience init(arrowType: ArrowType, startPoint: CGPoint, endPoint: CGPoint) {
        // Question: does it matter what the size of the frame is?
        // it'd be overly complex to calculate from start/end points
        self.init(frame: CGRect(x: 65, y: 20, width: 10, height: 5)) // default frame, because not optional, so always needs to be defined
        self.arrowType  = arrowType
        self.startPoint = startPoint
        self.endPoint   = endPoint
        
        addViews()
    }
    
    // allow control of blur and shadow, as well as start/end points
    convenience init(arrowType: ArrowType,
                     startPoint: CGPoint, endPoint: CGPoint,
                     blurriness: CGFloat, shadowWidth: CGFloat) {
        
        self.init(frame: CGRect(x: 65, y: 20, width: 10, height: 5)) // default frame, because not optional, so always needs to be defined
        self.arrowType      = arrowType
        self.startPoint     = startPoint
        self.endPoint       = endPoint
        self.blurriness     = blurriness
        self.shadowWidth    = shadowWidth
        
        addViews()
        
    }
    
    func calculateBubbleSizeFromText (textArray: [String]) {
        let lineHeightFactor: CGFloat   = 27.0
        let textWidthFactor:  CGFloat   =  6.0
        bubbleHeight = CGFloat(textArray.count + 1) * lineHeightFactor
        // assuming the largest strings have been put in the middle, shorts on the outside (to fit in a bubble)
        var maxLength = 0
        for s in textArray {
            if s.count > maxLength {
                maxLength = s.count
            }
        }
        bubbleWidth = CGFloat(maxLength + 10) * textWidthFactor
    }
    
    //TODO:- Put stackivew/label functionality into a protocol
    func addStackView() {
        let sv = UIStackView(frame: CGRect(x: bounds.minX + 20.0, y: bounds.minY + 12.0, width: bubbleWidth, height: bubbleHeight - 24.0))
        sv.spacing = 8.3
        
        let l1 = UILabel()
        l1.backgroundColor = .red
        l1.textAlignment = .center
        l1.numberOfLines = 1
        l1.text = bubbleText1[0]
        let l2 = UILabel()
        l2.backgroundColor = Colors.bluek
        l2.text = bubbleText1[1]
        l2.textAlignment = .center
        let l3 = UILabel()
        l3.backgroundColor = UIColor.orange
        l3.text = bubbleText1[2]
        l3.textAlignment = .center
        sv.addArrangedSubview(l1)
        sv.addArrangedSubview(l2)
        sv.addArrangedSubview(l3)
        sv.axis = .vertical
        addSubview(sv)
        
    }
    
    // allow control of blur and shadow and all arrow parameters
    //TODO: consider making more of the parameters optional
    convenience init(arrowType: ArrowType,
                     startPoint:    CGPoint, endPoint:     CGPoint,
                     startWidth:    CGFloat, endWidth:     CGFloat,
                     arrowWidth:    CGFloat, arrowHeight:  CGFloat,
                     blurriness:    CGFloat     = 0.5,
                     shadowWidth:   CGFloat     = 3.5,
                     bubbleWidth:   CGFloat     = 100.0,
                     bubbleHeight:  CGFloat     = 100.0,
                     bubbleType:    BubbleType  = .none ) {
        
        self.init(frame: CGRect(x: 65, y: 20, width: 10, height: 5))
        
        self.arrowType      = arrowType
        self.startPoint     = startPoint
        self.endPoint       = endPoint
        self.startWth       = startWidth
        self.endWth         = endWidth
        self.arrowWth       = arrowWidth
        self.arrowHt        = arrowHeight
        // optional parameters
        self.blurriness     = blurriness
        self.shadowWidth    = shadowWidth
        self.bubbleType     = bubbleType
        if self.bubbleType != .none {
            if bubbleWidth < 0.01 || bubbleHeight < 0.01 {
                self.bubbleType = .none // bubble dimensions must be > 0
                // TODO: check other parameter values for validity
            }
            self.bubbleWidth  = bubbleWidth
            self.bubbleHeight = bubbleHeight
        }
        calculateBubbleSizeFromText(textArray: bubbleText1) // bubble dimensions must be determined before creating views
        addViews()
        addStackView()
    }
    
    // helper for inits
    func addViews() {
        addShapeView()
        if blurriness   > 0.01 { addBlurView()   }
        if shadowWidth  > 0.01 { addShadowView() }
    }
    
    //MARK:- Path and shape creation
    // createShape has no parameters, so it can be called in the ShapeView superclass in the
    // addShapeView() func. Therefore, need another func addPoints(...) that *can* contain
    // parameters specific to this subclass
    override func createShape() {
        addPoints(arrowType: arrowType, bubbleType: bubbleType)
        createPath() // works with all types
    }
    
    func addPoints(arrowType: ArrowType, bubbleType: BubbleType) {
        
        /*** Vars needed for all cases ***/
        // startPoint. endPoint, startLeft and startRight are needed in all cases
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        let startLeft  = CGPoint(x: startPoint.x   - startWth,   y: startPoint.y)
        let startRight = CGPoint(x: startPoint.x   + startWth,   y: startPoint.y)
        /*** END Vars needed for all cases ***/
        
        /*** Bubble points code should be accessible with any of the arrow type options ***/
        // points for corners of Rectangle bubbles are same as quadcurve control pts
        if bubbleType == .quadcurve || bubbleType == .rectangle {
            let bx = bubbleWidth  * 0.5
            let by = bubbleHeight * 0.5 * d // d is -1.0 when arrow points up
            // points for quad curve bubble
            let cornerLowerRight = CGPoint(x: startRight.x + bx, y: startRight.y         )
            let cornerUpperRight = CGPoint(x: startRight.x + bx, y: startRight.y - by * 2)
            let cornerUpperLeft  = CGPoint(x: startLeft.x  - bx, y: startLeft.y  - by * 2)
            let cornerLowerLeft  = CGPoint(x: startLeft.x  - bx, y: startLeft.y          )
            quadCorners.append(cornerLowerRight)
            quadCorners.append(cornerUpperRight)
            quadCorners.append(cornerUpperLeft)
            quadCorners.append(cornerLowerLeft)
            
            if bubbleType == .quadcurve {
                let bubbleRight      = CGPoint(x: startRight.x + bx, y: startRight.y - by    )
                let bubbleTop        = CGPoint(x: startPoint.x,      y: startPoint.y - by * 2)
                let bubbleLeft       = CGPoint(x: startLeft.x  - bx, y: startPoint.y - by    )
                quadPoints.append(bubbleRight)
                quadPoints.append(bubbleTop)
                quadPoints.append(bubbleLeft)
                quadPoints.append(startLeft) // last quad point is back at beginning
            }
        }
        /*** END Bubble points code ***/
        
        
        // create and add the points in the order they will be used
        // put points into their arrays
        switch arrowType {
        case .curved:
            
            adjustControlPoints()
            
            let innerPointRight   = CGPoint(x: endPoint.x   + endWth,   y: endPoint.y   - arrowHt * d               )
            let innerPointLeft    = CGPoint(x: endPoint.x   - endWth,   y: endPoint.y   - arrowHt * d               )
            let outerPointRight   = CGPoint(x: endPoint.x   + arrowWth, y: endPoint.y   - arrowHt * d               )
            let outerPointLeft    = CGPoint(x: endPoint.x   - arrowWth, y: endPoint.y   - arrowHt * d               )
            let endControlRight   = CGPoint(x: endPoint.x   + endWth,   y: endPoint.y   - arrowHt * d   - cpValue1  )
            let endControlLeft    = CGPoint(x: endPoint.x   - endWth,   y: endPoint.y   - arrowHt * d   - cpValue2  )
            let startControlLeft  = CGPoint(x: startPoint.x - startWth, y: startPoint.y                 + cpValue1  )
            let startControlRight = CGPoint(x: startPoint.x + startWth, y: startPoint.y                 + cpValue2  )
            
            arrowPoints.append(startLeft)
            arrowPoints.append(outerPointLeft)
            arrowPoints.append(endPoint)
            arrowPoints.append(outerPointRight)
            arrowPoints.append(innerPointRight)
            
            bezierPoints.append([innerPointLeft, startControlLeft, endControlLeft])
            bezierPoints.append([startRight, endControlRight, startControlRight])
            
        case .pointer:
            
            let endLeft           = CGPoint(x: endPoint.x    - endWth,   y: endPoint.y)
            let endRight          = CGPoint(x: endPoint.x    + endWth,   y: endPoint.y)

            arrowPoints.append(startLeft)
            arrowPoints.append(endLeft)
            arrowPoints.append(endRight)
            arrowPoints.append(startRight)

        case .straight:
            let arrowheadPoints = getRotatedArrowheadPts()
            arrowPoints.append(startLeft)
            arrowPoints.append(arrowheadPoints[0])
            arrowPoints.append(arrowheadPoints[1])
            arrowPoints.append(endPoint)
            arrowPoints.append(arrowheadPoints[2])
            arrowPoints.append(arrowheadPoints[3])
            arrowPoints.append(startRight)
        }
    }
    
    // Makes path from points stored in arrays
    func createPath () { // works for .pointer and .straight and .curved
        
        // Create the arrow path, open at top to optionally accept adding bubble to path
        path.move   (to: arrowPoints[0])
        
        if arrowType == .curved {
            path.addCurve(to: bezierPoints[0][0], controlPoint1: bezierPoints[0][1], controlPoint2: bezierPoints[0][2])
        }
        
        for i in 1 ..< arrowPoints.count {
            path.addLine(to: arrowPoints[i])
        }
        
        if arrowType == .curved {
            path.addCurve(to: bezierPoints[1][0], controlPoint1: bezierPoints[1][1], controlPoint2: bezierPoints[1][2])
        }
        
        // Add bubble to path (optional)
        switch bubbleType {
        case .none:
            print("do nothing")
        
        case .quadcurve:
            for i in 0 ..< quadPoints.count {
                // quadPoints are in middle of sides, quadCorners are in the corners
                path.addQuadCurve(to: quadPoints[i], controlPoint: quadCorners[i])
            }
        case .rectangle:
            for i in 0 ..< quadCorners.count {
                path.addLine(to: quadCorners[i])
            }
        }
        
        path.close()
    }
    
    /* // Curved (Bezier) Arrow
    // Curved arrow, arrowhead points straight up or down
    func createBezierArrow () {
        
        if startPoint == nil {
            useFrameForPoints()
        }
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        
        adjustControlPoints()
        
        let startPointLeft    = CGPoint(x: startPoint.x - startWth, y: startPoint.y                             )
        let startPointRight   = CGPoint(x: startPoint.x + startWth, y: startPoint.y                             )
        let innerPointRight   = CGPoint(x: endPoint.x   + endWth,   y: endPoint.y   - arrowHt * d               )
        let innerPointLeft    = CGPoint(x: endPoint.x   - endWth,   y: endPoint.y   - arrowHt * d               )
        let outerPointRight   = CGPoint(x: endPoint.x   + arrowWth, y: endPoint.y   - arrowHt * d               )
        let outerPointLeft    = CGPoint(x: endPoint.x   - arrowWth, y: endPoint.y   - arrowHt * d               )
        let endControlRight   = CGPoint(x: endPoint.x   + endWth,   y: endPoint.y   - arrowHt * d   - cpValue1  )
        let endControlLeft    = CGPoint(x: endPoint.x   - endWth,   y: endPoint.y   - arrowHt * d   - cpValue2  )
        let startControlLeft  = CGPoint(x: startPoint.x - startWth, y: startPoint.y                 + cpValue1  )
        let startControlRight = CGPoint(x: startPoint.x + startWth, y: startPoint.y                 + cpValue2  )
        
        //path.move       (to: startPoint)
        path.move       (to: startPointRight)
        path.addCurve   (to: innerPointRight, controlPoint1: startControlRight,  controlPoint2: endControlRight)
        path.addLine    (to: outerPointRight)
        path.addLine    (to: endPoint)
        path.addLine    (to: outerPointLeft)
        path.addLine    (to: innerPointLeft)
        path.addCurve   (to: startPointLeft, controlPoint1: endControlLeft, controlPoint2: startControlLeft)
        
     
        // add them to arrays
        // In each create func, add the lines/quadcurves from the arrays per options chosen
        
        
        // make an ellipse above
        if bubbleType == .quadcurve {
            let bw = bubbleWidth  * 0.5
            let bh = bubbleHeight * 0.5 * d // d is -1.0 when points up
        path.addQuadCurve(to: CGPoint(x: startPointLeft.x - bw, y: startPoint.y - bh   ), controlPoint: CGPoint(x: startPointLeft.x - bw, y: startPoint.y    ))
        path.addQuadCurve(to: CGPoint(x: startPoint.x, y: startPoint.y - bh * 2   ), controlPoint: CGPoint(x: startPointLeft.x - bw, y: startPoint.y - bh * 2      ))
        path.addQuadCurve(to: CGPoint(x: startPointRight.x + bw, y: startPointRight.y - bh   ), controlPoint: CGPoint(x: startPointRight.x + bw, y: startPoint.y - bh * 2     ))
        path.addQuadCurve(to: startPointRight, controlPoint: CGPoint(x: startPointRight.x + bw, y: startPoint.y     ))
        }

        //path.addQuadCurve(to: CGPoint(x: startPointLeft.x, y: startPoint.y   ), controlPoint: CGPoint(x: startPointLeft.x - 100, y: startPoint.y    ))
        
        
        path.close      ()
    }
    */
    
    func adjustControlPoints() {
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        
        // in case where the arrow is too short, reduce control point offsets
        let ht = abs(endPoint.y - startPoint.y)
        if ht < 2 * cpValue1 {
            cpValue1 = ht * 0.45
        }
        // If arrow points up, d will be -1.0  Otherwise d = 1.0
        cpValue1 *= d

        // make the values equal for now
        cpValue2 = cpValue1
        
        // adjust one control point, depending on the angle of the arrow
        // to make graceful curves, with inner and outer curves matching
        let xShift = endPoint.x - startPoint.x
        
        // arrow points right
        if abs(xShift) > TANGENTLIMIT { // prevent divide by 0 (or close to 0)
            let tangent = abs((endPoint.y - startPoint.y) / xShift)
            if tangent < TANGENTLIMIT { // no adjustment if angle is close to 90°
                cpValue1 *= (1.0 + (CPMULTIPLIER / tangent))
            }
        } else { // Angle close to vertical, so don't pull out control points at all
            cpValue1 = 0.0
            cpValue2 = 0.0
        }
        // arrow points toward left, so skew control points the other way
        if xShift < -TANGENTLIMIT {
            swapCPValues()
        }
    }
    
    func swapCPValues () {
        let tempValue   = cpValue1
        cpValue1        = cpValue2
        cpValue2        = tempValue
    }
    
    /* Straight (Rotated) Arrow
    func createStraightArrow () {
        
        if startPoint == nil {
            useFrameForPoints()
        }
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        
        let startPointLeft    = CGPoint(x: startPoint.x - startWth, y: startPoint.y                             )
        let startPointRight   = CGPoint(x: startPoint.x + startWth, y: startPoint.y                             )
        let arrowheadPoints   = getRotatedArrowheadPts()
        
        path.move       (to: startPoint)
        path.addLine    (to: startPointRight)
        path.addLine    (to: arrowheadPoints[1])
        path.addLine    (to: arrowheadPoints[0])
        path.addLine    (to: endPoint)
        path.addLine    (to: arrowheadPoints[3])
        path.addLine    (to: arrowheadPoints[2])
        path.addLine    (to: startPointLeft)
        path.close      ()
    }
    */
    
    func getRotatedArrowheadPts() -> [CGPoint] {
        
        var pointsOut: [CGPoint] = [CGPoint]()
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return pointsOut
        }
        
        // Check whether arrow points up or down
        if startPoint.y - endPoint.y > 0 {
            // arrow is pointing up
            d = -1.0
        }
        
        // The points before rotation, and before being moved by the height of the arrowhead
        let outerRight          = CGPoint(x:  arrowWth,             y: endPoint.y               )
        let innerRight          = CGPoint(x:  endWth,               y: endPoint.y               )
        let innerLeft           = CGPoint(x:  endWth *      -1.0,   y: endPoint.y               )
        let outerLeft           = CGPoint(x:  arrowWth *    -1.0,   y: endPoint.y               )
        
//        let pointsIn: [CGPoint] = [outerRight, innerRight, innerLeft, outerLeft]
        let pointsIn: [CGPoint] = [innerLeft, outerLeft, outerRight, innerRight]
        
        // Get the angle amount to rotate
        let opposite: CGFloat   = startPoint.x - endPoint.x
        let adjacent: CGFloat   = endPoint.y - startPoint.y
        let rotationAngle       = atan(opposite / adjacent)
        
        // rotate points (around the endpoint of the arrow)
        // add/subtract the (rotated) height of the arrow (translating back to original coord system)
        let cosine              = cos(rotationAngle)
        let sine                = sin(rotationAngle)
        for i in 0 ..< pointsIn.count {
            let a               = endPoint.x + pointsIn[i].x * cosine + arrowHt * sine * d
            let b               = endPoint.y + pointsIn[i].x * sine   - arrowHt * cosine * d
            pointsOut.append(CGPoint(x: a, y: b))
        }
        
        return pointsOut
    }
    
    // Uncomment to cut off the top of the shadow if desired
//    override func getExpandedRect() -> CGRect {
//        var expandedRect = bounds.insetBy(dx: -2 * shadowWidth, dy: -2 * shadowWidth)
//        expandedRect.origin.y += 2.15 * shadowWidth * d // d is 1 for down pointing, and -1 for up
//        return expandedRect
//    }
    
}


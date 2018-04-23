//
//  ArrowBlurView.swift
//  AahToZzz
//
//  Created by David Fierstein on 4/18/18.
//  Copyright © 2018 David Fierstein. All rights reserved.

import UIKit

class ArrowBlurView: ShapeView {
    
    //MARK: Arrow const's and vars
    //Wth == WIDTH, Ht == HEIGHT

    let TANGENTLIMIT:   CGFloat   = 5.0  // prevents control pt adjustments when close to vertical
    let CPMULTIPLIER:   CGFloat   = 0.4  // empirical const for amount of control pt adjustment
    
    var startWth:       CGFloat   = 9.0
    var endWth:         CGFloat   = 12.0
    var arrowWth:       CGFloat   = 24.0
    var arrowHt:        CGFloat   = 16.0
    
    var cpValue1:       CGFloat   = 36.0
    var cpValue2:       CGFloat   = 36.0
    var d:              CGFloat   = 1.0  // arrow direction, 1.0 for down, -1.0 for up
    var arrowType:      ArrowType = .curved
    
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
    
    // allow control of blur and shadow and all arrow parameters
    convenience init(arrowType: ArrowType,
                     startPoint: CGPoint, endPoint: CGPoint,
                     startWidth: CGFloat, endWidth: CGFloat,
                     arrowWidth: CGFloat, arrowHeight: CGFloat,
                     blurriness: CGFloat, shadowWidth: CGFloat) {
        
        self.init(frame: CGRect(x: 65, y: 20, width: 10, height: 5))
        
        self.arrowType      = arrowType
        self.startPoint     = startPoint
        self.endPoint       = endPoint
        self.startWth       = startWidth
        self.endWth         = endWidth
        self.arrowWth       = arrowWidth
        self.arrowHt        = arrowHeight
        self.blurriness     = blurriness
        self.shadowWidth    = shadowWidth
        
        addViews()
    }
    
    // helper for inits
    func addViews() {
        addShapeView()
        if blurriness   > 0.01 { addBlurView()   }
        if shadowWidth  > 0.01 { addShadowView() }
    }
    
    // createShape has no parameters, so it can be called in the ShapeView superclass in the
    // addShapeView() func. Therefore, need another func createArrow(...) that *can* contain
    // parameters specific to this subclass
    override func createShape() {
        createArrow(arrowType: arrowType)
    }
    
    func createArrow(arrowType: ArrowType) {
        switch arrowType {
        case .curved:
            createBezierArrow()
        case .pointer:
            createPointer()
        case .straight:
            createStraightArrow()
        }
    }
    
    //MARK:- Pointer
    func createPointer () {

        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        let startPointLeft  = CGPoint(x: startPoint.x   - startWth,   y: startPoint.y)
        let startPointRight = CGPoint(x: startPoint.x   + startWth,   y: startPoint.y)
        let endPointLeft    = CGPoint(x: endPoint.x     - endWth,     y: endPoint.y)
        let endPointRight   = CGPoint(x: endPoint.x     + endWth,     y: endPoint.y)
        path.move   (to: startPointLeft)
        path.addLine(to: startPointRight)
        path.addLine(to: endPointRight)
        path.addLine(to: endPointLeft)
        path.close  ()
    }
    
    //MARK:- Curved (Bezier) Arrow
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
        
        path.move       (to: startPoint)
        path.addLine    (to: startPointRight)
        path.addCurve   (to: innerPointRight, controlPoint1: startControlRight,  controlPoint2: endControlRight)
        path.addLine    (to: outerPointRight)
        path.addLine    (to: endPoint)
        path.addLine    (to: outerPointLeft)
        path.addLine    (to: innerPointLeft)
        path.addCurve   (to: startPointLeft, controlPoint1: endControlLeft, controlPoint2: startControlLeft)
        path.close      ()
    }
    
    
    func adjustControlPoints() {
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        
        // in case where the arrow is too short, reduce control point offsets
        let ht = abs(endPoint.y - startPoint.y)
        if ht < 2 * cpValue1 {
            cpValue1 = ht * 0.45
        }
        // Check whether arrow points up or down
        if startPoint.y - endPoint.y > 0 {
            // arrow is pointing up
            d = -1.0
            cpValue1 *= d
        }
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
    
    //MARK:- Straight (Rotated) Arrow
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
        
        let pointsIn: [CGPoint] = [outerRight, innerRight, innerLeft, outerLeft]
        
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
    
    
    // To cut off the top of the shadow
    override func getExpandedRect() -> CGRect {
        var expandedRect = bounds.insetBy(dx: -2 * shadowWidth, dy: -2 * shadowWidth)
        expandedRect.origin.y += 2.15 * shadowWidth * d // d is 1 for down pointing, and -1 for up
        return expandedRect
    }
    
}


//
//  ShapeView.swift
//  AahToZzz
//
//  Created by David Fierstein on 4/10/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//

//  Based on:
//  ArrowView.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/28/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//

import UIKit

class ShapeView: UIView {
    
    //TODO: As part of init, allow calling the type of shape to create
    
    //MARK: Arrow const's and vars WTH == WIDTH, HT == HEIGHT
    let STARTWTH:       CGFloat = 12.0
    let ENDWTH:         CGFloat = 6.0
    let ARROWWTH:       CGFloat = 16.0
    let ARROWHT:        CGFloat = 22.0
    let TANGENTLIMIT:   CGFloat = 5.0 // prevents control pt adjustments when close to vertical
    let CPMULTIPLIER:   CGFloat = 0.4 // empirical const for amount of control pt adjustment
    var startPoint:     CGPoint?
    var endPoint:       CGPoint?
    var cpValue1:       CGFloat = 36.0
    var cpValue2:       CGFloat = 36.0
    var d:              CGFloat = 1.0 // arrow direction, 1.0 for down, -1.0 for up
    //MARK:- Blur and view vars
    var arrowBounds:    CGRect?
    var blurView:       UIVisualEffectView?
    var blurriness:     CGFloat = 0.5
    var animator:       UIViewPropertyAnimator?
    var path:           UIBezierPath = UIBezierPath()
    var lineProperties: [LineProperties] = [LineProperties]()
    var shapeView:      UIView?
    var shadowView:     UIView?
    
    struct LineProperties {
        var lineWidth:  CGFloat
        var color:      UIColor
    }
    
    //MARK:- init
    override init(frame: CGRect) {
        super.init(frame: frame)
        useFrameForPoints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // init for tile holder (upper positions background)
    convenience init(numTiles: Int, tileWidth: CGFloat, borderWidth: CGFloat) {
        let w: CGFloat = CGFloat((numTiles)) * (tileWidth + borderWidth) + borderWidth
        let h: CGFloat = tileWidth + 2 * borderWidth
        let frame = CGRect(x: 0, y: 0, width: w, height: h)
        self.init(frame: frame)
        addShapeView(numTiles: numTiles, tileWidth: tileWidth, borderWidth: borderWidth)
        //createTileHolder(numTiles: numTiles, tileWidth: tileWidth, borderWidth: borderWidth)
        addLineProperties()
        for i in 0 ..< lineProperties.count {
            addSublayerShapeLayer(lineWidth: lineProperties[i].lineWidth, color: lineProperties[i].color)
        }
        blurArrow()
        addShadowView()
    }
    
    init(frame: CGRect, startPoint: CGPoint, endPoint: CGPoint) {
        
        self.startPoint = startPoint
        self.endPoint = endPoint
        super.init(frame: frame)
        addLineProperties()
        addShapeWithBlur()
    }
    
    // helpers for init
    func addLineProperties() {
        lineProperties.append(LineProperties(lineWidth: 11.0,  color: Colors.veryLight))
        lineProperties.append(LineProperties(lineWidth: 8.5,   color: Colors.veryLight))
        lineProperties.append(LineProperties(lineWidth: 5.5,   color: Colors.lightBackground))
        lineProperties.append(LineProperties(lineWidth: 2.25,  color: .white))
        lineProperties.append(LineProperties(lineWidth: 1.5,   color: Colors.darkBackground))
    }
    
    func useFrameForPoints () {
        startPoint  = CGPoint(x: 0,           y:0            )
        endPoint    = CGPoint(x: frame.width, y: frame.height)
    }
    
    deinit {
        //animator?.stopAnimation(false)
        print("ARROW DEINITS")
    }
    
    //MARK:- Inspectables
    
    @IBInspectable var sPt: CGPoint = CGPoint(x: 0, y: 0) {
        didSet {
            self.startPoint = self.sPt
        }
    }
    
    @IBInspectable var ePt: CGPoint = CGPoint(x: 300, y: 200) {
        didSet {
            self.endPoint = self.ePt
        }
    }
    
    //MARK:- Shape creation
    
//    func createTileHolder(numTiles: Int, tileWidth: CGFloat, borderWidth: CGFloat) {
//        let cornerRadius = borderWidth + 8.0
//        let outerPath = UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius)
//        path.append(outerPath)
//        for i in 0 ..< numTiles {
//            let xPos = CGFloat(i) * (borderWidth + tileWidth) + borderWidth
//            let tileRect = CGRect(x: xPos, y: borderWidth, width: tileWidth, height: tileWidth)
//            let innerPath = UIBezierPath(roundedRect: tileRect, cornerRadius: 8.0)
//            path.append(innerPath)
//        }
//    }
    
    func addShapeView(numTiles: Int, tileWidth: CGFloat, borderWidth: CGFloat) {
        shapeView = UIView(frame: bounds)
        guard let shapeView = shapeView else {
            return
        }
        let cornerRadius = borderWidth + 8.0
        let outerPath = UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius)
        path.append(outerPath)
        for i in 0 ..< numTiles {
            let xPos = CGFloat(i) * (borderWidth + tileWidth) + borderWidth
            let tileRect = CGRect(x: xPos, y: borderWidth, width: tileWidth, height: tileWidth)
            let innerPath = UIBezierPath(roundedRect: tileRect, cornerRadius: 8.0)
            path.append(innerPath)
        }
        
        self.addSubview(shapeView)
//        shapeView.mask = getArrowMask()
        
    }
    
    func addShadowView() {
        
        shadowView = UIView(frame: bounds.offsetBy(dx: 0, dy: 0))
        guard let shadowView = shadowView else {
            return
        }
        shadowView.backgroundColor      = .red
        shadowView.layer.cornerRadius   = 18.0
        shadowView.layer.shadowColor    = UIColor.black.cgColor
        shadowView.layer.shadowOpacity  = 1.0
        shadowView.layer.shadowRadius   = 12.0
        shadowView.layer.masksToBounds  = false
        
        
        let outerShadowMaskRect = CGRect(x: bounds.minX - 25, y: bounds.minY - 25, width: bounds.width + 50, height: bounds.height + 50)
        let outerShadowPath = UIBezierPath(rect: outerShadowMaskRect)
        let innerShadowRect = CGRect(x: 0.0, y: 0.0, width: shadowView.frame.width, height: shadowView.frame.height)
        let innerPath = UIBezierPath(roundedRect: innerShadowRect, cornerRadius: 18.0)
        
        let shadowMask                          = CGMutablePath()
        let shadowMaskLayer                     = CAShapeLayer()
        
        shadowMask.addPath(outerShadowPath.cgPath)
        shadowMask.addPath(innerPath.cgPath)
        
        shadowMaskLayer.path                    = shadowMask
        shadowMaskLayer.fillRule                = kCAFillRuleEvenOdd
        shadowView.layer.mask                   = shadowMaskLayer
        //shadowView.mask = UIView(frame: bounds.offsetBy(dx: 10, dy: 10))
        self.addSubview(shadowView)
    }
    
    
    // adapted from similar code in BlurViewC and its xib - need to consolidate
    func updateShadowMaskLayer () {
        //        let outerShadowMaskRect = CGRect(x: bounds.minX - 25, y: bounds.minY - 25, width: bounds.width + 50, height: bounds.height + 50)
        //        let outerPath = UIBezierPath(rect: outerShadowMaskRect)
        //        let innerShadowRect = CGRect(x: 0.0, y: -1.0, width: shadowView.frame.width, height: shadowView.frame.height)
        //        let innerPath = UIBezierPath(roundedRect: innerShadowRect, cornerRadius: cornerRadius)
        //
        //        let shadowMask                          = CGMutablePath()
        //        let shadowMaskLayer                     = CAShapeLayer()
        //
        //        shadowMask.addPath(outerPath.cgPath)
        //        shadowMask.addPath(innerPath.cgPath)
        //
        //        shadowMaskLayer.path                    = shadowMask
        //        shadowMaskLayer.fillRule                = kCAFillRuleEvenOdd
        //        shadowView.layer.mask                   = shadowMaskLayer
    }
    
    // Curved arrow, arrowhead points straight up or down
    func createBezierArrow () {
        
        if startPoint == nil {
            useFrameForPoints()
        }
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        
        adjustControlPoints()
        
        let startPointLeft    = CGPoint(x: startPoint.x - STARTWTH, y: startPoint.y                             )
        let startPointRight   = CGPoint(x: startPoint.x + STARTWTH, y: startPoint.y                             )
        let innerPointRight   = CGPoint(x: endPoint.x   + ENDWTH,   y: endPoint.y   - ARROWHT * d               )
        let innerPointLeft    = CGPoint(x: endPoint.x   - ENDWTH,   y: endPoint.y   - ARROWHT * d               )
        let outerPointRight   = CGPoint(x: endPoint.x   + ARROWWTH, y: endPoint.y   - ARROWHT * d               )
        let outerPointLeft    = CGPoint(x: endPoint.x   - ARROWWTH, y: endPoint.y   - ARROWHT * d               )
        let endControlRight   = CGPoint(x: endPoint.x   + ENDWTH,   y: endPoint.y   - ARROWHT * d   - cpValue1  )
        let endControlLeft    = CGPoint(x: endPoint.x   - ENDWTH,   y: endPoint.y   - ARROWHT * d   - cpValue2  )
        let startControlLeft  = CGPoint(x: startPoint.x - STARTWTH, y: startPoint.y                 + cpValue1  )
        let startControlRight = CGPoint(x: startPoint.x + STARTWTH, y: startPoint.y                 + cpValue2  )
        
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
        let arrowHeight = abs(endPoint.y - startPoint.y)
        if arrowHeight < 2 * cpValue1 {
            cpValue1 = arrowHeight * 0.45
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
        let outerRight          = CGPoint(x:  ARROWWTH,             y: endPoint.y               )
        let innerRight          = CGPoint(x:  ENDWTH,               y: endPoint.y               )
        let innerLeft           = CGPoint(x:  ENDWTH *      -1.0,   y: endPoint.y               )
        let outerLeft           = CGPoint(x:  ARROWWTH *    -1.0,   y: endPoint.y               )
        
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
            let a               = endPoint.x + pointsIn[i].x * cosine + ARROWHT * sine * d
            let b               = endPoint.y + pointsIn[i].x * sine   - ARROWHT * cosine * d
            pointsOut.append(CGPoint(x: a, y: b))
        }
        
        return pointsOut
    }
    
    //let hypotenuse: CGFloat = sqrt(pow(opposite, 2) + pow(adjacent, 2))
    //let rotationAmount  = (asin(opposite / hypotenuse) * 180.0) / .pi
    
    // Curved arrow, arrowhead points straight up or down
    func createRotatedArrow () {
        
        if startPoint == nil {
            useFrameForPoints()
        }
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        
        let startPointLeft    = CGPoint(x: startPoint.x - STARTWTH, y: startPoint.y                             )
        let startPointRight   = CGPoint(x: startPoint.x + STARTWTH, y: startPoint.y                             )
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
    
    func getQuadControl (startPt: CGPoint, endPt: CGPoint) -> CGPoint {
        let pointingRight: Bool = startPt.x < endPt.x ? true : false
        //let tanx = (endPt.x - startPt.x) / (startPt.y - endPt.y)
        let midX = (startPt.x - endPt.x) * 0.5
        let midY = (endPt.y - startPt.y) * 0.5
        let cpX = startPt.x - midX
        let cpY = endPt.y - midY
        //let cp = CGPoint(x: cpX, y: cpY)
        var cp2X = startPt.x
        var cp2Y = endPt.y
        if pointingRight { cp2X = endPt.x + 30.0; cp2Y = startPt.y }
        
        let cp2 = CGPoint(x: cp2X, y: cp2Y)
        return cp2
    }
    
    func createQuadCurveArrow () {
        path = UIBezierPath()
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        let startPointLeft      = CGPoint(x: startPoint.x - STARTWTH,    y: startPoint.y                          )
        let startPointRight     = CGPoint(x: startPoint.x + STARTWTH,    y: startPoint.y                          )
        let insidePointRight    = CGPoint(x: endPoint.x   + ENDWTH,      y: endPoint.y    - ARROWHT           )
        let insidePointLeft     = CGPoint(x: endPoint.x   - ENDWTH,      y: endPoint.y    - ARROWHT           )
        let outsidePointRight   = CGPoint(x: endPoint.x   + ARROWWTH,    y: endPoint.y    - ARROWHT           )
        let outsidePointLeft    = CGPoint(x: endPoint.x   - ARROWWTH,    y: endPoint.y    - ARROWHT           )
        //let startControlRight   = CGPoint(x: startPoint.x + STARTWTH,    y: startPoint.y                + 40.0    )
        //let insideControlRight  = CGPoint(x: endPoint.x   + ENDWTH,      y: endPoint.y    - ARROWHT - 40.0    )
        let startControlLeft    = CGPoint(x: startPoint.x - STARTWTH,    y: startPoint.y                + 40.0    )
        let insideControlLeft   = CGPoint(x: endPoint.x   - ENDWTH,      y: endPoint.y    - ARROWHT - 40.0    )
        let quadControl = getQuadControl(startPt: startPointRight, endPt: insidePointRight)
        
        path.move           (to: startPoint)
        path.addLine        (to: startPointRight)
        path.addQuadCurve   (to: insidePointRight, controlPoint: quadControl)
        path.addLine        (to: outsidePointRight)
        path.addLine        (to: endPoint)
        path.addLine        (to: outsidePointLeft)
        path.addLine        (to: insidePointLeft)
        path.addQuadCurve   (to: startPointLeft, controlPoint: quadControl)
        //path.addCurve       (to: startPointLeft, controlPoint1: insideControlLeft, controlPoint2: startControlLeft)
        path.close          ()
    }
    
    func createArrow () {
        path = UIBezierPath()
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        let startPointLeft      = CGPoint(x: startPoint.x - STARTWTH,    y: startPoint.y                          )
        let startPointRight     = CGPoint(x: startPoint.x + STARTWTH,    y: startPoint.y                          )
        let insidePointRight    = CGPoint(x: endPoint.x   + ENDWTH,      y: endPoint.y    - ARROWHT           )
        let insidePointLeft     = CGPoint(x: endPoint.x   - ENDWTH,      y: endPoint.y    - ARROWHT           )
        let outsidePointRight   = CGPoint(x: endPoint.x   + ARROWWTH,    y: endPoint.y    - ARROWHT           )
        let outsidePointLeft    = CGPoint(x: endPoint.x   - ARROWWTH,    y: endPoint.y    - ARROWHT           )
        let startControlRight   = CGPoint(x: startPoint.x + STARTWTH,    y: startPoint.y                + 40.0    )
        let insideControlRight  = CGPoint(x: endPoint.x   + ENDWTH,      y: endPoint.y    - ARROWHT - 40.0    )
        let startControlLeft    = CGPoint(x: startPoint.x - STARTWTH,    y: startPoint.y                + 40.0    )
        let insideControlLeft   = CGPoint(x: endPoint.x   - ENDWTH,      y: endPoint.y    - ARROWHT - 40.0    )
        
        path.move       (to: startPoint)
        path.addLine    (to: startPointRight)
        path.addCurve   (to: insidePointRight, controlPoint1: startControlRight,  controlPoint2: insideControlRight)
        path.addLine    (to: outsidePointRight)
        path.addLine    (to: endPoint)
        path.addLine    (to: outsidePointLeft)
        path.addLine    (to: insidePointLeft)
        path.addCurve   (to: startPointLeft, controlPoint1: insideControlLeft, controlPoint2: startControlLeft)
        path.close      ()
    }
    
    func createPointer () {
        path = UIBezierPath()
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        let startPointLeft  = CGPoint(x: startPoint.x   - STARTWTH,   y: startPoint.y)
        let startPointRight = CGPoint(x: startPoint.x   + STARTWTH,   y: startPoint.y)
        let endPointLeft    = CGPoint(x: endPoint.x     - ENDWTH,     y: endPoint.y)
        let endPointRight   = CGPoint(x: endPoint.x     + ENDWTH,     y: endPoint.y)
        path.move   (to: startPointLeft)
        path.addLine(to: startPointRight)
        path.addLine(to: endPointRight)
        path.addLine(to: endPointLeft)
        path.close  ()
    }
    
    func createRectangle() {
        
        //path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0.0))
        path.close()
    }
    
    // called in init
    func addShapeWithBlur() {
        
        
        //createBezierArrow()
        createRotatedArrow()
        
        
        for i in 0 ..< lineProperties.count {
            addSublayerShapeLayer(lineWidth: lineProperties[i].lineWidth, color: lineProperties[i].color)
        }
        
        blurArrow()
    }
    
    func addSublayerShapeLayer (lineWidth: CGFloat, color: UIColor) {
        let shapeLayer          = CAShapeLayer()
        shapeLayer.path         = self.path.cgPath
        shapeLayer.lineWidth    = lineWidth
        shapeLayer.strokeColor  = color.cgColor
        shapeLayer.fillColor    = UIColor.clear.cgColor
        shapeLayer.lineJoin     = kCALineJoinRound
        
        self.layer.addSublayer(shapeLayer)
    }
    
    // blur fx
    func blurArrow() {
        var blurEffect: UIBlurEffect
        if #available(iOS 10.0, *) {
            blurEffect = UIBlurEffect(style: .prominent)
        } else {
            blurEffect = UIBlurEffect(style: .light)
        }
        
        blurView = UIVisualEffectView(effect: nil)
        
        guard let blurView = blurView else {
            return
        }
        
        animator = UIViewPropertyAnimator(duration: 3, curve: .linear) {
            self.blurView?.effect = blurEffect
            self.animator?.pauseAnimation()
        }
        animator?.startAnimation()
        animator?.fractionComplete = blurriness
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        arrowBounds = self.path.cgPath.boundingBoxOfPath
        guard let arrowBounds = arrowBounds else {
            return
        }
        blurView.frame              = arrowBounds
        
        /*
         let maskLayer               = CAShapeLayer()
         
         let arrowBoundsExpanded     = CGRect(x:      arrowBounds.minX    - 20.0,
         y:      arrowBounds.minY    - 20.0,
         width:  arrowBounds.width   + 40.0,
         height: arrowBounds.height  + 40.0)
         
         let maskPath                = UIBezierPath(rect: arrowBoundsExpanded)
         maskPath.append(self.path)
         
         //        let mPath = CGMutablePath()
         //        mPath.addPath(UIBezierPath(rect: arrowBoundsExpanded).cgPath)
         //        mPath.addPath(self.path.cgPath)
         
         
         maskLayer.path              = maskPath.cgPath
         maskLayer.fillRule          = kCAFillRuleEvenOdd
         maskLayer.fillColor         = Colors.bluek.cgColor
         
         
         let mView                = UIView(frame: CGRect(x:0,y:0,width: arrowBounds.width, height: arrowBounds.height))
         
         mView.layer.addSublayer(maskLayer)
         
         mView.layer.mask = maskLayer
         
         //blurView.mask = maskView
         
         //        blurView.mask = mView
         //        blurView.contentView.layer.mask = maskLayer
         
         */
        let blurSuperView = UIView(frame: bounds)
        blurSuperView.translatesAutoresizingMaskIntoConstraints = false
//        blurSuperView.view.maskToBounds = false
        blurSuperView.mask = getShapeMask() // set mask on containing view
        self.insertSubview(blurSuperView, at: 0)
        blurSuperView.insertSubview(blurView, at: 0)
        //self.insertSubview(maskView, at: 1)
        //blurView.layer.mask = maskLayer
        
        
    }
    
    func getShadowMask() -> UIView {
        // will return a UIView
        var sView = getShapeMask()
        // invert the mask for use as a shadow mask
        return sView
    }
    
    // Needs to be called from the containing view, otherwise the blur will not work
    func getShapeMask() -> UIView {
        
//        guard let arrowBounds = arrowBounds else {
//            print("COULD NOT let arrowBounds")
//            return self // causes crash if self is return (circular reference) -- FIX
//        }
        
        
        let maskLayer               = CAShapeLayer()
        
        //        let arrowBoundsExpanded     = CGRect(x:      (arrowBounds?.minX)!    - 20.0,
        //                                             y:      (arrowBounds?.minY)!    - 20.0,
        //                                             width:  (arrowBounds?.width)!   + 40.0,
        //                                             height: (arrowBounds?.height)!  + 40.0)
        //
        //        let maskPath                = UIBezierPath(rect: arrowBoundsExpanded)
        //        maskPath.append(self.path)
        
        //        let mPath = CGMutablePath()
        //        mPath.addPath(UIBezierPath(rect: arrowBoundsExpanded).cgPath)
        //        mPath.addPath(self.path.cgPath)
        
        
        maskLayer.path              = self.path.cgPath  //  maskPath.cgPath
        maskLayer.fillRule          = kCAFillRuleEvenOdd
        //maskLayer.fillColor       = Colors.bluek.cgColor
        let mView = UIView(frame: CGRect(x:0,y:0,width: bounds.width, height: bounds.height))
//        let mView = UIView(frame: CGRect(x:0,y:0,width: arrowBounds.width, height: arrowBounds.height))
        
        mView.layer.addSublayer(maskLayer)
        
        //mView.layer.mask = maskLayer
        
        return mView
        
    }
}


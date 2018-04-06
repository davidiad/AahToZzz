//
//  ArrowView.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/28/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//

import UIKit

class ArrowView: UIView {
    
    //MARK: Arrow const's and vars WTH == WIDTH, HT == HEIGHT
    let STARTWTH:       CGFloat = 12.0
    let ENDWTH:         CGFloat = 6.0
    let ARROWWTH:       CGFloat = 16.0
    let ARROWHT:        CGFloat = 22.0
    var startPoint:     CGPoint?
    var endPoint:       CGPoint?
    var cpStrong:       CGFloat = 36.0
    var cpWeak:         CGFloat = 36.0
    
    //MARK:- Blur and view vars
    var arrowBounds:    CGRect?
    var blurView:       UIVisualEffectView?
    var blurriness:     CGFloat = 0.5
    var animator:       UIViewPropertyAnimator?
    var path:           UIBezierPath = UIBezierPath()
    var lines:          [Line] = [Line]()
    
    struct Line {
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
    
    init(frame: CGRect, startPoint: CGPoint, endPoint: CGPoint) {
        
        self.startPoint = startPoint
        self.endPoint = endPoint
        super.init(frame: frame)
        addLineProperties()
        addShapeWithBlur()
    }
    
    // helpers for init
    func addLineProperties() {
        lines.append(Line(lineWidth: 11.0,  color: Colors.veryLight))
        lines.append(Line(lineWidth: 8.5,   color: Colors.veryLight))
        lines.append(Line(lineWidth: 5.5,   color: Colors.lightBackground))
        lines.append(Line(lineWidth: 2.25,  color: .white))
        lines.append(Line(lineWidth: 1.5,   color: Colors.darkBackground))
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
    

    
//    convenience init(frame: CGRect, sPoint: CGPoint, ePoint: CGPoint) {
//
//        startPoint = sPoint
//        endPoint = ePoint
//        self.init(frame: frame)
//    }
    
//    func getQuadControl (startPt: CGPoint, endPt: CGPoint) -> CGPoint {
//        let tanx = (endPt.x - startPt.x) / (startPt.y - endPt.y)
//        let x    = endPt.x - (endPt.x - startPt.x) * 0.5
//        let y    = endPt.y + (startPt.y - endPt.y) * 0.5 + (x * tanx)
//        return CGPoint(x: endPt.x, y: y)
//    }
    
    //MARK:- Shape creation
    
    // arrowhead points up or down, arrow curves
    func createBezierArrow () {
        //path = UIBezierPath()
        if startPoint == nil {
            useFrameForPoints()
        }
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        
        var down: Bool = false
        // Check whether arrow points up or down
        var d: CGFloat = 1.0
        if endPoint.y - startPoint.y > 0 {
            // arrow points down
            down = true
            d = -1.0

        }
        
        // Check whether arrow points left or right
        var r: CGFloat = 1.0
        if startPoint.x - endPoint.x > 0 {
            // arrow points left
                r = -1.0
        }
        
        var u: CGFloat = 1.0
        var ul: CGFloat = 1.0
        if down == false {
            u = -1.0
            if startPoint.x - endPoint.x > 0 {
                // pointing up and to the left
                // all control points need to go the opposite way
                ul = -1.0
            }
            
        }
        
        
        
        adjustControlPoints()
        
        let startPointLeft    = CGPoint(x: startPoint.x - STARTWTH, y: startPoint.y                                         )
        let startPointRight   = CGPoint(x: startPoint.x + STARTWTH, y: startPoint.y                                         )
        let innerPointRight   = CGPoint(x: endPoint.x   + ENDWTH,   y: endPoint.y   + ARROWHT * d                           )
        let innerPointLeft    = CGPoint(x: endPoint.x   - ENDWTH,   y: endPoint.y   + ARROWHT * d                           )
        let outerPointRight   = CGPoint(x: endPoint.x   + ARROWWTH, y: endPoint.y   + ARROWHT * d                           )
        let outerPointLeft    = CGPoint(x: endPoint.x   - ARROWWTH, y: endPoint.y   + ARROWHT * d                           )
        let startControlRight = CGPoint(x: startPoint.x + STARTWTH, y: startPoint.y               + cpWeak * r * ul         )
        let innerControlRight = CGPoint(x: endPoint.x   + ENDWTH,   y: endPoint.y   + ARROWHT * d - cpStrong * d * r * ul   )
        let startControlLeft  = CGPoint(x: startPoint.x - STARTWTH, y: startPoint.y               + cpStrong * -r * u * ul  )
        let innerControlLeft  = CGPoint(x: endPoint.x   - ENDWTH,  y: endPoint.y    + ARROWHT * d - cpWeak * d * -r * u * ul)
        
        path.move       (to: startPoint)
        path.addLine    (to: startPointRight)
        path.addCurve   (to: innerPointRight, controlPoint1: startControlRight,  controlPoint2: innerControlRight)
        path.addLine    (to: outerPointRight)
        path.addLine    (to: endPoint)
        path.addLine    (to: outerPointLeft)
        path.addLine    (to: innerPointLeft)
        path.addCurve   (to: startPointLeft, controlPoint1: innerControlLeft, controlPoint2: startControlLeft)
        path.close      ()
    }
    
    // Adjust based on direction arrow is pointing, and length of arrow
    func adjustControlPoints() {
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        
        // in case where the arrow is too short, reduce control point offsets
        let arrowHeight = endPoint.y - startPoint.y
        if arrowHeight < 2 * cpWeak {
            cpWeak = arrowHeight * 0.45
            cpStrong = cpWeak
        }
        
        // Check whether arrow points up or down
        var d: CGFloat = -1.0 // arrow is pointing up
        if startPoint.y - endPoint.y > 0 {
            // arrow is pointing up
            d = 1.0
        }
        
        // adjust the strong control point, depending on the angle of the arrow
        // to make graceful curves, with inner and outer curves matching
        // 4 cases, arrow point up or down, right or left
        let rightShift = endPoint.x - startPoint.x
        // arrow points right
        if rightShift > 9.0 { // prevent divide by 0 (or close to 0)
            let tangent = abs((endPoint.y - startPoint.y) / rightShift)
            if tangent < 5 { // no adjustment if angle is close to 90°
                let cpFactor = 4 / (10 * tangent)
                cpStrong *= ((1.0 + cpFactor) * d)
            }
            
        // arrow points toward left
        } else if rightShift < -1.0 {
            let tangent = abs((endPoint.y - startPoint.y) / (startPoint.x - endPoint.x))
            if tangent < 5 { // no adjustment if angle is close to 90°
                let cpFactor = 4 / (10 * tangent)
                // switch roles of cpWeak and cpStrong (naming should be improved)
                cpWeak *= (1.0 + cpFactor) * d
                
            }
        }
        
        // if arrow is pointing up, swap the strong and weak sides
        if d > 0 && rightShift > 0 {
            let tempStrong  = cpStrong
            cpStrong        = cpWeak
            cpWeak          = tempStrong
        }
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
        // Initialize the path.
        path = UIBezierPath()
        
        // Specify the point that the path should start get drawn.
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        
        // Create a line between the starting point and the bottom-left side of the view.
        path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height))
        
        // Create the bottom line (bottom-left to bottom-right).
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        
        // Create the vertical line from the bottom-right to the top-right side.
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0.0))
        
        // Close the path. This will create the last line automatically.
        path.close()
    }

    // called in init
    func addShapeWithBlur() {

        createBezierArrow()
        
        for i in 0 ..< lines.count {
            addSublayerShapeLayer(lineWidth: lines[i].lineWidth, color: lines[i].color)
        }
//        addSublayerShapeLayer(lineWidth: 11.0,  color: Colors.veryLight)
//        // note: added 2nd time to increase opacity and to feather edge
//        addSublayerShapeLayer(lineWidth: 8.5,   color: Colors.veryLight)
//        addSublayerShapeLayer(lineWidth: 5.5,   color: Colors.lightBackground)
//        addSublayerShapeLayer(lineWidth: 2.25,  color: .white)
//        addSublayerShapeLayer(lineWidth: 1.5,   color: Colors.darkBackground)
        
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
    func blurArrow()  {
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
        self.insertSubview(blurView, at: 0)
        //self.insertSubview(maskView, at: 1)
        //blurView.layer.mask = maskLayer
        
        
    }
    
    func getArrowMask() -> UIView {
        guard let arrowBounds = arrowBounds else {
            return self
        }
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
        
        let mView = UIView(frame: CGRect(x:0,y:0,width: arrowBounds.width, height: arrowBounds.height))
        
        mView.layer.addSublayer(maskLayer)
        
        //mView.layer.mask = maskLayer
        
        return mView
        
    }
}

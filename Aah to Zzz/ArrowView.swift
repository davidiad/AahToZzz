//
//  ArrowView.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/28/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//

import UIKit

class ArrowView: UIView {
    
    let STARTWIDTH:     CGFloat = 12.0
    let ENDWIDTH:       CGFloat = 6.0
    let ARROWWIDTH:     CGFloat = 16.0
    let ARROWHEIGHT:    CGFloat = 22.0
    var startPoint:     CGPoint?
    var endPoint:       CGPoint?
    var cpStrong:       CGFloat = 36.0
    var cpWeak:         CGFloat = 36.0
    var arrowBounds:    CGRect?
    var blurView:       UIVisualEffectView?
    var blurriness:     CGFloat = 0.5
    var animator:       UIViewPropertyAnimator?
    
    struct Line {
        var lineWidth : CGFloat
        var color :     UIColor
    }
    
    var lines:          [Line] = [Line]()

    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

//    override func draw(_ rect: CGRect) {
//        self.createRectangle()
//
//        // Specify the fill color and apply it to the path.
//        UIColor.orange.setFill()
//        path.fill()
//
//        // Specify a border (stroke) color.
//        UIColor.purple.setStroke()
//        path.stroke()
//    }
    
    var path: UIBezierPath!
    
    
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
    
    // helper for init
    func addLineProperties() {
        lines.append(Line(lineWidth: 11.0,  color: Colors.veryLight))
        lines.append(Line(lineWidth: 8.5,   color: Colors.veryLight))
        lines.append(Line(lineWidth: 5.5,   color: Colors.lightBackground))
        lines.append(Line(lineWidth: 2.25,  color: .white))
        lines.append(Line(lineWidth: 1.5,   color: Colors.darkBackground))
    }
    
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
    
    func useFrameForPoints () {
        startPoint = CGPoint(x:0, y:0)
        endPoint = CGPoint(x: frame.width, y: frame.height)
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
    
    func createBezierArrow () {
        path = UIBezierPath()
        if startPoint == nil {
            useFrameForPoints()
        }
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        adjustControlHt()
        
        let startPointLeft      = CGPoint(x: startPoint.x - STARTWIDTH, y: startPoint.y                             )
        let startPointRight     = CGPoint(x: startPoint.x + STARTWIDTH, y: startPoint.y                             )
        let insidePointRight    = CGPoint(x: endPoint.x   + ENDWIDTH,   y: endPoint.y    - ARROWHEIGHT              )
        let insidePointLeft     = CGPoint(x: endPoint.x   - ENDWIDTH,   y: endPoint.y    - ARROWHEIGHT              )
        let outsidePointRight   = CGPoint(x: endPoint.x   + ARROWWIDTH, y: endPoint.y    - ARROWHEIGHT              )
        let outsidePointLeft    = CGPoint(x: endPoint.x   - ARROWWIDTH, y: endPoint.y    - ARROWHEIGHT              )
        let startControlRight   = CGPoint(x: startPoint.x + STARTWIDTH, y: startPoint.y                + cpWeak     )
        let insideControlRight  = CGPoint(x: endPoint.x   + ENDWIDTH,   y: endPoint.y    - ARROWHEIGHT - cpStrong   )
        let startControlLeft    = CGPoint(x: startPoint.x - STARTWIDTH, y: startPoint.y                + cpStrong   )
        let insideControlLeft   = CGPoint(x: endPoint.x   - ENDWIDTH,   y: endPoint.y    - ARROWHEIGHT - cpWeak     )
        
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
    
    // in case arrow is too short
    func adjustControlHt() {
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        
        // if the arrow is too short, reduce control point offsets
        let arrowHeight = endPoint.y - startPoint.y
        if arrowHeight < 2 * cpWeak {
            cpWeak = arrowHeight * 0.45
            cpStrong = cpWeak
        }
        
        // adjust the strong control point, depending on the angle of the arrow
        let rightShift = endPoint.x - startPoint.x
        if rightShift > 9.0 { // prevent divide by 0
            let tangent = (endPoint.y - startPoint.y) / rightShift
            if tangent < 5 { // no adjustment if angle is close to 90°
                let cpFactor = 4 / (10 * tangent)
                cpStrong *= 1.0 + cpFactor
            }
        } else if rightShift < -1.0 { // arrow points toward left
            let tangent = (endPoint.y - startPoint.y) / (startPoint.x - endPoint.x)
            if tangent < 5 { // no adjustment if angle is close to 90°
                let cpFactor = 4 / (10 * tangent)
                // switch roles of cpWeak and cpStrong (naming should be improved)
                cpWeak *= 1.0 + cpFactor
            }
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
        let startPointLeft      = CGPoint(x: startPoint.x - STARTWIDTH,    y: startPoint.y                          )
        let startPointRight     = CGPoint(x: startPoint.x + STARTWIDTH,    y: startPoint.y                          )
        let insidePointRight    = CGPoint(x: endPoint.x   + ENDWIDTH,      y: endPoint.y    - ARROWHEIGHT           )
        let insidePointLeft     = CGPoint(x: endPoint.x   - ENDWIDTH,      y: endPoint.y    - ARROWHEIGHT           )
        let outsidePointRight   = CGPoint(x: endPoint.x   + ARROWWIDTH,    y: endPoint.y    - ARROWHEIGHT           )
        let outsidePointLeft    = CGPoint(x: endPoint.x   - ARROWWIDTH,    y: endPoint.y    - ARROWHEIGHT           )
        //let startControlRight   = CGPoint(x: startPoint.x + STARTWIDTH,    y: startPoint.y                + 40.0    )
        //let insideControlRight  = CGPoint(x: endPoint.x   + ENDWIDTH,      y: endPoint.y    - ARROWHEIGHT - 40.0    )
        let startControlLeft    = CGPoint(x: startPoint.x - STARTWIDTH,    y: startPoint.y                + 40.0    )
        let insideControlLeft   = CGPoint(x: endPoint.x   - ENDWIDTH,      y: endPoint.y    - ARROWHEIGHT - 40.0    )
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
        let startPointLeft      = CGPoint(x: startPoint.x - STARTWIDTH,    y: startPoint.y                          )
        let startPointRight     = CGPoint(x: startPoint.x + STARTWIDTH,    y: startPoint.y                          )
        let insidePointRight    = CGPoint(x: endPoint.x   + ENDWIDTH,      y: endPoint.y    - ARROWHEIGHT           )
        let insidePointLeft     = CGPoint(x: endPoint.x   - ENDWIDTH,      y: endPoint.y    - ARROWHEIGHT           )
        let outsidePointRight   = CGPoint(x: endPoint.x   + ARROWWIDTH,    y: endPoint.y    - ARROWHEIGHT           )
        let outsidePointLeft    = CGPoint(x: endPoint.x   - ARROWWIDTH,    y: endPoint.y    - ARROWHEIGHT           )
        let startControlRight   = CGPoint(x: startPoint.x + STARTWIDTH,    y: startPoint.y                + 40.0    )
        let insideControlRight  = CGPoint(x: endPoint.x   + ENDWIDTH,      y: endPoint.y    - ARROWHEIGHT - 40.0    )
        let startControlLeft    = CGPoint(x: startPoint.x - STARTWIDTH,    y: startPoint.y                + 40.0    )
        let insideControlLeft   = CGPoint(x: endPoint.x   - ENDWIDTH,      y: endPoint.y    - ARROWHEIGHT - 40.0    )
        
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
        let startPointLeft  = CGPoint(x: startPoint.x   - STARTWIDTH,   y: startPoint.y)
        let startPointRight = CGPoint(x: startPoint.x   + STARTWIDTH,   y: startPoint.y)
        let endPointLeft    = CGPoint(x: endPoint.x     - ENDWIDTH,     y: endPoint.y)
        let endPointRight   = CGPoint(x: endPoint.x     + ENDWIDTH,     y: endPoint.y)
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
        
        arrowBounds = self.path?.cgPath.boundingBoxOfPath
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
    
    deinit {
        //animator?.stopAnimation(false)
        print("ARROW DEINITS")
    }
}

//
//  ArrowView.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/28/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//

import UIKit

@IBDesignable class ArrowView: UIView {

    let STARTWIDTH:     CGFloat = 16.0
    let ENDWIDTH:       CGFloat = 7.0
    let ARROWWIDTH:     CGFloat = 22.0
    let ARROWHEIGHT:    CGFloat = 16.0
    var startPoint:     CGPoint?
    var endPoint:       CGPoint?
    var cpStrong:       CGFloat = 40.0
    var cpWeak:         CGFloat = 40.0
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
        simpleShapeLayer()
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
        let arrowHeight = endPoint.y - startPoint.y
        if arrowHeight < 2 * cpWeak {
            cpWeak = arrowHeight * 0.45
            cpStrong = cpWeak
        }
        
        // adjust the strong control point, depending on the angle of the arrow
        let rightShift = endPoint.x - startPoint.x
        if rightShift > 2.0 { // prevent divide by 0
            let tangent = (endPoint.y - startPoint.y) / rightShift
            if tangent < 5 { // no adjustment if angle is close to 90°
                // range 0 to 1.3~
                let cpFactor = 4 / (10 * tangent)
                cpStrong *= 1.0 + cpFactor
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

    func simpleShapeLayer() {
        print ("SSSSSS")
        createBezierArrow()
        
        let shapeLayerLower = CAShapeLayer()
        shapeLayerLower.path = self.path.cgPath
        shapeLayerLower.fillColor = UIColor.clear.cgColor
        shapeLayerLower.strokeColor = UIColor.white.cgColor
        shapeLayerLower.lineWidth = 1.5
        self.layer.addSublayer(shapeLayerLower)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = self.path.cgPath
        shapeLayer.fillColor = Colors.lightBackground.cgColor
        shapeLayer.strokeColor = Colors.darkBackground.cgColor
        shapeLayer.lineWidth = 0.75
        self.layer.addSublayer(shapeLayer)
    }

}

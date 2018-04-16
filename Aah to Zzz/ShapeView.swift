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
    let TILEWTH:        CGFloat = 50.0 // (to do: get from Tile)
    let TILERADIUS:     CGFloat = 8.0  // (to do: get from Tile)
    var borderWth:      CGFloat = 10.0 // (to do: get from AtoZ VC)
    let STARTWTH:       CGFloat = 12.0
    let ENDWTH:         CGFloat = 6.0
    let ARROWWTH:       CGFloat = 16.0
    let ARROWHT:        CGFloat = 22.0
    let TANGENTLIMIT:   CGFloat = 5.0  // prevents control pt adjustments when close to vertical
    let CPMULTIPLIER:   CGFloat = 0.4  // empirical const for amount of control pt adjustment
    var shadowWidth:    CGFloat = 3.5 // only used if there is a shadow. Make optional?
    var shadowed:       Bool    = false
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
    var shadowPath:     UIBezierPath = UIBezierPath() // TODO: should be an optional, as there may not be a shadow
    var lineProperties: [LineProperties] = [LineProperties]()
    var shapeView:      UIView?
    var shadowView:     UIView?
    var shadowImage:    UIImage? // rendered image of inner shadow of tile holder
    var shapeType:      ShapeType = .arrow
    
//    struct LineProperties {
//        var lineWidth:  CGFloat
//        var color:      UIColor
//    }
    
    //MARK:- init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
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
        shapeType = .tileholder
        shadowed = true
        addShapeView(numTiles: numTiles, tileWidth: tileWidth, borderWidth: borderWidth)
        addLineProperties() // populate the line props array
        for i in 0 ..< lineProperties.count {
            addSublayerShapeLayer(lineWidth: lineProperties[i].lineWidth, color: lineProperties[i].color)
        }
        addBlurView()
        addShadowView()
        guard let shadowView = shadowView else {
            return
        }
        bringSubview(toFront: shadowView)
        print("END of tile holder convenience init")
    }
    
    // init for triangle shape to be added to Down Arrow
    convenience init(frame: CGRect, direction: Directions) {
        self.init(frame: frame)
        shapeType = .triangle
        shadowed = true
        addLineProperties()
        addTriangleView(direction: direction)
        for i in 0 ..< lineProperties.count {
            addSublayerShapeLayer(lineWidth: lineProperties[i].lineWidth, color: lineProperties[i].color)
        }
        addBlurView()
        if shadowed == true {shadowPath.append(path)}
        let shadowRect  = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: bounds.height)
        shadowView = UIView(frame: shadowRect)
        
        guard let shadowView = shadowView else {
            return
        }
        shadowView.backgroundColor      = .clear
        shadowView.layer.shadowColor    = UIColor.black.cgColor
        shadowView.layer.shadowOpacity  = 1.0
        shadowView.layer.shadowRadius   = shadowWidth
        shadowView.layer.masksToBounds  = false
        shadowView.layer.shadowOffset   = CGSize(width: 0, height: 0)
        //shadowView.layer.mask             = getShadowMask()
        //shadowPath = path
        let shadowBounds             = UIBezierPath(rect: bounds.insetBy(dx: -2 * shadowWidth, dy: -2 * shadowWidth))
        
        shadowBounds.append(shadowPath)
        let shadowMaskLayer         = CAShapeLayer()
        shadowMaskLayer.path        = shadowBounds.cgPath
        shadowMaskLayer.fillRule    = kCAFillRuleEvenOdd
        shadowView.layer.shadowPath     = shadowPath.cgPath
        shadowView.layer.mask             = shadowMaskLayer
        addSubview(shadowView)
        //addShadowView()
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
        lineProperties = LinePropertyStyles.frosted
    }
    
    func useFrameForPoints () {
        startPoint  = CGPoint(x: 0,           y:0            )
        endPoint    = CGPoint(x: frame.width, y: frame.height)
    }
    
    deinit {
        //animator?.stopAnimation(false)
        print("ARROW DEINITS")
    }
    
    override func draw(_ rect: CGRect) {
        // create inner shadows if needed
        print("::::::*******^^^^^%%$$$$+++_@)$@::::::::::")
        print("::::::*******^^^^^%%$$$$+++_@)$@::::::::::")
        print("DRAW RECT")
        print("::::::*******^^^^^%%$$$$+++_@)$@::::::::::")
        print("::::::*******^^^^^%%$$$$+++_@)$@::::::::::")
        if shapeType == .tileholder && shadowed == true {
            self.backgroundColor = UIColor.clear
            self.backgroundColor?.setFill()
            UIGraphicsGetCurrentContext()!.fill(rect);
            addInnerShadow()
        }
    }
    
    func drawInContext(){
//
//        let size = CGSize(width: 90, height: 50)
//
//        let context = UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
//        // Establish the image context
////        UIGraphicsBeginImageContextWithOptions(
////            CGSize(77,212), isOpaque, 0.0);
//
//        // Retrieve the current context
//        //let context = UIGraphicsGetCurrentContext()
//        UIGraphicsPushContext(context!)
//        // Perform the drawing
//        context?.setLineWidth(4)
//        context?.setStrokeColor(UIColor.gray.cgColor)
//        context?.strokeEllipse(in: bounds)
//
//
//        // Retrieve the drawn image
//        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
//
//        // End the image context
//        UIGraphicsEndImageContext();
//        UIGraphicsPopContext()
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
    
    // for adding the shape to the Down Button
    func addTriangleView(direction: Directions) {
        // separate really, could be moved
        // should this be wrapped in createShape? and overridden per type
        createTriangle(direction: direction) // creates triangle, and stores into 'path' var
        
        shapeView = UIView(frame: bounds)
        guard let shapeView = shapeView else {
            return
        }
        shapeView.mask = getShapeMask()
        addSubview(shapeView)
        
    }
    
    // should work with any shape, and not need to be overridden (but can be if needed)
    func addShapeView() {
        // needs to be overridden?
        
        shapeView = UIView(frame: bounds)
        guard let shapeView = shapeView else {
            return
        }
        
        createShape()
        addLineProperties() // populate line prop's array
        for i in 0 ..< lineProperties.count {
            addSublayerShapeLayer(lineWidth: lineProperties[i].lineWidth, color: lineProperties[i].color)
        }

        shapeView.mask = getShapeMask()
        addSubview(shapeView)
    }
    
    // basically, creates path, stores in path var. override as needed
    func createShape() {
        // add rect as default?
        // call createTileHolder(), or other shape
    }
    
    // should this be wrapped in createPathShape? and overridden per type
    // this func moved to TriangleView
    func createTriangle(direction: Directions) {
        // set up the points, and their relationship to the direction
        let points      = [CGPoint(x:0,           y:0),
                           CGPoint(x:frame.width, y:0),
                           CGPoint(x:frame.width, y:frame.height),
                           CGPoint(x:0,           y:frame.height)]
        
        // get the 2nd and 3rd points
        let secondPoint = points[(direction.rawValue + 1) % 4]
        let thirdPoint  = points[(direction.rawValue + 2) % 4]
        // find midpoint between 2nd and 3rd points
        let midPoint    = CGPoint(x: ((secondPoint.x + thirdPoint.x) * 0.5),
                                  y: ((secondPoint.y + thirdPoint.y) * 0.5))
        
        path.move       (to: points[direction.rawValue])            // starting point
        path.addLine    (to: midPoint)                              // point of triangle
        path.addLine    (to: points[(direction.rawValue + 3) % 4])  // final point
        path.close()
    }
    
    func createTileHolder (numTiles: Int, tileWidth: CGFloat, borderWidth: CGFloat) {
        
    }
    
    // for adding tile holder shape
    func addShapeView(numTiles: Int, tileWidth: CGFloat, borderWidth: CGFloat) {
        shapeView = UIView(frame: bounds)
        guard let shapeView = shapeView else {
            return
        }
        let cornerRadius = borderWidth + TILERADIUS
        let outerPath = UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius)
        path.append(outerPath)
        if shadowed == true {shadowPath.append(outerPath)}
        for i in 0 ..< numTiles {
            let xPos = CGFloat(i) * (borderWidth + tileWidth) + borderWidth
            let tileRect = CGRect(x: xPos, y: borderWidth, width: tileWidth, height: tileWidth)
            let innerPath = UIBezierPath(roundedRect: tileRect, cornerRadius: TILERADIUS)
            if shadowed == true {shadowPath.append(innerPath)}
            path.append(innerPath)
            // If shadow will be added,
            // need to add an additional path inside, so that the shadow is filled correctly
            // according to kCAFillRuleEvenOdd
            // if from a point inside, an odd number of lines are crossed to go outside,
            // the region is filled. Therefore an extra path to cross is needed to make it an even number.
            if shadowed == true {
                //drawInContext()
                print("Adding Inner Tile")
                let inset: CGFloat = 1.25
                let iWidth = tileWidth - (2 * inset)
                let innermostTileRect = CGRect(x: xPos + inset, y: borderWidth + inset, width: iWidth, height: iWidth)
                let innermostPath = UIBezierPath(roundedRect: innermostTileRect,
                                                 cornerRadius: TILERADIUS - inset)
                shadowPath.append(innermostPath)
                
                // add some additional shadow
                let addShadow = UIView(frame: innermostTileRect)
                addShadow.backgroundColor = Colors.additionalShadow
                addSubview(addShadow)
                
                
            }
        }
        
        shapeView.mask = getShapeMask()
        self.addSubview(shapeView)

        
    }
    
    // blur fx
    func addBlurView() {
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
        blurView.frame              = arrowBounds //TODO:- replace 'arowBounds' with more generic name
        let blurSuperView = UIView(frame: bounds)
        blurSuperView.translatesAutoresizingMaskIntoConstraints = false
        blurSuperView.mask = getShapeMask() // set mask on containing view
        self.insertSubview(blurSuperView, at: 0)
        blurSuperView.insertSubview(blurView, at: 0)
    }
    
    
//    shadowBounds.append(shadowPath)
//    let shadowMaskLayer         = CAShapeLayer()
//    shadowMaskLayer.path        = shadowBounds.cgPath
//    shadowMaskLayer.fillRule    = kCAFillRuleEvenOdd
//    shadowView.layer.shadowPath     = shadowPath.cgPath
//    shadowView.layer.mask             = shadowMaskLayer
//    addSubview(shadowView)
    func addShadowView() {
        if shapeType == .triangle && shadowWidth > 0.1 {
            shadowPath.append(path)
        }
        let shadowRect  = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: bounds.height)
        shadowView = UIView(frame: shadowRect)
        
        guard let shadowView = shadowView else {
            return
        }
        shadowView.backgroundColor      = .clear
        if shapeType == .tileholder {
            shadowView.layer.cornerRadius   = TILERADIUS + borderWth
        }
        shadowView.layer.shadowColor    = UIColor.black.cgColor
        shadowView.layer.shadowOpacity  = 1.0
        shadowView.layer.shadowRadius   = shadowWidth

        shadowView.layer.masksToBounds  = false
        shadowView.layer.shadowOffset   = CGSize(width: 0, height: 0)
        
//        let outerShadowMaskRect = CGRect(x: bounds.minX - 25, y: bounds.minY - 25, width: bounds.width + 50, height: bounds.height + 50)
//        let outerShadowPath = UIBezierPath(rect: outerShadowMaskRect)
//        let innerShadowRect = CGRect(x: 0.0, y: 0.0, width: shadowView.frame.width, height: shadowView.frame.height)
//        let innerPath = UIBezierPath(roundedRect: innerShadowRect, cornerRadius: 18.0)
//
//        let shadowMask                          = CGMutablePath()
//        let shadowMaskLayer                     = CAShapeLayer()
//
//        shadowMask.addPath(outerShadowPath.cgPath)
//        shadowMask.addPath(innerPath.cgPath)
//
//        shadowMaskLayer.path                    = shadowMask
//        shadowMaskLayer.fillRule                = kCAFillRuleEvenOdd
        //shadowPath.cgPath                 = path.cgPath
        shadowView.layer.mask             = getShadowMask()
        //shadowView.mask                 = getShapeMask()
        
        addSubview(shadowView)
        
        
        
        
        //bringSubview(toFront: shadowView)
        
        //addInnerShadow()
    }
    
    func addInnerShadow() {
        //UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        //UIGraphicsPushContext(context!)
        // TODO: move out of draw rect, so can use init vars of tile holder.
        let testRect = CGRect(x: borderWth, y: borderWth, width: TILEWTH, height: TILEWTH)
        let testRect2 = CGRect(x: 2 * borderWth + TILEWTH, y: borderWth, width: TILEWTH, height: TILEWTH)
        let testRect3 = CGRect(x: 3 * borderWth + 2 * TILEWTH, y: borderWth, width: TILEWTH, height: TILEWTH)
        let testPath = UIBezierPath(roundedRect: testRect, cornerRadius: TILERADIUS)
        let testPath2 = UIBezierPath(roundedRect: testRect2, cornerRadius: TILERADIUS)
        let testPath3 = UIBezierPath(roundedRect: testRect3, cornerRadius: TILERADIUS)
        
        testPath.append(testPath2)
        testPath.append(testPath3)
        let offset = CGSize(width: 0, height: 0)
        drawInnerShadowInContext(context: context, pathShape: testPath.cgPath, shadColor: Colors.shadowBG.cgColor, offset: offset, blurRad: TILEWTH * 0.25)
        //shadowImage = UIGraphicsGetImageFromCurrentImageContext()
        //let innerShadowView = UIImageView(image: shadowImage)
        //shadowView?.addSubview(innerShadowView)
        //UIGraphicsEndImageContext()
        //UIGraphicsPushContext(context!)
    }
    
    // inner shadow
    func drawInnerShadowInContext(context: CGContext, pathShape: CGPath, shadColor: CGColor, offset: CGSize, blurRad: CGFloat) {
        
        context.saveGState()
        context.addPath(pathShape)
        context.clip()
        
        guard let opaqueShadowColor = shadColor.copy(alpha: 1.0) else {
            return
        }
        context.setAlpha(shadColor.alpha)
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        context.setShadow(offset: offset, blur: blurRad, color: opaqueShadowColor)
        context.setBlendMode(.sourceOut)
        context.setFillColor(opaqueShadowColor)
        context.addPath(pathShape)
        context.fillPath()
        context.endTransparencyLayer()
        context.restoreGState()
    }
    
    func getShadowMask() -> CAShapeLayer? {
        // invert the mask for use as a shadow mask
        // make a path that is a box larger than the entire view, then append the path
        let shadowInvertedPath          = UIBezierPath(rect: bounds.insetBy(dx: -2 * shadowWidth, dy: -2 * shadowWidth))
        
        shadowInvertedPath.append(shadowPath)
        let shadowMaskLayer             = CAShapeLayer()
        shadowMaskLayer.path            = shadowInvertedPath.cgPath
        shadowMaskLayer.fillRule        = kCAFillRuleEvenOdd
        shadowView?.layer.shadowPath    = shadowPath.cgPath
        
        return shadowMaskLayer

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
        
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0.0))
        path.close()
    }
    
    // called in init
    func addShapeWithBlur() {
        
        
        //createBezierArrow()
        //createRotatedArrow()
        
        
        for i in 0 ..< lineProperties.count {
            addSublayerShapeLayer(lineWidth: lineProperties[i].lineWidth, color: lineProperties[i].color)
        }
        
        addBlurView()
    }
    
    func addSublayerShapeLayer (lineWidth: CGFloat, color: UIColor) {
        let shapeLayer          = CAShapeLayer()
        shapeLayer.path         = self.path.cgPath
        shapeLayer.lineWidth    = lineWidth
        shapeLayer.strokeColor  = color.cgColor
        shapeLayer.fillColor    = UIColor.clear.cgColor
        shapeLayer.lineJoin     = kCALineJoinMiter
        
        shapeView?.layer.addSublayer(shapeLayer)
    }
    
//    // blur fx
//    func blurArrow() {
//        var blurEffect: UIBlurEffect
//        if #available(iOS 10.0, *) {
//            blurEffect = UIBlurEffect(style: .prominent)
//        } else {
//            blurEffect = UIBlurEffect(style: .light)
//        }
//
//        blurView = UIVisualEffectView(effect: nil)
//
//        guard let blurView = blurView else {
//            return
//        }
//
//        animator = UIViewPropertyAnimator(duration: 3, curve: .linear) {
//            self.blurView?.effect = blurEffect
//            self.animator?.pauseAnimation()
//        }
//        animator?.startAnimation()
//        animator?.fractionComplete = blurriness
//
//        blurView.translatesAutoresizingMaskIntoConstraints = false
//
//        arrowBounds = self.path.cgPath.boundingBoxOfPath
//        guard let arrowBounds = arrowBounds else {
//            return
//        }
//        blurView.frame              = arrowBounds
//
//        /*
//         let maskLayer               = CAShapeLayer()
//
//         let arrowBoundsExpanded     = CGRect(x:      arrowBounds.minX    - 20.0,
//         y:      arrowBounds.minY    - 20.0,
//         width:  arrowBounds.width   + 40.0,
//         height: arrowBounds.height  + 40.0)
//
//         let maskPath                = UIBezierPath(rect: arrowBoundsExpanded)
//         maskPath.append(self.path)
//
//         //        let mPath = CGMutablePath()
//         //        mPath.addPath(UIBezierPath(rect: arrowBoundsExpanded).cgPath)
//         //        mPath.addPath(self.path.cgPath)
//
//
//         maskLayer.path              = maskPath.cgPath
//         maskLayer.fillRule          = kCAFillRuleEvenOdd
//         maskLayer.fillColor         = Colors.bluek.cgColor
//
//
//         let mView                = UIView(frame: CGRect(x:0,y:0,width: arrowBounds.width, height: arrowBounds.height))
//
//         mView.layer.addSublayer(maskLayer)
//
//         mView.layer.mask = maskLayer
//
//         //blurView.mask = maskView
//
//         //        blurView.mask = mView
//         //        blurView.contentView.layer.mask = maskLayer
//
//         */
//        let blurSuperView = UIView(frame: bounds)
//        blurSuperView.translatesAutoresizingMaskIntoConstraints = false
////        blurSuperView.view.maskToBounds = false
//        blurSuperView.mask = getShapeMask() // set mask on containing view
//        self.insertSubview(blurSuperView, at: 0)
//        blurSuperView.insertSubview(blurView, at: 0)
//        //self.insertSubview(maskView, at: 1)
//        //blurView.layer.mask = maskLayer
//
//
//    }
    
    
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
    
    // obj-c
//    - (void)drawInnerShadowInContext:(CGContextRef)context
//    withPath:(CGPathRef)path
//    shadowColor:(CGColorRef)shadowColor
//    offset:(CGSize)offset
//    blurRadius:(CGFloat)blurRadius {
//    CGContextSaveGState(context);
//
//    CGContextAddPath(context, path);
//    CGContextClip(context);
//
//    CGColorRef opaqueShadowColor = CGColorCreateCopyWithAlpha(shadowColor, 1.0);
//
//    CGContextSetAlpha(context, CGColorGetAlpha(shadowColor));
//    CGContextBeginTransparencyLayer(context, NULL);
//    CGContextSetShadowWithColor(context, offset, blurRadius, opaqueShadowColor);
//    CGContextSetBlendMode(context, kCGBlendModeSourceOut);
//    CGContextSetFillColorWithColor(context, opaqueShadowColor);
//    CGContextAddPath(context, path);
//    CGContextFillPath(context);
//    CGContextEndTransparencyLayer(context);
//
//    CGContextRestoreGState(context);
//
//    CGColorRelease(opaqueShadowColor);
//    }
}


protocol ShapeDelegate: class {
    var shadowed:       Bool { get }
//    var path:           UIBezierPath { get }// = UIBezierPath()
//    var shadowPath:     UIBezierPath { get }// = UIBezierPath() // TODO: should be optional, as there may not be a shadow
//    var lineProperties: [LineProperties] { get }// = [LineProperties]()
//    var shapeView:      UIView? { get set }
//    var shadowView:     UIView? { get set }
//    var shapeType:      ShapeType { get }


    
    func addShapeView() // if implented by its super., doesn't need to be also in the child
    func addBlurView() // if implented by its super., doesn't need to be also in the child
    func addShadowView()
    func addCruft()
    func createShape() // wrapper for createTriangle etc
}

//@objc protocol UFCFighter {
//    var name: String { get }
//    var nickname: String? { get set }
//    func punch()
//    func kick()
//    func grapple()
//    @objc optional func trashTalk()
//}


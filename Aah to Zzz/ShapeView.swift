//  ShapeView.swift
//  AahToZzz
//
//  Created by David Fierstein on 4/10/18.
//  Copyright © 2018 David Fierstein. All rights reserved.


import UIKit

class ShapeView: UIView {
    //TODO:- cut off mask of top of arrowViews, try to blend arrows with text bubbles
    //TODO:- replace ArrowView with ArrowBlurView, renaming
    //TODO:- Create a subclass (called TextRectView?) that allows adding text and buttons into a stack view
    
    // Currently only used in Arrow views, but might be used in some other shape?
    var startPoint:     CGPoint?
    var endPoint:       CGPoint?

    //MARK:- Blur and view vars
    var blurView:       UIVisualEffectView?
    var blurriness:     CGFloat = 0.5
    var animator:       UIViewPropertyAnimator?
    var path:           UIBezierPath = UIBezierPath()
    var shadowPath:     UIBezierPath = UIBezierPath() // TODO: should be an optional, as there may not be a shadow
    var lineProperties: [LineProperties] = [LineProperties]()
    var shapeView:      UIView?
    var shadowView:     UIView?
    var shadowWidth:    CGFloat = 3.5 // only used if there is a shadow. Make optional? Needed?
    
    //MARK:- init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
        print("BUTTONFRAME1: \(frame)")
        useFrameForPoints()
    }
    
    func useFrameForPoints () {
        startPoint  = CGPoint(x: frame.minX, y: frame.minY)
        endPoint    = CGPoint(x: frame.maxX, y: frame.maxY)
        
    }
    
    // Makes a rectangle
    convenience init(frame: CGRect, blurriness: CGFloat, shadowWidth: CGFloat) {
        
        self.init(frame: frame)
        self.blurriness  = blurriness
        self.shadowWidth = shadowWidth
        addShapeView()
        if blurriness       > 0.01 { addBlurView()   }
        if shadowWidth      > 0.01 { addShadowView() }
//        guard let shadowView = shadowView else {
//            return
//        }
//        bringSubview(toFront: shadowView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // helpers for init
    func addLineProperties() {
        lineProperties = LinePropertyStyles.frosted
    }
    
    deinit {
        // ensure that all animators are stopped before dismissal
        // (otherwise this crash: 'NSInternalInconsistencyException', reason: 'It is an error to release a paused or stopped property animator. Property animators must either finish animating or be explicitly stopped and finished before they can be released.')
        animator?.stopAnimation(true)
        animator?.finishAnimation(at: UIViewAnimatingPosition(rawValue: 0)!)
        print("Shape DEINITS")
    }
    
//    func drawInContext(){
////
//        let size = CGSize(width: 90, height: 50)
////
//        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
//        let context = UIGraphicsGetCurrentContext()
////        // Establish the image context
//////        UIGraphicsBeginImageContextWithOptions(
//////            CGSize(77,212), isOpaque, 0.0);
////
////        // Retrieve the current context
////        //let context = UIGraphicsGetCurrentContext()
//        UIGraphicsPushContext(context!)
////        // Perform the drawing
//        context?.setLineWidth(4)
//        context?.setStrokeColor(UIColor.red.cgColor)
//        context?.strokeEllipse(in: bounds)
//
//context?.strokeEllipse(in: bounds)
//
////        // Retrieve the drawn image
//        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
////
////        // End the image context
//        UIGraphicsEndImageContext();
//        UIGraphicsPopContext()
//    }
    
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
    
    // should work with any shape, and not need to be overridden (but can be if needed)
    func addShapeView() {
        
        shapeView = UIView(frame: bounds)
        guard let shapeView = shapeView else {
            return
        }
//        guard let startPoint = startPoint, let endPoint = endPoint else {
//            return
//        }
//        // Check whether arrow points up or down
//        if startPoint.y - endPoint.y > 0 {
//            // arrow is pointing up
//            d = -1.0
//        }
        
        createShape() // override point for subclasses
        
        addLineProperties() // populate line properties array
        for i in 0 ..< lineProperties.count {
            addSublayerShapeLayer(lineWidth: lineProperties[i].lineWidth, color: lineProperties[i].color)
        }

        shapeView.mask = getShapeMask()
        addSubview(shapeView)
    }
    
    // Creates path, stores in path var. Override as needed per type of shape
    func createShape() {
        // call createTileHolder(), or other shape
        // override point for subclasses
        // default?
        createRectangle()
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
        blurView.frame = path.cgPath.boundingBoxOfPath
        let blurSuperView = UIView(frame: bounds)
        blurSuperView.translatesAutoresizingMaskIntoConstraints = false
        blurSuperView.mask = getShapeMask() // set mask on containing view
        self.insertSubview(blurSuperView, at: 0)
        blurSuperView.insertSubview(blurView, at: 0)
    }
    
    // override point for inner shadows or other shadow customization
    func setShadowPath() {
        shadowPath.append(path)
    }
    
    func addShadowView() {
        setShadowPath()
        shadowView = UIView(frame: bounds)
        guard let shadowView = shadowView else {
            return
        }

        shadowView.backgroundColor      = .clear
        shadowView.layer.shadowColor    = UIColor.black.cgColor
        shadowView.layer.shadowOpacity  = 1.0
        shadowView.layer.shadowRadius   = shadowWidth
        shadowView.layer.masksToBounds  = false
        shadowView.layer.shadowOffset   = CGSize(width: 0, height: 0)
        shadowView.layer.mask             = getShadowMask()
        
        addSubview(shadowView)
    }
    
    
    func getShadowMask() -> CAShapeLayer? {
        // reset the bounds to the bounds of the newly created path
        bounds  = path.cgPath.boundingBoxOfPath
        
        // invert the mask for use as a shadow mask
        // make a path that is a box larger than the entire view, then append the path
        let expandedRect                = getExpandedRect()
        let shadowInvertedPath          = UIBezierPath(rect: expandedRect)
        shadowInvertedPath.append(shadowPath)
        let shadowMaskLayer             = CAShapeLayer()
        shadowMaskLayer.path            = shadowInvertedPath.cgPath
        shadowMaskLayer.fillRule        = kCAFillRuleEvenOdd
        shadowView?.layer.shadowPath    = shadowPath.cgPath
        
        return shadowMaskLayer
    }
    
    // Override this in ArrowView to cut off top of shadow
    func getExpandedRect() -> CGRect {
        return bounds.insetBy(dx: -2 * shadowWidth, dy: -2 * shadowWidth)
    }
    
//    // adapted from similar code in BlurViewC and its xib - need to consolidate
//    func updateShadowMaskLayer () {
//        //        let outerShadowMaskRect = CGRect(x: bounds.minX - 25, y: bounds.minY - 25, width: bounds.width + 50, height: bounds.height + 50)
//        //        let outerPath = UIBezierPath(rect: outerShadowMaskRect)
//        //        let innerShadowRect = CGRect(x: 0.0, y: -1.0, width: shadowView.frame.width, height: shadowView.frame.height)
//        //        let innerPath = UIBezierPath(roundedRect: innerShadowRect, cornerRadius: cornerRadius)
//        //
//        //        let shadowMask                          = CGMutablePath()
//        //        let shadowMaskLayer                     = CAShapeLayer()
//        //
//        //        shadowMask.addPath(outerPath.cgPath)
//        //        shadowMask.addPath(innerPath.cgPath)
//        //
//        //        shadowMaskLayer.path                    = shadowMask
//        //        shadowMaskLayer.fillRule                = kCAFillRuleEvenOdd
//        //        shadowView.layer.mask                   = shadowMaskLayer
//    }
    
    
    func createRectangle() {
        
        path.move(to: CGPoint(x: frame.minX, y: frame.minY))
        path.addLine(to: CGPoint(x: frame.maxX, y: frame.minY))
        path.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
        path.addLine(to: CGPoint(x: frame.minX, y: frame.maxY))
        path.close()
    }
    
//    // called in init
//    func addShapeWithBlur() {
//
//
//        //createBezierArrow()
//        //createRotatedArrow()
//
//
//        for i in 0 ..< lineProperties.count {
//            addSublayerShapeLayer(lineWidth: lineProperties[i].lineWidth, color: lineProperties[i].color)
//        }
//
//        addBlurView()
//    }
    
    func addSublayerShapeLayer (lineWidth: CGFloat, color: UIColor) {
        let shapeLayer          = CAShapeLayer()
        shapeLayer.path         = self.path.cgPath
        shapeLayer.lineWidth    = lineWidth
        shapeLayer.strokeColor  = color.cgColor
        shapeLayer.fillColor    = UIColor.clear.cgColor
        shapeLayer.lineJoin     = kCALineJoinMiter
        
        shapeView?.layer.addSublayer(shapeLayer)
    }
    
    //TODO:- Add override for arrow views that allows cutting off top line with mask
    // Needs to be called from the containing view, otherwise the blur will not work
    func getShapeMask() -> UIView {
        
        let maskLayer               = CAShapeLayer()
        maskLayer.path              = self.path.cgPath  //  maskPath.cgPath
        maskLayer.fillRule          = kCAFillRuleEvenOdd
        
        // update the frame with the new path's bounds
        frame  = path.cgPath.boundingBoxOfPath
        let mView = UIView(frame: bounds)
        mView.layer.addSublayer(maskLayer)
        
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


//protocol ShapeDelegate: class {
//    var shadowed:       Bool { get }
////    var path:           UIBezierPath { get }// = UIBezierPath()
////    var shadowPath:     UIBezierPath { get }// = UIBezierPath() // TODO: should be optional, as there may not be a shadow
////    var lineProperties: [LineProperties] { get }// = [LineProperties]()
////    var shapeView:      UIView? { get set }
////    var shadowView:     UIView? { get set }
////    var shapeType:      ShapeType { get }
//
//
//
//    func addShapeView() // if implented by its super., doesn't need to be also in the child
//    func addBlurView() // if implented by its super., doesn't need to be also in the child
//    func addShadowView()
//    func addCruft()
//    func createShape() // wrapper for createTriangle etc
//}

//@objc protocol UFCFighter {
//    var name: String { get }
//    var nickname: String? { get set }
//    func punch()
//    func kick()
//    func grapple()
//    @objc optional func trashTalk()
//}


//
//  TileHolderView.swift
//  AahToZzz
//
//  Created by David Fierstein on 4/17/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//

import UIKit

class TileHolderView: ShapeView {
    
    let TILEWTH:           CGFloat      = 50.0 // (to do: get from Tile)
    let TILERADIUS:        CGFloat      = 8.0  // (to do: get from Tile)
    var borderWth:         CGFloat      = 10.0 // (to do: get from AtoZ VC)
    var numTiles:          Int          = 3
    var tileWidth:         CGFloat      = 50.0
    var borderWidth:       CGFloat      = 10.0
    var innerShadowPath:   UIBezierPath = UIBezierPath()
    var shadowImage:       UIImage? // rendered image of inner shadow of tile holder
    
    // init for tile holder (upper positions background)
    convenience init(numTiles: Int, tileWidth: CGFloat, borderWidth: CGFloat, blurriness: CGFloat, shadowWidth: CGFloat) {
        
        let w: CGFloat   = CGFloat((numTiles)) * (tileWidth + borderWidth) + borderWidth
        let h: CGFloat   = tileWidth + 2 * borderWidth
        let frame        = CGRect(x: 0, y: 0, width: w, height: h)
        
        self.init(frame: frame)
        self.numTiles    = numTiles
        self.tileWidth   = tileWidth
        self.borderWidth = borderWidth
        self.blurriness  = blurriness
        self.shadowWidth = shadowWidth
        //shapeType        = .tileholder
        //shadowed         = true // is this var even needed?
        
        addShapeView()
        if blurriness       > 0.01 { addBlurView()   }
        if shadowWidth      > 0.01 { addShadowView() }
        guard let shadowView = shadowView else {
            return
        }
        bringSubview(toFront: shadowView)
    }
    
    override func draw(_ rect: CGRect) {
        // create inner shadows if needed
        print("::::::*******^^^^^%%$$$$+++_@)$@::::::::::")
        print("::::::*******^^^^^%%$$$$+++_@)$@::::::::::")
        print("DRAW RECT")
        print("::::::*******^^^^^%%$$$$+++_@)$@::::::::::")
        print("::::::*******^^^^^%%$$$$+++_@)$@::::::::::")
        if shadowWidth > 0.01 {
            self.backgroundColor = UIColor.clear
            self.backgroundColor?.setFill()
            UIGraphicsGetCurrentContext()!.fill(rect);
            addInnerShadow()
        }
    }
    
    // try to move out of draw rect
    func addInnerShadow() {
        //UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        //UIGraphicsPushContext(context!)
        // TODO: move out of draw rect, so can use init vars of tile holder.

        
        let offset = CGSize(width: 0, height: 0)
        drawInnerShadowInContext(context: context, pathShape: innerShadowPath.cgPath, shadColor: Colors.shadowBG.cgColor, offset: offset, blurRad: TILEWTH * 0.25)
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
    
    // If shadow will be added, need to add an additional path inside, so that the shadow is filled correctly
    // according to kCAFillRuleEvenOdd
    // if from a point inside, an odd number of lines are crossed to go outside,
    // the region is filled. Therefore an extra path to cross is needed to make it an even number.
    override func setShadowPath() {
        shadowPath.append(path) // starting point is the shape path. (Outermost part of shadow mask added later)
        for i in 0 ..< numTiles {
            let xPos = CGFloat(i) * (borderWidth + tileWidth) + borderWidth
            let inset: CGFloat = 1.25
            let iWidth = tileWidth - (2 * inset)
            let innermostTileRect = CGRect(x: xPos + inset, y: borderWidth + inset, width: iWidth, height: iWidth)
            let innermostPath = UIBezierPath(roundedRect: innermostTileRect, cornerRadius: TILERADIUS - inset)
            shadowPath.append(innermostPath)
            innerShadowPath.append(innermostPath) // save for adding additional shadow later
            // additional shadow to add
            let addShadow = UIView(frame: innermostTileRect)
            addShadow.backgroundColor = Colors.additionalShadow
            addSubview(addShadow)
        }
    }
    
    override func createShape() {
        createTileHolder(numTiles: numTiles, tileWidth: tileWidth, borderWidth: borderWidth)
    }
    
    // for adding tile holder shape
    func createTileHolder(numTiles: Int, tileWidth: CGFloat, borderWidth: CGFloat) {

        let cornerRadius = borderWidth + TILERADIUS
        let outerPath = UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius)
        path.append(outerPath)

        for i in 0 ..< numTiles {
            let xPos = CGFloat(i) * (borderWidth + tileWidth) + borderWidth
            let tileRect = CGRect(x: xPos, y: borderWidth, width: tileWidth, height: tileWidth)
            let innerPath = UIBezierPath(roundedRect: tileRect, cornerRadius: TILERADIUS)

            path.append(innerPath)
        }
    }
}

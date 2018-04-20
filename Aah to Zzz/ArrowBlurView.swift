//
//  ArrowBlurView.swift
//  AahToZzz
//
//  Created by David Fierstein on 4/18/18.
//  Copyright © 2018 David Fierstein. All rights reserved.

import UIKit

class ArrowBlurView: ShapeView {
    
    
    convenience init(arrowType: ArrowType, startPoint: CGPoint, endPoint: CGPoint) {
        // Question: does it matter what the size of the frame is?
        // it'd be overly complex to calculate from start/end points
        self.init(frame: CGRect(x: 65, y: 20, width: 10, height: 5))
        self.startPoint = startPoint
        self.endPoint   = endPoint
        
        addShapeView()
        addBlurView()
        addShadowView()
        
    }
    
    // init for triangle shape to be added to Down Arrow
    convenience init(frame: CGRect, blurriness: CGFloat, shadowWidth: CGFloat) {
        self.init(frame: frame)
        
        self.blurriness     = blurriness
        self.shadowWidth    = shadowWidth
        
        addShapeView()
        if blurriness       > 0.01 { addBlurView()   }
        if shadowWidth      > 0.01 { addShadowView() }
    }
    
    
    override func createShape() {
        createPointer()
    }
    
    func createPointer () {

//       // if startPoint == nil {
//            useFrameForPoints()
//       // }
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

}


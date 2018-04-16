//
//  TriangleView.swift
//  AahToZzz
//
//  Created by David Fierstein on 4/14/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
import UIKit

class TriangleView: ShapeView, ShapeDelegate {
    
    var direction:   Directions = .down

    // init for triangle shape to be added to Down Arrow
    convenience init(frame: CGRect, direction: Directions, blurriness: CGFloat, shadowWidth: CGFloat) {
        self.init(frame: frame)
        
        shapeType           = .triangle
        self.direction      = direction
        self.shadowWidth    = shadowWidth

        addShapeView()
        if blurriness       > 0.01 { addBlurView()   }
        if shadowWidth      > 0.01 { addShadowView() }
    }
    
    
    // note: the mask will cut off the outer half of these lines
    override func addLineProperties() {
        lineProperties = LinePropertyStyles.frostedEdgeHighlight
    }
    
    override func createShape() {
        createTriangle(direction: direction)
    }
    
    // later remove from super, no override
    override func createTriangle(direction: Directions) {
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
    
    func addCruft() {
        print ("CRUFT")
    }
}

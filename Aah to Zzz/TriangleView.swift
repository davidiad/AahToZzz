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
    convenience init(frame: CGRect, direction: Directions) {
        self.init(frame: frame)
        shapeType = .triangle
        self.direction = direction
        //shadowed = true // make a parameter shadow spread amount (float), with 0 -> no shadow
//        addLineProperties()
        //addTriangleView(direction: direction)
        addShapeView()
//        for i in 0 ..< lineProperties.count {
//            addSublayerShapeLayer(lineWidth: lineProperties[i].lineWidth, color: lineProperties[i].color)
//        }
        addBlurView()
    }
    
//    override func addShapeView() {
//        addTriangleView(direction: direction)
//    }
    
    // note: the mask with cut off the outer half of these lines
    override func addLineProperties() {
        lineProperties.append(LineProperties(lineWidth: 15.5,  color: Colors.veryLight))
        lineProperties.append(LineProperties(lineWidth: 13.0,  color: Colors.veryLight))
        lineProperties.append(LineProperties(lineWidth: 10.0,  color: Colors.lightBackground))
        lineProperties.append(LineProperties(lineWidth: 6.75,  color: .white))
        lineProperties.append(LineProperties(lineWidth: 6.0,   color: Colors.darkBackground))
        lineProperties.append(LineProperties(lineWidth: 3.0,   color: Colors.light_yellow)) // outer 'highlight' line
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

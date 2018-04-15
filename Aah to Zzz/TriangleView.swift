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
    convenience init(frame: CGRect, directionIn: Directions) {
        self.init(frame: frame)
        shapeType = .triangle
        direction = directionIn
        shadowed = true
        addLineProperties()
        //addTriangleView(direction: direction)
        addShapeView()
        for i in 0 ..< lineProperties.count {
            addSublayerShapeLayer(lineWidth: lineProperties[i].lineWidth, color: lineProperties[i].color)
        }
        addBlurView()
    }
    
    override func addShapeView() {
        addTriangleView(direction: direction)
    }
    
    override func createShape() {
        // createTriangle etc
    }
    
    func addCruft() {
        print ("CRUFT")
    }
}

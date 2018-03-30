//
//  ArrowView.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/28/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//

import UIKit

class ArrowView: UIView {

    var startPoint: CGPoint?
    var endPoint: CGPoint?
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
    
//    convenience init(frame: CGRect, sPoint: CGPoint, ePoint: CGPoint) {
//
//        startPoint = sPoint
//        endPoint = ePoint
//        self.init(frame: frame)
//    }
    
    func createArrow () {
        path = UIBezierPath()
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        //path.close()
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
        self.createArrow()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = self.path.cgPath
        shapeLayer.fillColor = UIColor.yellow.cgColor
        shapeLayer.strokeColor = UIColor.brown.cgColor
        shapeLayer.lineWidth = 13.0
        self.layer.addSublayer(shapeLayer)
    }

}

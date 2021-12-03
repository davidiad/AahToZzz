//
//  Tile.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/4/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit

//TODO: add to model: LetterPositions (10); TileInfo - 7 (?) -- or add to Letter? or, add location(or position) or LetterPosition to Letter, and from there, add to tile

class Tile: UIButton {
    var snapBehavior: UISnapBehavior?
    
    //TODO: this property is confusing, as there is also a position property in Letter which is a Position
    // check whether it's really needed? The Tile should get its position from its letter.position property
    //TODO: Consider removing position behavior. It's covered by position.letter.position. And besides, there's already an x and a y
    var position: CGPoint? // when this is updated, need to also update the letter position
    var letter: Letter? // letter.position.position would remove the need for the CGPoint position
    //var animator: UIDynamicAnimator?  // or use animator in view file?
    var boundingPath: UIBezierPath? // used for collision boundary
    // TODO: outline tile path in code for higher res
    //MARK:- Private vars
    //private var offset: CGPoint = CGPoint(x: 0, y: 0)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        layer.cornerRadius = 8.0
        layer.masksToBounds = false
        layer.shadowColor = UIColor.purple.cgColor
        layer.shadowOpacity = 0.0
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        boundingPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
        
//        let mutableAttrString = NSMutableAttributedString(string: (titleLabel?.text)!)
//        titleLabel?.attributedText = NSMutableAttributedString(attributedString: mutableAttrString)
        
       // var myRange = NSRange(location: 0, length: 1) // range starting at location 17 with a lenth of 7: "Strings"
        //titleLabel?..addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: myRange)
        

        
//        setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
//        titleLabel?.font = UIFont.systemFontOfSize(42.0)
        
//        let attributes: [String : AnyObject] = [NSFontAttributeName : UIFont(name: "BanglaSangamMN-Bold", size: 42.0)!,
//                                                NSForegroundColorAttributeName : UIColor.darkGrayColor()]
//        let title = NSAttributedString(string: "A", attributes: attributes)
//        
//        setAttributedTitle(title, forState: .Normal)
        
        let image = UIImage(named: "tile") as UIImage?
        setBackgroundImage(image, for: UIControl.State())
        
        
    }
    
   // override func attributedTitleForState(state: UIControlState) -> NSAttributedString? {

   // }
    
//    func setupPanRecognizer() {
//        let panRecognizer = UIPanGestureRecognizer(target: self, action: "pan:")
//        addGestureRecognizer(panRecognizer)
//    }
//    
//    func pan(pan: UIPanGestureRecognizer) {
//        animator?.removeBehavior(snapBehavior!)
//        animator?.removeAllBehaviors()
//        var location = pan.locationInView(self)
//        
//        switch pan.state {
//        case .Began:
//            
//            let center = self.center
//            offset.x = location.x - center.x
//            offset.y = location.y - center.y
//            
//            //animator?.removeAllBehaviors()
//            
//        case .Changed:
//            let referenceBounds = self.bounds
//            let referenceWidth = referenceBounds.width
//            let referenceHeight = referenceBounds.height
//            
//            // Get item bounds.
//            let itemBounds = self.bounds
//            let itemHalfWidth = itemBounds.width / 2.0
//            let itemHalfHeight = itemBounds.height / 2.0
//            
////            // Apply the initial offset.
////            location.x -= offset.x
////            location.y -= offset.y
//            
//            // Bound the item position inside the reference view.
////            location.x = max(itemHalfWidth, location.x)
////            location.x = min(referenceWidth - itemHalfWidth, location.x)
////            location.y = max(itemHalfHeight, location.y)
////            location.y = min(referenceHeight - itemHalfHeight, location.y)
//            
//            center = location
//            
//        case .Ended:
//            let velocity = pan.velocityInView(self)
//            
////            animator?.addBehavior(radialGravity)
////            animator?.addBehavior(itemBehavior)
////            animator?.addBehavior(collisionBehavior)
////            
////            itemBehavior.addLinearVelocity(velocity, forItem: raft)
//            
//        default: break
//        }
 //   }

    
}

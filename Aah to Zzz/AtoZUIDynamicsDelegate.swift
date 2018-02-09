//
//  AtoZUIDynamicsDelegate.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/3/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//

//import Foundation
import UIKit

class AtoZUIDynamicsDelegate: NSObject, UIDynamicAnimatorDelegate, Lettertiles {
    
    var lettertiles: [Tile]?
    
    //MARK:- dynamic animator delegate
    var animatorBeganPause: Bool = false
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        if !animatorBeganPause { // otherwise this is called continually
            for tile in lettertiles! {
                checkTilePosition(tile) // NOTE: this check may not be needed
            }
            animatorBeganPause = true
        }
    }
    
    func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator) {
        animatorBeganPause = false // reset
    }
    
    // Helper to see if tile has reached its position after dynamic animator has paused
    func checkTilePosition(_ tile: Tile) {
        // TODO: check if the position checking is working
        //animator.removeBehavior(tile.snapBehavior!)
        
        let tolerance: Float = 0.1
        guard let tilePosX = tile.letter!.position?.xPos else {
            return
        }
        let checkX = abs(Float(tile.frame.origin.x) - tilePosX)
        
        guard let tilePosY = tile.letter!.position?.yPos else {
            return
        }
        let checkY = abs(Float(tile.frame.origin.y) - tilePosY)
        
        if checkX > tolerance || checkY > tolerance {
            
            UIView.animate(withDuration: 0.15, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                
                //tile.transform = CGAffineTransformIdentity // this line is a safeguard in case tiles get rotated after a jumble. However, may not be needed, and was preventing enlarging the tiles during a pan (to make them appear raised above the others while panning)
                
                tile.center = (tile.letter?.position?.position)!
                
            }, completion: { (finished: Bool) -> Void in
            })
            //tile.center = (tile.letter?.position?.position)!
        }
    }
}

protocol Lettertiles {
    var lettertiles: [Tile]? {get}
}

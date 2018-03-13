//
//  ProxyTable.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/12/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//

import UIKit

class ProxyTable: UITableView {
    
    var proxyTableArrow: UIImageView?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        arrowFade(amount: 0.3)
//        guard let arrow = proxyTableArrow else {
//            return
//        }
//        let opacityAnimator = UIViewPropertyAnimator(duration: 1.0, curve: .easeIn) {
//            arrow.alpha = 0.3
//        }
//        opacityAnimator.startAnimation()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        arrowFade(amount: 0.0)
    }
    
    func arrowFade(amount: CGFloat) {
        guard let arrow = proxyTableArrow else {
            return
        }
        let opacityAnimator = UIViewPropertyAnimator(duration: 1.0, curve: .easeInOut) {
            arrow.alpha = amount
        }
        opacityAnimator.startAnimation()
    }
    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesCancelled(touches, with: event)
//        guard let arrow = proxyTableArrow else {
//            return
//        }
//        let opacityAnimator = UIViewPropertyAnimator(duration: 1.0, curve: .easeOut) {
//            arrow.alpha = 0.0
//        }
//        opacityAnimator.startAnimation()
//    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

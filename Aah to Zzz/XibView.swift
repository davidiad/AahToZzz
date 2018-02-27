//
//  XibView.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/24/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//
/* from:
https://medium.com/zenchef-tech-and-product/how-to-visualize-reusable-xibs-in-storyboards-using-ibdesignable-c0488c7f525d
 
 and:
 https://medium.com/@brianclouser/swift-3-creating-a-custom-view-from-a-xib-ecdfe5b3a960
 */

import UIKit

@IBDesignable
class XibView : UIView {
    
    var contentView:UIView?
    @IBInspectable var nibName:String?

    @IBOutlet weak var blurView: UIVisualEffectView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
        controlBlur()
    }
    
    func xibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask =
            [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
        
    }
    
    func loadViewFromNib() -> UIView? {
        guard let nibName = nibName else { return nil }
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(
            withOwner: self,
            options: nil).first as? UIView
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
    }
    
    func controlBlur () {
        
        
        var blurEffect: UIBlurEffect
        if #available(iOS 10.0, *) {
            blurEffect = UIBlurEffect(style: .prominent)
        } else {
            blurEffect = UIBlurEffect(style: .light)
        }
        //blurView = UIVisualEffectView(effect: nil)
//        guard let blurView = blurView else {
//            return
//        }
        blurView.effect = nil
        if #available(iOS 10.0, *) {
            //var animator: UIViewPropertyAnimator?
            
            
            var animator = UIViewPropertyAnimator(duration: 0.2, curve: .linear) {
                print ("CONTROL BLUR animator")
                self.blurView?.effect = blurEffect
                
            }
            
            
            //animator.pauseAnimation()
            //animator.startAnimation()
           
            //blurView?.effect = blurEffect
            animator.stopAnimation(true)
            
            animator.fractionComplete = 0.66 // set the amount of bluriness here
        }
 
    }
}

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
    
    @IBAction func changeBlur(_ sender: Any) {
        controlBlur()
    }
    
    @IBOutlet weak var bview: UIVisualEffectView!
    var contentView:UIView?
    //var blurView2: UIVisualEffectView?
    @IBInspectable var nibName:String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
        //controlBlur()
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
        
        //blurView2 = UIVisualEffectView(effect: nil)
//        guard let bview = bview else {
//            return
//        }
        //bview.effect = nil
        
        if #available(iOS 10.0, *) {
            var animator: UIViewPropertyAnimator?
            
//            var ani = UIViewPropertyAnimator(duration: 1.0, curve: .linear, animations: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
//                        animator = UIViewPropertyAnimator(duration: 0.2, curve: .linear, animations: { [weak self] in
            
//            animator = UIViewPropertyAnimator(duration: 1, curve: .linear) {
//                print ("CONTROL BLUR animator")
//
//                self.bview?.effect = blurEffect
//
//            }
            
            
            animator = UIViewPropertyAnimator(duration: 9, curve: .linear) {
                self.bview?.effect = nil
                
                
            
            }
            
//
            animator?.stopAnimation(false)
            //animator?.finishAnimation(at: UIViewAnimatingPosition(rawValue: Int(1.0))!)
            
            animator?.startAnimation()
            
            
//
 //
//
//            animator?.fractionComplete = 0.66 // set the amount of blurriness here
            
        }
        
//        contentView?.insertSubview(blurView2, at: 0)
    }
}


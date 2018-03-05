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
//            var animateDown: UIViewPropertyAnimator?
//            var animateUp: UIViewPropertyAnimator?
//            animateDown?.isInterruptible = true
//            animateUp?.isInterruptible = true
            
//            var ani = UIViewPropertyAnimator(duration: 1.0, curve: .linear, animations: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
//                        animator = UIViewPropertyAnimator(duration: 0.2, curve: .linear, animations: { [weak self] in
            
//            animator = UIViewPropertyAnimator(duration: 1, curve: .linear) {
//                print ("CONTROL BLUR animator")
//
//                self.bview?.effect = blurEffect
//
//            }
//            if #available(iOS 11.0, *) {
//                animateDown?.pausesOnCompletion = true
//                animateUp?.pausesOnCompletion = true
//            }
            var animateDown: UIViewPropertyAnimator?
            animateDown = UIViewPropertyAnimator(duration: 4, curve: .linear) {
                
                
//                    self.bview?.effect = UIBlurEffect(style: .dark)
                    self.bview?.effect = nil
//                animateDown?.pauseAnimation()
            }
            
//            animateDown = partialAni {
//                print("Partial Ani")
//                animateDown.startAnimation()
//                animateDown.fractionComplete = 0.25
//            }
            animateDown?.startAnimation()
            
            animateDown?.fractionComplete = 0.25

//            animateDown?.addCompletion { _ in
//                print("IN COMPLETION")
//                animateUp?.fractionComplete = CGFloat(0.4)
//                animateUp?.startAnimation()
//                animateUp?.fractionComplete = CGFloat(0.3)
//            }
            
//            animateUp = UIViewPropertyAnimator(duration: 3.0, curve: .linear) {
//                animateUp?.fractionComplete = CGFloat(0.3)
//                self.bview?.effect = blurEffect
//
//                animateUp?.fractionComplete = CGFloat(0.3)
                //animateDown?.stopAnimation(false)
                //animateUp?.pauseAnimation()
            
            //dataTask(with: request, completionHandler: { (data, response, error) in
            
            
            
//            partialAni(ani:animateDown, completion: {
//                    animateDown.pauseAnimation()
//                })
            
           
        
        
//
//            animateUp?.addCompletion { _ in
////                let secondAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear) {
////                    animatableView.transform = CGAffineTransform.identity
////                }
//                print("COMPETIONS???")
//                animateUp?.stopAnimation(true)
//                animateUp?.fractionComplete = 0.5
////                secondAnimator.startAnimation()
//            }
            
//            if #available(iOS 11.0, *) {
//                animateUp?.pausesOnCompletion = true
//            }
            //animateUp?.startAnimation()
            
            //animateUp?.stopAnimation(true)
            
            
            
//
 //
//
//            animator?.fractionComplete = 0.66 // set the amount of blurriness here
            
        }
    
    }
    
    @available(iOS 10.0, *)
    func partialAni(completion: () -> Void) -> UIViewPropertyAnimator  {
        var ani: UIViewPropertyAnimator?
        ani = UIViewPropertyAnimator(duration: 2, curve: .linear) {
            //self.bview?.effect = UIBlurEffect(style: .light)
            self.bview?.effect = nil
            ani?.pauseAnimation()
        }
        
        return ani!
    }
    

    
    
//        contentView?.insertSubview(blurView2, at: 0)
}



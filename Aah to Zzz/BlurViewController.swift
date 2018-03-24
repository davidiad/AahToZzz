//
//  BlurViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/5/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//

import UIKit

class BlurViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var outerShadowMask: UIView!
    
    //MARK: - Properties
    var numLines: Int           = 0
    var textLines: [String]     = []
    var blurriness: CGFloat     = 0.5
    var cornerRadius: CGFloat   = 20.0
    var shadowOpacity: Float    = 0.5
    var shadowRadius: CGFloat   = 6.0
    var borderWidth: CGFloat    = 1.0
    var buttons: [UIButton]?
    
    //MARK:- Vars
    var blurView: UIVisualEffectView?
    var animator: UIViewPropertyAnimator?
    var opacityAnimator: UIViewPropertyAnimator?
    var opacityAnimator2: UIViewPropertyAnimator?
    var animatingStatusHeight: Bool = false
    var textAsButtons: Bool = false
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var blurEffect: UIBlurEffect
        if #available(iOS 10.0, *) {
            blurEffect = UIBlurEffect(style: .prominent)
        } else {
            blurEffect = UIBlurEffect(style: .light)
        }
        blurView = UIVisualEffectView(effect: nil)
        
        guard let blurView = blurView else {
            return
        }

        
        animator = UIViewPropertyAnimator(duration: 3, curve: .linear) {
            self.blurView?.effect = blurEffect
            self.animator?.pauseAnimation()
        }
        animator?.startAnimation()
        animator?.fractionComplete = blurriness
        
        blurView.layer.cornerRadius = cornerRadius
        blurView.layer.masksToBounds = true
        blurView.layer.borderWidth = borderWidth
        blurView.layer.borderColor = Colors.bluek.cgColor
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.clear
        view.insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        initLines()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // shadowView.frame size is now set, so it's safe to create the shadowmask
        shadowView.layer.cornerRadius = cornerRadius
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = shadowOpacity
        shadowView.layer.shadowRadius = shadowRadius
        shadowView.layer.masksToBounds = false

//        let outerPath = UIBezierPath(rect: outerShadowMask.frame)
//        let innerPath = UIBezierPath(roundedRect: shadowView.frame, cornerRadius: cornerRadius)
//
//        let shadowMask                          = CGMutablePath()
//        let shadowMaskLayer                     = CAShapeLayer()
//        shadowMask.addPath(outerPath.cgPath)
//        shadowMask.addPath(innerPath.cgPath)
//        shadowMaskLayer.path                    = shadowMask
//        shadowMaskLayer.fillRule                = kCAFillRuleEvenOdd
//
//        shadowView.layer.mask = shadowMaskLayer
        
        //updateShadowMaskLayer()
        
        // Since we don't know the size of the shadowmask until ViewDidAppear
        // set the shadowView opacity was set to 0 in xib, to be animated up here
        // (otherwise, the unmasked shadowView would flash before its opacity is set to 0)
        opacityAnimator = UIViewPropertyAnimator(duration: 0.35, curve: .easeOut) {
            self.shadowView?.layer.opacity = 1.0
        }
        opacityAnimator?.startAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //shadowView?.layer.opacity = 0.0
       // while animatingStatusHeight {

        // 1. start the animation of .4 s from 52 height to 90 (or whatever) of the inner mask path
        // 2.
            updateShadowMaskLayer()
       // }
        
//        opacityAnimator2 = UIViewPropertyAnimator(duration: 4.35, curve: .easeIn) {
//            self.shadowView?.layer.opacity = 1.0
//        }
//        opacityAnimator2?.startAnimation()
        
    }
    
    func updateShadowMaskLayer () {
        let outerPath = UIBezierPath(rect: outerShadowMask.frame)
        let innerShadowRect = CGRect(x: 0.0, y: -1.0, width: shadowView.frame.width, height: shadowView.frame.height)
        let innerPath = UIBezierPath(roundedRect: innerShadowRect, cornerRadius: cornerRadius)
        
        let shadowMask                          = CGMutablePath()
        let shadowMaskLayer                     = CAShapeLayer()
        
        shadowMask.addPath(outerPath.cgPath)
        shadowMask.addPath(innerPath.cgPath)
        shadowMaskLayer.path                    = shadowMask
        shadowMaskLayer.fillRule                = kCAFillRuleEvenOdd
        shadowView.layer.mask = shadowMaskLayer
    }
    
    // Format the text
    func formatBubbleText(textToFormat: String) -> NSAttributedString {
        
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 3
        shadow.shadowOffset = CGSize(width: 0, height: 3)
        shadow.shadowColor = UIColor.gray
        
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .center
        
        let multipleAttributes: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.font: UIFont(name: "Noteworthy-Bold", size: 18.0)!,
            NSAttributedStringKey.paragraphStyle: paraStyle,
            NSAttributedStringKey.shadow: shadow,
            NSAttributedStringKey.strokeColor: Colors.darkBackground,
            NSAttributedStringKey.foregroundColor: Colors.lighterDarkBrown,
            NSAttributedStringKey.strokeWidth: -1.0]
        
        return NSAttributedString(string: textToFormat, attributes: multipleAttributes)
    }
    
    // Set the text for the bubble
    func initLines() {
        
        if numLines > 0 {
            
            // create the labels and add them to the stack view
            
            for t in textLines {
                if textAsButtons == false {
                    let textLineLabel = UILabel()
                    textLineLabel.attributedText = formatBubbleText(textToFormat: t)
                    textLineLabel.sizeToFit() // move to formatting
                    stackView.addArrangedSubview(textLineLabel)
                } else {
//                    let textline = UIButton()
//                    textline.setTitle(t, for: .normal)
//                    textline.sizeToFit()
//                    //textline.addTarget(self, action: #selector(action(sender:)), for: .touchUpInside)
//
                    
                    
                    // add button collection from storyboard
                    guard let buttons = buttons else {
                        print("NO BUTTONS IN THIS ONE")
                        return
                    }
                    for button in buttons {
                        stackView.addArrangedSubview(button)
                    }
//                    if buttons != nil {
//                        for button in buttons! {
//                            stackView.addArrangedSubview(button)
//                        }
//                    }
                }
                
                
                // add any necessary formatting
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

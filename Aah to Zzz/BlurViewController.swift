//
//  BlurViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/5/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//

import UIKit

class BlurViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var outerShadowMask: UIView!
    
    var blurView: UIVisualEffectView?
    var numLines: Int = 0
    var textLines: [String] = []
    
    var animator: UIViewPropertyAnimator?
    var opacityAnimator: UIViewPropertyAnimator?
    
    
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
        animator?.fractionComplete = 0.5 // set the amount of bluriness here
        
        blurView.layer.cornerRadius = 20.0
        blurView.layer.masksToBounds = true
        blurView.layer.borderWidth = 1.0
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
        shadowView.layer.cornerRadius = 20.0
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowRadius = 6
        shadowView.layer.masksToBounds = false

        let outerPath = UIBezierPath(rect: outerShadowMask.frame)
        let innerPath = UIBezierPath(roundedRect: shadowView.frame, cornerRadius: 20)
        
        let shadowMask = CGMutablePath()
        let shadowMaskLayer = CAShapeLayer()
        shadowMask.addPath(outerPath.cgPath)
        shadowMask.addPath(innerPath.cgPath)
        shadowMaskLayer.path = shadowMask
        shadowMaskLayer.fillRule = kCAFillRuleEvenOdd
        shadowView.layer.mask = shadowMaskLayer
        
        // Since we don't know the size of the shadowmask until ViewDidAppear
        // set the shadowView opacity was set to 0 in xib, to be animated up here
        // (otherwise, the unmasked shadowView would flash before its opacity is set to 0)
        opacityAnimator = UIViewPropertyAnimator(duration: 0.35, curve: .easeOut) {
            self.shadowView?.layer.opacity = 1.0
        }
        opacityAnimator?.startAnimation()
    }
    
    // Set the text for the bubble
    func initLines() {
        
        if numLines > 0 {
            
            // create the labels and add them to the stack view
            for t in textLines {
                let textLine = UILabel()
                // set the labels' text to the value of textLines[n]
                textLine.text = t
                textLine.sizeToFit() // move to formatting
                stackView.addArrangedSubview(textLine)
                
                // add any necessary formatting
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

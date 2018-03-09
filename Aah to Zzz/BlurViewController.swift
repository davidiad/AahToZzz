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

        
        //if #available(iOS 10.0, *) {
            //var animator: UIViewPropertyAnimator?
            animator = UIViewPropertyAnimator(duration: 3, curve: .linear) {
                self.blurView?.effect = blurEffect
                self.animator?.pauseAnimation()
            }
            animator?.startAnimation()
            animator?.fractionComplete = 0.5 // set the amount of bluriness here
        //}
        
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
        
        shadowView.layer.cornerRadius = 20.0
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowRadius = 10
        shadowView.layer.masksToBounds = false
//        let r = CGRect(x: outerShadowMask.frame.minX + 25.0, y: outerShadowMask.frame.minY + 25.0, width: outerShadowMask.frame.width - 50.0, height: outerShadowMask.frame.height - 50.0)
        let r = outerShadowMask.frame.offsetBy(dx: 25, dy: 25)
        let outerPath = UIBezierPath(rect: outerShadowMask.frame)
        let innerPath = UIBezierPath(roundedRect: r, cornerRadius: 20)
        
        let shadowMask = CGMutablePath()
        let shadowMaskLayer = CAShapeLayer()
        shadowMask.addPath(outerPath.cgPath)
        shadowMask.addPath(innerPath.cgPath)
        shadowMaskLayer.path = shadowMask
        shadowMaskLayer.fillRule = kCAFillRuleEvenOdd
        shadowView.layer.mask = shadowMaskLayer
        
        initLines()
        
//        //outerPath.append(innerPath)
//        outerPath.usesEvenOddFillRule = true
//        outerPath.addClip()
//        let shadowPath = outerPath.cgPath
//        blurView.layer.transform = CATransform3DMakeTranslation(-66, -52, 0)
//        blurView.layer.shadowPath = shadowPath

//        // Mask path
//        //CGMutablePathRef path = CGPathCreateMutable();
//        let path = CGMutablePath()
//        let shadowArea = UIBezierPath(rect: CGRect(x: -30, y: -30, width: 500, height: 750))
//        //CGPathAddRect(path, nil, (CGRect){.origin={0,0}, .size=frame.size});
//        path.addPath(shadowArea.cgPath)
//        //CGPathAddPath(path, &trans, shadowLayer.shadowPath);
//        path.addPath(innerPath.cgPath)
//        //CGPathCloseSubpath(path);
//        path.closeSubpath()
//
        // Mask layer
//        let path = CGMutablePath()
//        let maskLayer = CAShapeLayer()
//        maskLayer.frame = shadowView.frame
//        //maskLayer.fillRule = kCAFillRuleEvenOdd;
//        maskLayer.path = innerPath.cgPath;
//        //maskLayer.transform = CATransform3DMakeTranslation(-25, 15, 0)
//        shadowView.layer.mask = maskLayer
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

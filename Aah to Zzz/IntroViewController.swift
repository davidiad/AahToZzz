//
//  IntroViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 5/31/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

import UIKit


class IntroViewController: UIViewController {

    @IBOutlet weak var xibview: XibView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bg: UIImageView!
    @IBOutlet weak var infoBorder: UIImageView!
    
    @IBAction func play(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var blurredViews: [BlurViewController]?
    
    
    var blurView: UIVisualEffectView?
    var blurView2: UIVisualEffectView?
    var blurView3: UIVisualEffectView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var bvc1 = BlurViewController()
        var bvc2 = BlurViewController()
        blurredViews = [BlurViewController]()
        print("??????????")
        blurredViews?.append(bvc1)
        blurredViews?.append(bvc2)
        print(blurredViews)
        print("BVC: \(blurredViews?.count)")
        print("??????????")
        blurView3 = UIVisualEffectView(effect: nil)
        guard let blurView3 = blurView3 else {
            return
        }
        
        blurView2 = xibview.bview
        if #available(iOS 10.0, *) {
            //blurView3.effect = nil
            var animator2: UIViewPropertyAnimator?
            animator2 = UIViewPropertyAnimator(duration: 5, curve: .linear) {
                self.blurView3?.effect = UIBlurEffect(style: .extraLight)
                animator2?.pauseAnimation()
            }
            animator2?.fractionComplete = 0.1
            animator2?.startAnimation()
            animator2?.fractionComplete = 0.2 // set the amount of blurriness here
        }
        //view.insertSubview(blurView3, at: 1)
//        NSLayoutConstraint.activate([
//            blurView3.heightAnchor.constraint(equalTo: (blurView2?.heightAnchor)!),
//            blurView3.leadingAnchor.constraint(equalTo: (blurView2?.leadingAnchor)!),
//            blurView3.topAnchor.constraint(equalTo: (blurView2?.topAnchor)!),
//            blurView3.trailingAnchor.constraint(equalTo: (blurView2?.trailingAnchor)!)
//            ])
        
        
        bg.layoutIfNeeded()
        bg.layer.cornerRadius = 20.0
        bg.layer.borderWidth = 0.0
        bg.layer.borderColor = Colors.bluek.cgColor
        bg.layer.shadowColor = UIColor.black.cgColor
        bg.layer.shadowOpacity = 1
        bg.layer.shadowOffset = CGSize.zero
        bg.layer.shadowRadius = 12
        bg.layer.masksToBounds = false
        
        let outerPath = UIBezierPath(roundedRect: bg.frame, cornerRadius: 20)
        let innerCG = CGRect(x: 134.0, y: 72.0, width: 269, height: 176)
        let innerPath = UIBezierPath(roundedRect: innerCG , cornerRadius: 20)
        //outerPath.append(innerPath)
        outerPath.usesEvenOddFillRule = true
        outerPath.addClip()
        let shadowPath = outerPath.cgPath
        bg.layer.transform = CATransform3DMakeTranslation(-66, -52, 0)
        bg.layer.shadowPath = shadowPath
        
        // Mask path
        //CGMutablePathRef path = CGPathCreateMutable();
        let path = CGMutablePath()
        let shadowArea = UIBezierPath(rect: CGRect(x: -50, y: -80, width: 600, height: 400))
        //CGPathAddRect(path, nil, (CGRect){.origin={0,0}, .size=frame.size});
        path.addPath(shadowArea.cgPath)
        //CGPathAddPath(path, &trans, shadowLayer.shadowPath);
        path.addPath(innerPath.cgPath)
        //CGPathCloseSubpath(path);
        path.closeSubpath()
        
        // Mask layer
        let maskLayer = CAShapeLayer()
        maskLayer.frame = innerCG
        maskLayer.fillRule = kCAFillRuleEvenOdd;
        maskLayer.path = path;
        print("DIM: \(bg.frame)")
        maskLayer.transform = CATransform3DMakeTranslation(-200, -90, 0)
        bg.layer.mask = maskLayer
        
        view.isOpaque = false
        
        // blur effect
        bg.backgroundColor = .clear
        bg.isOpaque = false
        
        infoBorder.layoutIfNeeded()
        infoBorder.layer.cornerRadius = 20.0
        infoBorder.layer.borderWidth = 0.0
        infoBorder.layer.borderColor = Colors.bluek.cgColor
        infoBorder.layer.masksToBounds = false
        
        
        
        view.isOpaque = false
        
        // blur effect
        bg.backgroundColor = .clear
        bg.isOpaque = false
        
        
        
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
        
        if #available(iOS 10.0, *) {
            var animator: UIViewPropertyAnimator?
            animator = UIViewPropertyAnimator(duration: 3, curve: .linear) {
                self.blurView?.effect = blurEffect
                animator?.pauseAnimation()
            }
            animator?.startAnimation()
            animator?.fractionComplete = 0.66 // set the amount of bluriness here
        }

        blurView.layer.cornerRadius = 20.0
        blurView.layer.masksToBounds = false
        blurView.layer.borderWidth = 0.0
        
        blurView.layer.borderColor = Colors.desat_yellow.cgColor
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.shadowColor = UIColor.black.cgColor
        blurView.layer.shadowOpacity = 1
        blurView.layer.shadowOffset = CGSize.zero
        blurView.layer.shadowRadius = 20
        view.insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: stackView.heightAnchor),
            blurView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            blurView.topAnchor.constraint(equalTo: stackView.topAnchor),
            blurView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
            ])
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(vibrancyView)

        NSLayoutConstraint.activate([
            vibrancyView.heightAnchor.constraint(equalTo: blurView.contentView.heightAnchor),
            vibrancyView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            vibrancyView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            vibrancyView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor)
            ])

        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: vibrancyView.contentView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: vibrancyView.contentView.centerYAnchor),
            ])
        

        
    }
    

//    var blurredViews: [BlurViewController]?
    //var embeddedViewController: BlurViewController!
    // Pass text info to blurred background VC's
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let blurredBubble = segue.destination as? BlurViewController else {
            print ("NO BLURRED BUBBLE")
            return
        }
        if blurredViews == nil {
            let bvc1 = BlurViewController()
            let bvc2 = BlurViewController()
            blurredViews = [BlurViewController]()
            print("??????????")
            blurredViews?.append(bvc1)
            blurredViews?.append(bvc2)
            print(blurredViews ?? "NO BLURRED vvvvvviewwwws")
            print("BVC: \(blurredViews?.count)")
            print("??????????")
        }
//        guard let blurred = blurredViews else {
//            print ("NO BLURRED VIEWS")
//            return
//        }
        
        if segue.identifier == "Blurred1" {

            blurredViews![0] = (segue.destination as? BlurViewController)!
            blurredViews![0].numLines = 2
            print(blurredViews![0])
            if blurredViews![0].textLines == nil {
                blurredViews![0].textLines = Array(repeating: "Q", count: blurredViews![0].numLines!)
            }
            blurredViews![0].textLines![0] = "First Line"
            blurredViews![0].textLines![1] = "2nd Line of D"
        } else if segue.identifier == "Blurred2" {
            blurredViews![1] = (segue.destination as? BlurViewController)!
            blurredViews![1].numLines = 1
            if blurredViews![1].textLines == nil {
                blurredViews![1].textLines = Array(repeating: "Q", count: blurredViews![1].numLines!)
            }
            
            blurredViews![1].textLines![0] = "3"
        }
        //blurredBubble.initLines()
        print("BlurredViews: \(blurredViews)    \(blurredViews?.count)")
    }
    
    // needed??
    override func viewWillLayoutSubviews() {
        print("DIM VWLOSV's: \(bg.frame)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

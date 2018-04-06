//
//  IntroViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 5/31/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

import UIKit
//TODO:- if poss, add New List icon, and possibly arrows pointing to appropo place

class IntroViewController: UIViewController {


    //@IBOutlet weak var xibview: XibView!
    //@IBOutlet weak var stackView: UIStackView!
    //@IBOutlet weak var bg: UIImageView!
    //@IBOutlet weak var infoBorder: UIImageView!
    

    //@IBAction func play(_ sender: Any) {
        //dismiss(animated: true, completion: nil)
    //}
    
    //MARK:- Constants

    let bubbleText1: [String] = ["Tap or drag tiles",
                                 "to form",
                                 "three letter words"]
    
    let bubbleText2: [String] = ["Tap a word",
                                 "to see its definition"]
    
    let bubbleText3: [String] = ["Tap",
                                 "the New List button",
                                 "to get",
                                 "new words to find"]
    
    //MARK:- Outlets
    @IBOutlet var containers: [UIView]!

    //MARK:- Vars
    var blurredViews:           [BlurViewController]    = []
    var currentContainerIndex:  Int                     = 0
    var arrowStartPoints:       [CGPoint]               = []
    var arrowEndPoints:         [CGPoint]               = []
    var arrowViews:             [ArrowView]             = []
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        fadeMessageBubblesOrDismiss()
    }
    
    func fadeMessageBubblesOrDismiss() {
        // fade out the current msg bubble
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [.transitionCrossDissolve, .curveEaseInOut], animations: {
            self.containers[self.currentContainerIndex].alpha = 0.0
            self.arrowViews[self.currentContainerIndex].alpha = 0.0
        }) { (_) in
            // set the next message bubble
            // if the current is the last, then dismiss the entire view controller
            // and don't proceed
            self.currentContainerIndex += 1
            if self.currentContainerIndex >= self.containers.count {
                // run the last animation (if any)
                self.ghostFingerTap(whereToTap: CGPoint(x: 9.0, y: 7.8), completion: { (finished) in
                // then, upon completion, dismiss VC (TODO: add completion handler for this)
                    // Note: crashing when dismiss inside completion handler
//                    self.dismiss(animated: true, completion: nil)
//                    return
                })
                // ensure that all animators are stopped before dismissal
                for i in 0 ..< self.arrowViews.count {
                    print(i)
                    print(":::")
                    //if self.arrowViews[i].animator?.isRunning == true {
                        self.arrowViews[i].animator?.stopAnimation(true)
                        self.arrowViews[i].animator?.finishAnimation(at: UIViewAnimatingPosition(rawValue: 0)!)
                        
                    //}
                }
                self.dismiss(animated: true, completion: nil)
                return
            }
            // fade in the next msg bubble
            UIView.animate(withDuration: 1.0, delay: 0.1, options: [.transitionCrossDissolve, .curveEaseOut], animations: {
                    self.containers[self.currentContainerIndex].alpha = 1.0
                    self.arrowViews[self.currentContainerIndex].alpha = 1.0
                
            }, completion: { (finished) in
                print("PONYO!!!!!!!!")
                print(finished)
                // Can now run a subsequent animation
                self.ghostFingerTap(whereToTap: CGPoint(x: 21.0, y: 22.3), completion: nil)

            })
        }
    }
    
    //MARK: - Animations
    
    // for tutorial, show a ghosted outline of a finger tap
    func ghostFingerTap (whereToTap: CGPoint, completion: ((Bool)->())?) {
        print(whereToTap)
         //completion?(true)
    }
    
    //MARK: - View Lifecycle
    
    // Pass text info to blurred background VC's
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let bubble = segue.destination as? BlurViewController else {
            return
        }
        
        blurredViews.append(bubble)
        bubble.delegate = self
        
        if segue.identifier == "Blurred1" {
            bubble.textLines = bubbleText1
        } else if segue.identifier == "Blurred2" {
            bubble.textLines = bubbleText2
        } else if segue.identifier == "Blurred3" {
            bubble.textLines = bubbleText3
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer: )))
        view.addGestureRecognizer(tapGesture)
        
        containers[0].alpha = 1.0
        containers[1].alpha = 0.0
        containers[2].alpha = 0.0
        
        //addArrowViews()
        
        /*
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
 */
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addArrowViews()
//        // 0.9 below is only for testing
//        for i in 0 ..< containers.count {
//            arrowStartPoints.append( CGPoint(x: containers[i].center.x * 0.9, y: containers[i].center.y + (containers[i].frame.height * 0.5) ) )
//
//            let arrowView = ArrowView(frame: CGRect(x: 0, y: 0, width: 200, height: 300), startPoint: arrowStartPoints[i], endPoint: arrowEndPoints[i])
//            arrowViews.append(arrowView) // need a ref so visibility can be controlled
//            if i > 0 {
//                arrowViews[i].alpha = 0.0
//            }
//            self.view.addSubview(arrowView)
//        }
    }
    
    func addArrowViews() {
        // 0.9 below is only for testing
        for i in 0 ..< containers.count {
            arrowStartPoints.append( CGPoint(x: containers[i].center.x * 0.9, y: containers[i].center.y + (containers[i].frame.height * 0.5) ) )
            
            let arrowView = ArrowView(frame: CGRect(x: 0, y: 0, width: 200, height: 300), startPoint: arrowStartPoints[i], endPoint: arrowEndPoints[i])
            // set the mask at this higher level - setting the mask directly on the blur view
            // causes an off screen render pass, which loses the blur.
            arrowView.mask = arrowView.getArrowMask()
            arrowViews.append(arrowView) // need a ref so visibility can be controlled
            
            
            if i > 0 {
                arrowViews[i].alpha = 0.0
            }
            self.view.addSubview(arrowView)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        for i in 0 ..< arrowViews.count {
//            arrowViews[i].addArrowMask()
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("Intro De-init")
    }
    
}

extension IntroViewController:ChildToParentProtocol {

    //var arrowStartPoints: [CGPoint]! {get}
    
    func passInfoToParent(with value:CGPoint) {
        print("Hi I am the parent of: \(value.x) and \(value.y)")
        arrowStartPoints.append(value)
    }
}

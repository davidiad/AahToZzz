//
//  BlurViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/5/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//

import UIKit

class BlurViewController: UIViewController {

    //var blurHolder: UIView?
    var blurView: UIVisualEffectView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        var blurEffect: UIBlurEffect
        if #available(iOS 10.0, *) {
            blurEffect = UIBlurEffect(style: .prominent)
        } else {
            blurEffect = UIBlurEffect(style: .light)
        }
        blurView = UIVisualEffectView(effect: nil)
//        blurHolder = UIView()
//        blurHolder?.backgroundColor = UIColor.clear
//        blurHolder?.translatesAutoresizingMaskIntoConstraints = false
        
        guard let blurView = blurView else {
            return
        }
        
//        guard let blurHolder = blurHolder else {
//            return
//        }
        
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
        blurView.layer.masksToBounds = true
        blurView.layer.borderWidth = 1.0
        
        blurView.layer.borderColor = Colors.bluek.cgColor
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.shadowColor = UIColor.black.cgColor
        blurView.layer.shadowOpacity = 1
        blurView.layer.shadowOffset = CGSize.zero
        blurView.layer.shadowRadius = 20
        blurView.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.clear
        //view.insertSubview(blurHolder, at: 0)
        view.insertSubview(blurView, at: 0)
//        NSLayoutConstraint.activate([
//            blurHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            blurHolder.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            blurHolder.topAnchor.constraint(equalTo: view.topAnchor),
//            blurHolder.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//            ])
    
        
        NSLayoutConstraint.activate([
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func viewWillLayoutSubviews() {
//        print("DIM VWLOSV's: ")
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

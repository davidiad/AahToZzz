//
//  IntroViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 5/31/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

import UIKit


class IntroViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bg: UIImageView!
    
    @IBAction func play(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    


    
    var blurView: UIVisualEffectView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bg.layoutIfNeeded()
        bg.layer.cornerRadius = 30.0
        bg.layer.borderWidth = 4.0
        bg.layer.borderColor = Colors.bluek.cgColor
        bg.layer.shadowColor = UIColor.white.cgColor
        bg.layer.shadowOpacity = 1
        bg.layer.shadowOffset = CGSize.zero
        bg.layer.shadowRadius = 9
        bg.layer.masksToBounds = false
        
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
            animator = UIViewPropertyAnimator(duration: 30, curve: .linear) {
                self.blurView?.effect = blurEffect
                animator?.pauseAnimation()
            }
            animator?.startAnimation()
            animator?.fractionComplete = 0.66 // set the amount of bluriness here
        }

        blurView.layer.cornerRadius = 30.0
        blurView.layer.masksToBounds = true
        blurView.layer.borderWidth = 2.0
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bg.layoutIfNeeded()
        bg.layer.cornerRadius = 30.0
        bg.layer.borderWidth = 2.0

        bg.layer.borderColor = UIColor.black.cgColor
        bg.layer.masksToBounds = true
        
        view.isOpaque = false
        
        // blur effect
        bg.backgroundColor = .blue
        bg.isOpaque = false
    
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 30.0
        blurView.layer.borderWidth = 2.0
        blurView.layer.borderColor = Colors.desat_yellow.cgColor
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.shadowColor = UIColor.black.cgColor
        blurView.layer.shadowOpacity = 1
        blurView.layer.shadowOffset = CGSize.zero
        blurView.layer.shadowRadius = 3
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
        //vibrancyView.contentView.addSubview(view)
        blurView.layer.cornerRadius = 30
        blurView.layer.masksToBounds = true
       // blurView.layer.maskedCorners
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

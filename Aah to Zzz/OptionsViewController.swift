//
//  OptionsViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/28/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit

var model = AtoZModel.sharedInstance
var gradient = CAGradientLayer()
let defaultLocation1: CGFloat = 0.0
let defaultLocation2: CGFloat = 0.2
let defaultLocation3: CGFloat = 0.58
let defaultLocation4: CGFloat = 0.97

class OptionsViewController: UIViewController {


    @IBOutlet weak var slider1: GradientSlider!
    @IBOutlet weak var slider2: GradientSlider!
    @IBOutlet weak var slider3: GradientSlider!
    @IBOutlet weak var slider4: GradientSlider!
    
    @IBAction func sliderChanged(sender: AnyObject) {
        model.location1 = CGFloat(slider1.value)
        model.location2 = CGFloat(slider2.value)
        model.location3 = CGFloat(slider3.value)
        model.location4 = CGFloat(slider4.value)
        updateOptionsGradient()
    }
    
    // helper for when sliders are changed, or ResetToDefault button is tapped
    func updateOptionsGradient() {
        for layer in view.layer.sublayers! {
            if let updatedLayer = layer as? CAGradientLayer {
                if updatedLayer.name == "optionsGradientLayer" {
                    updatedLayer.locations![0] = slider1.value
                    updatedLayer.locations![1] = slider2.value
                    updatedLayer.locations![2] = slider3.value
                    updatedLayer.locations![3] = slider4.value
                }
            }
        }
    }
    
    @IBAction func resetToDefaults(sender: AnyObject) {
        setDefaultGradient()
        updateOptionsGradient()
    }

    @IBAction func done(sender: AnyObject) {
        
        let mainGradient = updateGradient(model.location1!, loc2: model.location2!, loc3: model.location3!, loc4: model.location4!)

        mainGradient.frame = view.bounds
        mainGradient.zPosition = -1
        mainGradient.name = "mainGradientLayer"
        presentingViewController?.view.layer.addSublayer(mainGradient)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // helper function for both initial appearance and Reset button
    func setDefaultGradient() {
        slider1.value = defaultLocation1
        slider2.value = defaultLocation2
        slider3.value = defaultLocation3
        slider4.value = defaultLocation4
        model.location1 = CGFloat(slider1.value)
        model.location2 = CGFloat(slider2.value)
        model.location3 = CGFloat(slider3.value)
        model.location4 = CGFloat(slider4.value)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        slider1.thumbColor = UIColor(hue: 0.25, saturation: 0.70, brightness: 0.75, alpha: 1)
        slider1.thumbSize = 48.0
        slider2.thumbColor = UIColor(hue: 0.597, saturation: 0.75, brightness: 1.00, alpha: 1)
        slider2.thumbSize = 48.0
        slider3.thumbColor = UIColor(hue: 0.833, saturation: 0.70, brightness: 0.75, alpha: 1)
        slider3.thumbSize = 48.0
        slider4.thumbColor = UIColor(hue: 0.164, saturation: 1.0, brightness: 1.0, alpha: 1)
        slider4.thumbSize = 48.0
    
        view.backgroundColor = UIColor.clearColor()
        // if 1 is nil, they should all be nil, and vice-versa. But, be safe, check all
        if model.location1 == nil || model.location2 == nil || model.location3 == nil || model.location4 == nil{
            setDefaultGradient()
        } else {
            slider1.value = model.location1!
            slider2.value = model.location2!
            slider3.value = model.location3!
            slider4.value = model.location4!
        }
        
        if model.location1 != nil {
            gradient = updateGradient(model.location1!, loc2: model.location2!, loc3: model.location3!, loc4: model.location4!)
        } else {
            gradient = model.yellowPinkBlueGreenGradient()
        }
        gradient.frame = view.bounds
        
        
        // put the gradient layer *behind* the UIControls made in storyboard
        gradient.zPosition = -1
        gradient.name = "optionsGradientLayer"
        view.layer.addSublayer(gradient)
    }
    
    
    func updateGradient(loc1: CGFloat, loc2: CGFloat, loc3: CGFloat, loc4: CGFloat) -> CAGradientLayer {
        
        let colorOne = UIColor(hue: 0.25, saturation: 0.70, brightness: 0.75, alpha: 1).CGColor as CGColorRef
        let colorTwo = UIColor(hue: 0.597, saturation: 0.75, brightness: 1.00, alpha: 1).CGColor as CGColorRef
        let colorThree = UIColor(hue: 0.833, saturation: 0.70, brightness: 0.75, alpha: 1).CGColor as CGColorRef
        let colorFour = UIColor(hue: 0.164, saturation: 1.0, brightness: 1.0, alpha: 1).CGColor as CGColorRef
        
        let gradientColors: Array <AnyObject> = [colorOne, colorTwo, colorThree, colorFour]
        
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = [loc1, loc2, loc3, loc4]
        
        return gradientLayer
    }

}

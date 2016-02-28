//
//  OptionsViewController.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/28/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import UIKit

var gradient = CAGradientLayer()

class OptionsViewController: UIViewController {

    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.redColor()

        
//        let color1 = UIColor.yellowColor().CGColor as CGColorRef
//        let color2 = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0).CGColor as CGColorRef
//        let color3 = UIColor.clearColor().CGColor as CGColorRef
//        let color4 = UIColor(white: 0.0, alpha: 0.7).CGColor as CGColorRef
//        let colorOne = UIColor(hue: 0.25, saturation: 0.70, brightness: 0.75, alpha: 1).CGColor as CGColorRef // green
//        let colorTwo = UIColor(hue: 0.597, saturation: 0.75, brightness: 1.00, alpha: 1).CGColor as CGColorRef // blue
//        let colorThree = UIColor(hue: 0.833, saturation: 0.70, brightness: 0.75, alpha: 1).CGColor as CGColorRef //magenta
//        let colorFour = UIColor(hue: 0.164, saturation: 1.0, brightness: 1.0, alpha: 1).CGColor as CGColorRef //dark blue
        
        
        gradient = CAGradientLayer.yellowPinkBlueGreenGradient(gradient)()
        gradient.frame = view.bounds
//        gradientLayer.colors = [colorOne, colorTwo, colorThree, colorFour]
//        gradientLayer.frame = view.bounds
//        gradientLayer.yellowPinkBlueGreenGradient()
        //gradient.locations = [0.0, 0.2, 0.58, 0.97]
        
        
        // put the gradient layer *behind* the UIControls made in storyboard
        gradient.zPosition = -1
        view.layer.addSublayer(gradient)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = view.bounds
//        gradientLayer.yellowPinkBlueGreenGradient()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

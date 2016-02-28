//
//  extension-Gradient.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/28/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import Foundation
import UIKit

extension CAGradientLayer {
    
    func yellowPinkBlueGreenGradient() -> CAGradientLayer {
    
        let colorOne = UIColor(hue: 0.25, saturation: 0.70, brightness: 0.75, alpha: 1).CGColor as CGColorRef // green
        let colorTwo = UIColor(hue: 0.597, saturation: 0.75, brightness: 1.00, alpha: 1).CGColor as CGColorRef // blue
        let colorThree = UIColor(hue: 0.833, saturation: 0.70, brightness: 0.75, alpha: 1).CGColor as CGColorRef //magenta
        let colorFour = UIColor(hue: 0.164, saturation: 1.0, brightness: 1.0, alpha: 1).CGColor as CGColorRef //dark blue
    
        let gradientColors: Array <AnyObject> = [colorOne, colorTwo, colorThree, colorFour]
        
    
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = [0.0, 0.2, 0.58, 0.97]
        
        return gradientLayer
    }

    
    func gradientColor(hueValue: CGFloat) -> CAGradientLayer {
        let lightestColor = UIColor(hue: hueValue, saturation: 0.23, brightness: 0.95, alpha: 1)
        let lighterColor = UIColor(hue: hueValue, saturation: 0.33, brightness: 0.925, alpha: 1)
        let darkerColor = UIColor(hue: hueValue, saturation: 0.4, brightness: 0.9, alpha: 1)
        
        let gradientColors: Array <AnyObject> = [lightestColor.CGColor, lighterColor.CGColor, darkerColor.CGColor, lighterColor.CGColor, lightestColor.CGColor]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = [0.0, 0.15, 0.5, 0.85, 1.0]
        
        return gradientLayer
    }
}

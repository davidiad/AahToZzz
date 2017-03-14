//
//  ColorCode.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/24/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import Foundation
import UIKit

struct ColorCode {
//    struct Colors {
//        static let magenta = UIColor(hue: 300/360, saturation: 0.4, brightness: 1.0, alpha: 1.0)
//        static let bluek = UIColor(hue: 200/360, saturation: 0.4, brightness: 1.0, alpha: 1.0)
//        static let green = UIColor(hue: 90/360, saturation: 0.4, brightness: 1.0, alpha: 1.0)
//        static let orange = UIColor(hue: 30/360, saturation: 0.4, brightness: 1.0, alpha: 1.0)
//        static let purple = UIColor(hue: 275/360, saturation: 0.4, brightness: 1.0, alpha: 1.0)
//        static let whitish_red = UIColor(hue: 2/360, saturation: 0.35, brightness: 1.0, alpha: 1.0)
//    }
    
    
    var colorCode: Int? // typically the colorCode is the level, but sometimes there's an override (red/-1 when filling in the blanks, gray/-2 when inactive)
    //var tile_bg: UIImage?
    //var outline: UIImage?
    //var tint: UIColor
    
    private init() {
        //tint = UIColor.yellowColor()
        // other property values default to nil
    }
    
    init(code: Int) {
        colorCode = code
    }
    
    lazy var tile_bg: UIImage? = {
        var image = UIImage()
        
        if let colorCode = self.colorCode {
                
                let tintLevel = colorCode % 6
                
                switch tintLevel {
                case -2:
                    image = UIImage(named: "small_tile_gray")! // the word is inactive
                case -1:
                    image = UIImage(named: "small_tile_red")! // the word hadn't been found, and player tapped FillInTheBlanks
                case 0:
                    image = UIImage(named: "small_tile_yellow")!
                case 1:
                    image = UIImage(named: "small_tile_magenta")!
                case 2:
                    image = UIImage(named: "small_tile_blue_kimba")!
                case 3:
                    image = UIImage(named: "small_tile_green")!
                case 4:
                    image = UIImage(named: "small_tile_orange")!
                case 5:
                    image = UIImage(named: "small_tile_purple")!
                default:
                    image = UIImage(named: "small_tile_yellow")!
                    break
                }
            }
        //}
        return image
    }()
    
    // set the tint color for the outlines, etc
    lazy var tint: UIColor? = {
        if let colorCode = self.colorCode {
            
//            if colorCode == -1 {
//                return Colors.whitish_red
//            }
            
            let tintLevel = colorCode % 6
            
            switch tintLevel {
            case -2:
                return Colors.gray_text
            case -1:
                return Colors.whitish_red
            case 0:
                return UIColor.yellowColor()
            case 1:
                return Colors.magenta
            case 2:
                return Colors.bluek
            case 3:
                return Colors.green
            case 4:
                return Colors.orange
            case 5:
                return Colors.purple
            default:
                return UIColor.yellowColor()
            }
        }
        return UIColor.yellowColor()
    }()

    // set which image to use for outline
    lazy var outline: UIImage? = {
        var image = UIImage()

        if self.colorCode != nil {
            switch self.colorCode! {
            case 0...5:
                image = UIImage(named: "outline_thick")!
                //return nil
            case 6...10:
                image = UIImage(named: "outline_double_unstretched")!
            case 11...15:
                image = UIImage(named: "outline_thicker")!
            //TODO: Implement tripled lines (tripled lines too close)
            default:
                image = UIImage(named: "outline_thick")!
            }
        }
        return image
    }()
    
    // set which image to use for outline
    lazy var shadow: UIImage? = {
        var image = UIImage()
        
        if self.colorCode != nil {
            switch self.colorCode! {
            case 0...5:
                image = UIImage(named: "outline_yellow")!
            //return nil
            case 6...10:
                image = UIImage(named: "outline_shadow_unstretched")!
            case 11...15:
                image = UIImage(named: "outline_shadow_unstretched")!
            //TODO: Implement tripled lines (tripled lines too close) - Use Double line with colored center
            default:
                image = UIImage(named: "outline_yellow")! // thin outline, can be tinted other colors
            }
        }
        return image
    }()
}


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
    
    var colorCode: Int? // typically the colorCode is the level, but sometimes there's an override (red/-1 when filling in the blanks, gray/-2 when inactive)
    
    fileprivate init() {
        //tint = UIColor.yellowColor()
        // other property values default to nil
    }
    
    init(code: Int) {
        colorCode = code
    }
    
    lazy var tile_bg: UIImage? = {
        var image = UIImage()
        
        if let colorCode = self.colorCode {
                
                let tintLevel = colorCode % 5
                
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
            
            let tintLevel = colorCode % 5
            
            switch tintLevel {
            case -2:
                return Colors.gray_text
            case -1:
                return Colors.whitish_red
            case 0:
                return UIColor.yellow
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
                return UIColor.yellow
            }
        }
        return UIColor.yellow
    }()
    
    // set a saturated color, to be used as an accent for tripled lines
    lazy var saturatedColor: UIColor? = {
        if let colorCode = self.colorCode {
            
            let tintLevel = colorCode % 5
            
            switch tintLevel {

            case 0:
                return Colors.sat_yellow // already saturated, so desaturate
            case 1:
                return Colors.sat_magenta
            case 2:
                return Colors.sat_blue
            case 3:
                return Colors.sat_green
            case 4:
                return Colors.sat_orange
            case 5:
                return Colors.sat_purple
            default:
                return UIColor.yellow
            }
        }
        return UIColor.yellow
    }()

    // set which image to use for outline
    lazy var outline: UIImage? = {
        var image = UIImage()

        if self.colorCode != nil {
            switch self.colorCode! {
            case 0...4:
                image = UIImage(named: "word_outline_single")! // regular single thickness
                //return nil
            case 5...9:
                image = UIImage(named: "word_outline_double")!
            case 10...14:
                image = UIImage(named: "word_outline_double_triple")! // doubled outline, with inner line slightly thicker to compensate for the inner stripe covering part of it
            case 15...19:
                image = UIImage(named: "outline_thicker")!
            default:
                image = UIImage(named: "outline_thicker")!
            }
        }
        return image
    }()
    
    // Only for the tripled outline, set the image for the inner stripe
    lazy var tripleStripe: UIImage? = {
        var image = UIImage()
        
        if self.colorCode != nil {
            switch self.colorCode! {
            case 10...14:
                image = UIImage(named: "word_outline_triple")!
                
            default:
                return nil
            }
        }
        return image
    }()
    
    // set which image to use for outline
    lazy var shadow: UIImage? = {
        var image = UIImage()
        
        if self.colorCode != nil {
            switch self.colorCode! {
            case 0...4:
                image = UIImage(named: "outline_yellow")!
            //return nil
            case 5...9:
                image = UIImage(named: "outline_shadow_unstretched")!
            case 10...14:
                image = UIImage(named: "outline_shadow_unstretched")!
            case 15...19:
                image = UIImage(named: "outline_shadow_unstretched")!
            default:
                //image = UIImage(named: "outline_yellow")! // thin outline, can be tinted other colors
                image = UIImage(named: "outline_shadow_unstretched")!

            }
        }
        return image
    }()
}


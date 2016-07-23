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
    struct Colors {
        static let magenta = UIColor(hue: 300/360, saturation: 0.4, brightness: 1.0, alpha: 1.0)
        static let bluek = UIColor(hue: 200/360, saturation: 0.4, brightness: 1.0, alpha: 1.0)
        static let green = UIColor(hue: 90/360, saturation: 0.4, brightness: 1.0, alpha: 1.0)
        static let orange = UIColor(hue: 30/360, saturation: 0.4, brightness: 1.0, alpha: 1.0)
        static let purple = UIColor(hue: 275/360, saturation: 0.4, brightness: 1.0, alpha: 1.0)
        static let whitish_red = UIColor(hue: 2/360, saturation: 0.35, brightness: 1.0, alpha: 1.0)
    }
    
    var level: Int?
    //var tile_bg: UIImage?
    //var outline: UIImage?
    //var tint: UIColor
    
    private init() {
        //tint = UIColor.yellowColor()
        // other property values default to nil
    }
    
    init(code: Int) {
        level = code
        //tint = UIColor.yellowColor()
    }
    
    lazy var tile_bg: UIImage? = {
        var image = UIImage()
        
        if let level = self.level {
            if level == -1 {
                image = UIImage(named: "small_tile_red")!
            } else {
                let tintLevel = level % 4
                
                switch tintLevel {
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
                    print("hit default: \(self.level)")
                    break
                }
            }
        }
        return image
    }()
    
    lazy var tint: UIColor? = {
        if let level = self.level {
            
            if level == -1 {
                return Colors.whitish_red
            }
            
            let tintLevel = level % 4
            
            switch tintLevel {
            case 0:
                return UIColor.yellowColor()
            case 1:
                return Colors.magenta
            case 2:
                return Colors.bluek
            case 3:
                return Colors.green
//            case 4:
//                return Colors.orange
//            case 5:
//                return Colors.purple
            default:
                return UIColor.yellowColor()
            }
        }
        return UIColor.yellowColor()
    }()

    
    lazy var outline: UIImage? = {
        var image = UIImage()

        if self.level != nil {
            switch self.level! {
            case 0:
                //image = UIImage(named: "outline_thick")!
                return nil
                
            case 1:
                image = UIImage(named: "outline_double")!
            //TODO: Implement tripled lines (tripled lines too close)
            default:
                image = UIImage(named: "outline_yellow")! // thin outline, can be tinted other colors
            }
        }
        return image
    }()
}


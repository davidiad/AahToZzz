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
    var level: Int?
    //var tile_bg: UIImage?
    //var outline: UIImage?
    
    private init() {
        // property values default to nil
    }
    
    init(code: Int) {
        level = code
    }
    
    lazy var tile_bg: UIImage? = {
        var image = UIImage()
        switch self.level! {
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
            print("hit default: \(self.level)")
            break
        }
        return image
    }()
    
    lazy var outline: UIImage? = {
        var image = UIImage()
        switch self.level! {
        case 0:
            image = UIImage(named: "outline_yellow")!
        default:
            break
        }
        return image
    }()
    
}


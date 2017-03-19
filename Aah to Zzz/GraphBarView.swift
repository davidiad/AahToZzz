//
//  GraphBarView.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/17/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

import UIKit

class GraphBarView: UIView {
    
    let WIDTH: Float = 32.0
    
    var level: Int?
    var graphHeight: CGFloat?
    var colorCode: ColorCode?
    var isEmpty: Bool?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    init(frame: CGRect, level: Int, graphHeight: CGFloat, isEmpty: Bool) {
        super.init(frame: frame)
        
        self.graphHeight = graphHeight
        self.isEmpty = isEmpty
        
        colorCode = ColorCode(code: level - 1)
        translatesAutoresizingMaskIntoConstraints = false
        
        // create mask to round the corners of the graph bar
        let mask: UIView = UIView(frame: frame)
        let maskImageView = UIImageView(frame: frame)
        maskImageView.image = UIImage(named: "bar_graph_mask")
        mask.addSubview(maskImageView)
        maskView = mask
        
        // TODO:-set the background color per level
        let bg_image = UIImage(named:"graph_bg")
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        bg_image!.resizableImageWithCapInsets(insets, resizingMode: .Tile)
        backgroundColor = UIColor(patternImage: bg_image!)
        
        // create the outline view
        let outlineView = UIImageView(frame: frame)
        let outlineShadowView: UIImageView = UIImageView()
        // Triple the line by making the inside a different color
        // Will only be added on levels > 10
        let outlineTripleView: UIImageView = UIImageView()
        let outlineShadowImageSingle = UIImage(named: "outline_shadow_single")
        let outlineShadowImageDouble = UIImage(named: "outline_shadow")
        let outlineImageTriple = UIImage(named: "outline_triple")
        
        // Add the outline image on top of the level bar table controller
        // first, the shadow image beneath to help the outline stand out

        
        outlineShadowView.alpha = 0.5
        outlineShadowView.frame = frame
        outlineTripleView.frame = frame
        
        // TODO:- specify cases more clearly. 0 words vs. height is small enough that the rounded top doesn't fit without squishing
        
        // if graph height is short, don't want to stretch the images, instead clip them without stretching (as in .BottomLeft)
        if graphHeight < 22.0 || isEmpty {
            outlineView.image = UIImage(named: "outline_graph_double_unstretched")
            outlineView.contentMode = .BottomLeft
        } else {
            
            switch level {
            case -1...5:
                
//                if graphHeight < 22.0 || isEmpty {
//                    outlineView.image = UIImage(named: "outline_graph_double_unstretched")
//                    outlineView.contentMode = .BottomLeft
//                } else {
                    outlineView.image = UIImage(named: "outline_single_flatbottom")
                    outlineShadowView.image = outlineShadowImageSingle
             //   }
            case 6...10:
                
//                if graphHeight < 22.0 || isEmpty {
//                    outlineView.image = UIImage(named: "outline_graph_double_unstretched")
//                    outlineView.contentMode = .BottomLeft
//                } else {
                    outlineView.image = UIImage(named: "outline_double_flatbottom")
                    outlineShadowView.image = outlineShadowImageDouble
               // }
            case 11...15:
                
//                if graphHeight < 22.0 || isEmpty {
//                    outlineView.image = UIImage(named: "outline_graph_double_unstretched")
//                    outlineView.contentMode = .BottomLeft
//                } else {
                    outlineView.image = UIImage(named: "outline_double_flatbottom")
                    outlineShadowView.image = outlineShadowImageDouble
                    // the tripled image is a contrasting color
                    outlineTripleView.image = outlineImageTriple
            //    }
            default:
                
                outlineView.image = UIImage(named: "outline_double_flatbottom")
                outlineShadowView.image = outlineShadowImageDouble
                // the tripled image is the same color, making it one thick line
                outlineTripleView.image = outlineImageTriple
                
            }
        }
        outlineView.frame = frame
        outlineView.image = outlineView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        // set the outlineView tintcolor per level
        guard let tintColor = colorCode?.tint else {
            return
        }
        outlineView.tintColor = tintColor  //colorCode.tint // Why not finding the .tint property in ColorCode?

        addSubview(outlineShadowView)
        addSubview(outlineView)
        
        if let tripleImage = outlineTripleView.image {
            outlineTripleView.image = tripleImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            addSubview(outlineTripleView)
            var colorCodeTriple: ColorCode? = ColorCode(code: level + 2)
            guard let tripleTintColor = colorCodeTriple?.tint else {
                return
            }
            outlineTripleView.tintColor = tripleTintColor
            
        }
        
        
        // make sure the shadow and outline are above the LevelTableView
        outlineShadowView.layer.zPosition   = 1000
        outlineView.layer.zPosition         = 1001
        outlineTripleView.layer.zPosition   = 1002
    }
    
    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    // make a custom init that reads in the height, and the level
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

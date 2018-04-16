//
//  LinePropertyStyles.swift
//  AahToZzz
//
//  Created by David Fierstein on 4/16/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//
import UIKit

struct LineProperties {
    var lineWidth:  CGFloat
    var color:      UIColor
}

struct LinePropertyStyles {
    
    // Standard frosted edge, works well with partial blur view
    static let frosted: [LineProperties] = [
        LineProperties(lineWidth: 11.0,  color: Colors.veryLight),
        LineProperties(lineWidth: 8.5,   color: Colors.veryLight),
        LineProperties(lineWidth: 5.5,   color: Colors.lightBackground),
        LineProperties(lineWidth: 2.25,  color: .white),
        LineProperties(lineWidth: 1.5,   color: Colors.darkBackground)]
    
    // Use for button: Highlight outside dark line gives a sunk into the screen look
    static let frostedEdgeHighlight: [LineProperties] = [
        LineProperties(lineWidth: 15.5,  color: Colors.veryLight),
        LineProperties(lineWidth: 13.0,  color: Colors.veryLight),
        LineProperties(lineWidth: 10.0,  color: Colors.lightBackground),
        LineProperties(lineWidth: 6.75,  color: .white),
        LineProperties(lineWidth: 6.0,   color: Colors.darkBackground),
        LineProperties(lineWidth: 3.0,   color: Colors.light_yellow)]
}



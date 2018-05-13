//
//  Directions.swift
//  AahToZzz
//
//  Created by David Fierstein on 4/14/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//
import UIKit

enum Directions:        Int { case right, down, left, up }
enum ShapeType:         Int { case arrow, curvedArrow, triangle, tileholder } // not needed?
enum ArrowType:         Int { case curved, straight, pointer }
enum BubbleType:        Int { case none, rectangle, quadcurve }
enum ArrowDirection:    Int { case up, down, upright, downright, upleft, downleft }

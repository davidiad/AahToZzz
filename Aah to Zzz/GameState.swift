//
//  GameState.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/13/18.
//  Copyright © 2018 David Fierstein. All rights reserved.
//
import Foundation

@objc enum GameState: Int {
    case firstTime            = 0
    case playingThreeLetter   = 1
    case home                 = 2
    case tutorial             = 3
    case statsGraph           = 4
    case firstTimePlaying     = 5
}

//
//  GameType.swift
//  AahToZzz
//
//  Created by David Fierstein on 1/24/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

import Foundation

@objc enum GameType: Int {
    case twoLetterWords     = 0
    case threeLetterWords   = 1
    case jqxz               = 2
    case sevenLetterWords   = 3
    case eightLetterWords   = 4
    case nineLetterWords    = 5
}

// TODO: link this enum/struct to Game managed object
// move dictionaryName property from GameData to Game

// TODO:-- make this a struct, so can have stored properties

//TODO:-- make the enum map to integer for persisting in core data
//TODO:-- add other properties for each type
// lengthOfWords
// deviceOrientation
// which dictionary(s) to use (So dictionary property should be an array of Strings, corresponding to the file name for the dictionary)

// unique rules for the game, such as mix of letters to use

// Question: if you create a struct that goes with the game, does it need to be created just once? each time game is loaded??

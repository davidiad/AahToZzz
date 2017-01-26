//
//  GameType.swift
//  AahToZzz
//
//  Created by David Fierstein on 1/24/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

import Foundation

enum GameType: Int {
    case TwoLetterWords = 0
    case ThreeLetterWords = 1
    case JQXZ = 2
    case SevenLetterWords = 3
    case EightLetterWords = 4
    case NineLetterWords = 5
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

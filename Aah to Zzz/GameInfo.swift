//
//  GameInfo.swift
//  AahToZzz
//
//  Created by David Fierstein on 1/25/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

import Foundation

enum Orientation {
    
    case Portrait
    case Landscape
}

// add others as they are created
enum DictionaryName: String {
    case OSPD5_2letter = "OSPD5_2letter"
    case OSPD5_3letter = "OSPD5_3letter"
    case OSPD5_7letter = "OSPD5_7letter"
    case OSPD5_8letter = "OSPD5_8letter"
    case OSPD5_9letter = "OSPD5_9letter"
    case OSPD5_JQXZ = "OSPD5_JQXZ"
    case threeletterwordlist = "3letterwordlist"
}

struct GameInfo {
    
    var type: GameType?
    var lengthOfWords: Int?
    var numberOfTiles: Int?
    var letterMix: String?
    var deviceOrientation: Orientation?
    // each game has a list of possible dictionaries to choose from. May be just one, or several. Which one is chosen should be persisted in the GameData object
    var dictionaries: [String]?
    
    var numberOfPositions: Int?
    
    // for reference
//    enum GameType: Int {
//        case TwoLetterWords = 0
//        case ThreeLetterWords = 1
//        case JQXZ = 2
//        case SevenLetterWords = 3
//        case EightLetterWords = 4
//        case NineLetterWords = 5
//    }
    
    
    init() {
        
    }
    
    init(gameType: GameType.RawValue) {
        // use switch case
        switch gameType {
        case 0 :
            lengthOfWords = 2
            numberOfTiles = 7
            letterMix = "AAABCDEEEFGHIIIJKLMNOOOPQRSTUUVWXYZ"
            deviceOrientation = Orientation.Portrait
            dictionaries = [DictionaryName.OSPD5_2letter.rawValue] // need to create this wordlist
            
        case 1 :
            lengthOfWords = 3
            numberOfTiles = 7
            letterMix = "AAABCDEEEFGHIIIJKLMNOOOPQRSTUUVWXYZ"
            deviceOrientation = Orientation.Portrait
            dictionaries = [DictionaryName.OSPD5_3letter.rawValue]
            
        case 2:
            lengthOfWords = nil // variable. Should set to max length?
            numberOfTiles = 7 // may be more
            letterMix = "AAABCDEEEFGHIIIJJJKLMNOOOPQQQRSTUUUUVWXXXYZZZ" // added extra J's, Q's, U's, X's, and Z's
            deviceOrientation = Orientation.Landscape
            dictionaries = [DictionaryName.OSPD5_JQXZ.rawValue] // need to create this wordlist
         
        case 3:
            lengthOfWords = 7
            numberOfTiles = 7 // may be more
            letterMix = "AAABCDEEEFGHIIIJKLMNOOOPQRSTUUVWXYZ"
            deviceOrientation = Orientation.Landscape
            dictionaries = [DictionaryName.OSPD5_7letter.rawValue] // need to create this wordlist
            
        case 4:
            lengthOfWords = 8
            numberOfTiles = 8 // may be more
            letterMix = "AAABCDEEEFGHIIIJKLMNOOOPQRSTUUVWXYZ"
            deviceOrientation = Orientation.Landscape
            dictionaries = [DictionaryName.OSPD5_8letter.rawValue] // need to create this wordlist
            
        case 5:
            lengthOfWords = 9
            numberOfTiles = 9 // may be more
            letterMix = "AAABCDEEEFGHIIIJKLMNOOOPQRSTUUVWXYZ"
            deviceOrientation = Orientation.Landscape
            dictionaries = [DictionaryName.OSPD5_9letter.rawValue] // need to create this wordlist
            
        default :
            lengthOfWords = 3
            numberOfTiles = 7
            letterMix = "AAABCDEEEFGHIIIJKLMNOOOPQRSTUUVWXYZ"
            deviceOrientation = Orientation.Portrait
            dictionaries = [DictionaryName.OSPD5_3letter.rawValue]
        }
        
        guard let lOW = lengthOfWords, nOT = numberOfTiles else { // find better var names?
            numberOfPositions = 10 // default value
            return
        }
        
        numberOfPositions = lOW + nOT
    }
    

}



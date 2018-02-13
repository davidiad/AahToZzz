//
//  GameTypeInfo.swift
//  AahToZzz
//
//  Created by David Fierstein on 1/25/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

// Works with GameType. Sets the basic game info that corresponds to each type. And each
// Game has its GameType saved in the Game managed object.


enum Orientation {
    
    case portrait
    case landscape
}

// Word lists to put in the dictionary. add others as they are created
enum DictionaryName: String {
    case two = "OSPD5_2letter"
    case three = "OSPD5_3letter"
    case seven = "OSPD5_7letter"
    case eight = "OSPD5_8letter"
    case nine = "OSPD5_9letter"
    case jqxz = "OSPD5_JQXZ"
    case threeletterwordlist = "3letterwordlist"
}

struct GameTypeInfo {
    
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
//        case TwoLetterWords   = 0
//        case ThreeLetterWords = 1
//        case JQXZ             = 2
//        case SevenLetterWords = 3
//        case EightLetterWords = 4
//        case NineLetterWords  = 5
//    }
    
    
    init() {
        
    }
    
    init(gameType: GameType) { //GameType.RawValue) {
        
        self.type = gameType
        
        guard let typeCase = self.type?.rawValue else {
            return
        }
        switch typeCase {
        case 0 :
            lengthOfWords = 2
            numberOfTiles = 7
            letterMix = "AAABCDEEEFGHIIIJKLMNOOOPQRSTUUVWXYZ"
            deviceOrientation = Orientation.portrait
            dictionaries = [DictionaryName.two.rawValue] // need to create this wordlist
            
        case 1 :
            lengthOfWords = 3
            numberOfTiles = 7
            letterMix = "AAABCDEEEFGHIIIJKLMNOOOPQRSTUUVWXYZ"
            deviceOrientation = Orientation.portrait
            dictionaries = [DictionaryName.three.rawValue]
            
        case 2:
            lengthOfWords = nil // variable. Should set to max length?
            numberOfTiles = 7 // may be more
            letterMix = "AAABCDEEEFGHIIIJJJKLMNOOOPQQQRSTUUUUVWXXXYZZZ" // added extra J's, Q's, U's, X's, and Z's
            deviceOrientation = Orientation.landscape
            dictionaries = [DictionaryName.jqxz.rawValue] // need to create this wordlist
         
        case 3:
            lengthOfWords = 7
            numberOfTiles = 7 // may be more
            letterMix = "AAABCDEEEFGHIIIJKLMNOOOPQRSTUUVWXYZ"
            deviceOrientation = Orientation.landscape
            dictionaries = [DictionaryName.seven.rawValue] // need to create this wordlist
            
        case 4:
            lengthOfWords = 8
            numberOfTiles = 8 // may be more
            letterMix = "AAABCDEEEFGHIIIJKLMNOOOPQRSTUUVWXYZ"
            deviceOrientation = Orientation.landscape
            dictionaries = [DictionaryName.eight.rawValue] // need to create this wordlist
            
        case 5:
            lengthOfWords = 9
            numberOfTiles = 9 // may be more
            letterMix = "AAABCDEEEFGHIIIJKLMNOOOPQRSTUUVWXYZ"
            deviceOrientation = Orientation.landscape
            dictionaries = [DictionaryName.nine.rawValue] // need to create this wordlist
            
        default :
            lengthOfWords = 3
            numberOfTiles = 7
            letterMix = "AAABCDEEEFGHIIIJKLMNOOOPQRSTUUVWXYZ"
            deviceOrientation = Orientation.portrait
            dictionaries = [DictionaryName.three.rawValue]
        }
        
        guard let lOW = lengthOfWords, let nOT = numberOfTiles else { // find better var names?
            numberOfPositions = 10 // default value
            return
        }
        
        numberOfPositions = lOW + nOT
    }
    

}



//
//  GameInfo.swift
//  AahToZzz
//
//  Created by David Fierstein on 1/25/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

import Foundation

enum orientation {
    
    case Portrait
    case Landscape
}

struct GameInfo {
    
    var type: GameType?
    var letterMix: String?
    var lengthOfWords: Int?
    var numberOfTiles: Int?
    var deviceOrientation: orientation?
    
    // each game has a list of possible dictionaries to choose from. May be just one, or several. Which one is chosen should be persisted in the GameData object
    var dictionaries: [String]?
    
    
    init() {
        
    }
    
    init(type: GameType) {
        // use switch case
    }

}

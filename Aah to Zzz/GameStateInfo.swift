//
//  GameStateInfo.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/13/18.
//  Copyright © 2018 David Fierstein. All rights reserved.


// Works with GameState. Each
// Game has its GameState saved in the GameData managed object.
// Not yet in use, but
// could be used for info such as which game or view controller was last open when the game was last opened
// or any other game state info

struct GameStateInfo {
    
    var state: GameState?
    var viewController: String?
    var screenshotPath: String?
    
//    for reference
//    @objc enum GameState: Int {
//        case playingTwoLetter     = 0
//        case playingThreeLetter   = 1
//        case home                 = 2
//        case tutorial             = 3
//        case statsGraph           = 4
//        case firstTimePlaying     = 5
//    }
    
    init() {
        
    }
    
    init(gameState: GameState) {
        
        self.state = gameState
        
        guard let stateCase = self.state?.rawValue else {
            return
        }
        
        // Dummy info for now
        switch stateCase {
        case 0 :
            viewController = "playing2"
            screenshotPath = "somePath"
        case 1 :
            viewController = "playing2"
            screenshotPath = "somePath"
            
        case 2:
            viewController = "playing2"
            screenshotPath = "somePath"
            
        case 3:
            viewController = "playing2"
            screenshotPath = "somePath"
            
        case 4:
            viewController = "playing2"
            screenshotPath = "somePath"
            
        case 5:
            viewController = "playing2"
            screenshotPath = "somePath"
            
        default :
            viewController = "playing2"
            screenshotPath = "somePath"
        }
        
    }
    
}




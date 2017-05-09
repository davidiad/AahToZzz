//
//  Word.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/24/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import Foundation
import CoreData


class Word: NSManagedObject {

    @NSManaged var word: String?
    @NSManaged var inCurrentList: Bool
    @NSManaged var found: Bool
    @NSManaged var active: Bool // frequently found words will sometimes be set to inactive, meaning the game fills the word automatically, the word is greyed out, and neither adds nor subtracts from the score.
    @NSManaged var numTimesPlayed: Int16
    @NSManaged var numTimesFound: Int16 // should never go below 0, so player doesn't get into a huge hole
    @NSManaged var letterlist: LetterSet? // should really (in the future) allow many letterlist's to each word
    @NSManaged var game: GameData?
    
    //TODO: don't let diff between times found and times played to get too negative
    
    var gameLevel: Int {
        get {
            return Int((game?.level)!)
        }
    }
    
    
    //TODO:- add mastered var, based on numTimesFound. Add masteryLevel(Int) to GameData, which can be changed automatically, or as an option, later, the player can set.
    var level: Int {
        get {
            let checkLevel = 2 * Int(numTimesFound) - Int(numTimesPlayed)
            if checkLevel > gameLevel { // should keep the words level from ever going below the games level
                return checkLevel
            } else {
                return gameLevel
            }
        }
    }
    
    var mastered: Bool {
        get {
            let masteryLevel = 1 // TODO:- Set this for entire game
            if level >= masteryLevel {
                return true
            } else {
                return false
            }
        }
        
    }
    
    // standard Core Data init method.
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(wordString: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Word", in: context)!
        
        super.init(entity: entity,insertInto: context)
        
        word = wordString

        inCurrentList = false // by default, not in the current list
        found = false // when a word is first created, it has not yet been found
        numTimesPlayed = 0
        numTimesFound = 0
        active = true // active by default. Only inactive when word has been mastered, under the inactive quota
        // letterlist will be nil by default
                

    }
}

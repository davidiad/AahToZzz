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
    @NSManaged var numTimesPlayed: Int16
    @NSManaged var numTimesFound: Int16 // should never go below 0, so player doesn't get into a huge hole
    @NSManaged var letterlist: LetterSet? // should really (in the future) allow many letterlist's to each word
    @NSManaged var game: GameData?
    
    //TODO: don't let diff between times found and times played to get too negative
    
    //TODO:- add mastered var, based on numTimesFound. Add masteryLevel(Int) to GameData, which can be changed automatically, or as an option, later, the player can set.
    
    var level: Int {
        get {
            let checkLevel = 2 * Int(numTimesFound) - Int(numTimesPlayed)
            if checkLevel > 0 {
                return checkLevel
            } else {
                return 0
            }
        }
    }
    
    var mastered: Bool {
        get {
            let masteryLevel = 3 // TODO:- Set this for entire game
            if level >= masteryLevel {
                return true
            } else {
                return false
            }
        }
        
    }
    
    // standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(wordString: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Word", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        word = wordString

        inCurrentList = false // by default, not in the current list
        found = false // when a word is first created, it has not yet been found
        numTimesPlayed = 0
        numTimesFound = 0
        // letterlist will be nil by default
                

    }
}

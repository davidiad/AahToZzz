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
    @NSManaged var numTimesFound: Int16
    @NSManaged var letterlist: LetterSet? // should really (in the future) allow many letterlist's to each word
    @NSManaged var game: GameData? 
    
    // standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(wordString: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Word", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        word = wordString

        inCurrentList = false // by default, not in the current list
        found = false // when a word is first created, it has no yet been found
        numTimesPlayed = 0
        numTimesFound = 0
        // letterlist will be nil by default
    }
}

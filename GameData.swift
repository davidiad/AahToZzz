//
//  GameData.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/21/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import Foundation
import CoreData


class GameData: NSManagedObject {
    
    @NSManaged var isCurrentGame: Bool
    @NSManaged var currentLetterSetID: String?
    @NSManaged var name: String? // since the name could be changed, put in GameData rather than Game
    @NSManaged var level: Int16
    @NSManaged var masteryLevel: Int16
    @NSManaged var masteryLevelManual: Bool // when true, the mastery level set by the user is used. When false, it's automatic
    @NSManaged var positions: NSSet?
    @NSManaged var lettersets: NSSet?
    @NSManaged var words: NSSet?
    @NSManaged var currentLetterSet: NSManagedObject? // alternate way of finding the current letter set, besides using the ID
    @NSManaged var game: Game?
    
    // standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("GameData", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        // moved gameName to Game object
//        if let gameName = dictionary["name"] as? String {
//            name = gameName
//        }
        
        masteryLevel = 3 // default value
        
        // add the default dictionaryname for the GameType
    }
    
    //TODO:- add an init that accepts a dictionary name

}

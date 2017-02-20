//
//  Game.swift
//  AahToZzz
//
//  Created by David Fierstein on 1/25/17.
//  Copyright © 2017 David Fierstein. All rights reserved.
//

import Foundation
import CoreData

class Game: NSManagedObject {
    
    //TODO: use URI to get ID for game?
    /*
    let lettersetURI = NSURL(string: (game?.data?.currentLetterSetID)!)
    let id = sharedContext.persistentStoreCoordinator?.managedObjectIDForURIRepresentation(lettersetURI!)
    */
    
    @NSManaged var gameID: String? // ID using URI representation
    @NSManaged var dictionaryName: String? // since this won't change, put in Game rather than GameData
    @NSManaged private var gameType: NSNumber?
    @NSManaged var data: GameData?
    
    // convert enum to int value (saved in Core Data) and vice-versa
    var gameTypeSet: GameType {
        get {
            return GameType(rawValue: self.gameType!.integerValue)!
        }
        set {
            self.gameType = newValue.rawValue
        }
    }
    
    // standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Game", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
    }
    
    //TODO: move dictionaryName property here, from GameData object
    // and possibly move positions property here as well. Makes more sense logically, since the positions are set but once per game, but may make the code simpler to keep in GameData.
    
}

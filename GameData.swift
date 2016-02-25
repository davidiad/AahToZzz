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

    @NSManaged var currentLetterSetID: String?
    @NSManaged var gameID: String?
    @NSManaged var name: String?
    @NSManaged var lettersets: NSSet?
    @NSManaged var words: NSSet?
    @NSManaged var currentLetterSet: NSManagedObject? // alternate way of finding the current letter set, besides using the ID
    
    // standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("GameData", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        if let gameName = dictionary["name"] as? String {
            name = gameName
        }
    }

}

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
    
    @NSManaged var gameID: NSNumber?
    @NSManaged var name: String?
    @NSManaged var gameType: NSNumber?
    @NSManaged var data: GameData?
    
    // standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
}

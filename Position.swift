//
//  Position.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/5/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import Foundation
import CoreData


class Position: NSManagedObject {

    @NSManaged var index: Int16
    @NSManaged var xPos: Float
    @NSManaged var yPos: Float
    @NSManaged var occupied: Bool
    @NSManaged var letter: Letter?
    @NSManaged var game: GameData?
    
    // standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        occupied = false // not occupied by default
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Position", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        occupied = false // not occupied by default
        
        //to add values from dictionary
//        if let gameName = dictionary["game"] as? String {
//            name = gameName
//        }
    }

}

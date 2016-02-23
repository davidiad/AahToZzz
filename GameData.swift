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

    @NSManaged var currentLetterSetID: NSNumber?
    @NSManaged var gameID: NSNumber?
    @NSManaged var name: String?
    @NSManaged var lettersets: NSSet?
    
    // standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("GameData", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        //searchString = dictionary[searchString!] as? String
        //lon = dictionary[Keys.Lon] as? NSNumber
    }

}

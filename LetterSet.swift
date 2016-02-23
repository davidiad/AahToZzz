//
//  LetterSet.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/21/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import Foundation
import CoreData


class LetterSet: NSManagedObject {
    
    @NSManaged var letterSetID: NSNumber?
    @NSManaged var name: String? //TODO: do we need a name for each LetterSet?
    @NSManaged var letters: NSSet?
    @NSManaged var game: NSManagedObject?

    // standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("LetterSet", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        //searchString = dictionary[searchString!] as? String
        //lon = dictionary[Keys.Lon] as? NSNumber
    }
}

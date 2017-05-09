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
    
    @NSManaged var letterSetID: String? // ID using URI representation
    @NSManaged var name: String? 
    @NSManaged var letters: NSSet?
    @NSManaged var game: NSManagedObject?
    @NSManaged var currentGame: NSManagedObject?
    
    // standard Core Data init method.
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "LetterSet", in: context)!
        
        super.init(entity: entity,insertInto: context)

    }
}

//
//  Letter.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/21/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import Foundation
import CoreData

class Letter: NSManagedObject {
    
    @NSManaged var index: Int16
    @NSManaged var letter: String?
    @NSManaged var letterset: LetterSet? //TODO: should this be NSManagedObject?
    @NSManaged var position: Position?
    
    // standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Letter", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)

    }
    
    init(someLetter: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Letter", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        letter = someLetter
    }


}

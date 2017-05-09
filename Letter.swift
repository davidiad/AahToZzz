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
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Letter", in: context)!
        
        super.init(entity: entity,insertInto: context)

    }
    
    init(someLetter: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Letter", in: context)!
        
        super.init(entity: entity,insertInto: context)
        
        letter = someLetter
    }


}

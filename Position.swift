//
//  Position.swift
//  AahToZzz
//
//  Created by David Fierstein on 3/5/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//

import Foundation
import CoreData
import UIKit // needed to use CGPoint

class Position: NSManagedObject {

    @NSManaged var index: Int16
    @NSManaged var xPos: Float
    @NSManaged var yPos: Float
    //@NSManaged var occupied: Bool
    @NSManaged var letter: Letter?
    @NSManaged var game: GameData?
    
    // only change xPos and yPos, which then will update position. Not vice-versa.
    lazy var position: CGPoint = {
        CGPointMake(CGFloat(self.xPos), CGFloat(self.yPos)) // need ref to self in lazy var
    }()
    
    // no need to track 'occupied' as a separate bool. If there is a letter, occupied is true. Otherwise, false.
    lazy var occupied: Bool = {
        self.letter != nil
    }()
    
    // standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        occupied = false // not occupied by default
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Position", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        //occupied = false // not occupied by default
        
        //to add values from a dictionary
//        if let gameName = dictionary["game"] as? String {
//            name = gameName
//        }
    }

}

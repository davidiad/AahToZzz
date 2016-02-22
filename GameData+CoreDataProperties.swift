//
//  GameData+CoreDataProperties.swift
//  AahToZzz
//
//  Created by David Fierstein on 2/21/16.
//  Copyright © 2016 David Fierstein. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension GameData {

    @NSManaged var currentLetterSetID: NSNumber?
    @NSManaged var gameID: NSNumber?
    @NSManaged var name: String?
    @NSManaged var lettersets: NSSet?

}

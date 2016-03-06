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

}

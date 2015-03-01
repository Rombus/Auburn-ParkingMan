//
//  OtherLots.swift
//  ParkingMan
//
//  Created by Richard Kosbab on 2/22/15.
//  Copyright (c) 2015 ParkingMan. All rights reserved.
//

import Foundation
import CoreData

class OtherLots: NSManagedObject {

    @NSManaged var provider: String
    @NSManaged var address: String
    @NSManaged var spots: NSNumber
    @NSManaged var cost: NSDecimalNumber

}

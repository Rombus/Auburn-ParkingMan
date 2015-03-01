//
//  CityOfAuburn.swift
//  ParkingMan
//
//  Created by Richard Kosbab on 2/21/15.
//  Copyright (c) 2015 ParkingMan. All rights reserved.
//

import Foundation
import CoreData

class CityOfAuburn: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var lotid: NSNumber
    @NSManaged var stallnumber: NSNumber
    @NSManaged var starttime: NSDate
    @NSManaged var expirationtime: NSDate
    @NSManaged var occupidetime: NSDate
    @NSManaged var occupied: NSNumber
    @NSManaged var x_coord: NSNumber
    @NSManaged var y_coord: NSNumber
    @NSManaged var stalltype: String

}

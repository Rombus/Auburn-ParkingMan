//
//  AuburnImport.swift
//  ParkingMan
//
//  Created by Richard Kosbab on 2/21/15.
//  Copyright (c) 2015 ParkingMan. All rights reserved.
//

import Foundation
import CoreData
import UIKit
@objc(CityOfAuburn)
protocol updateProto {
    func updateTrigger()
}

class AuburnImport: NSObject{
    
    // Workaround for Swifts lack of Class Variables
    private struct vars{
        // Strings
        static let auburnURL:   String = "http://www.auburnalabama.org/odata/ventek/stall"
        static let auburnDate:  String = "yyyy-MM-dd'T'HH:mm:ss"
        
        // Core Data
        static let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        static let managedContext = vars.appDelegate.managedObjectContext!
        static let fetchRequest = NSFetchRequest(entityName: "CityOfAuburn")
    }
    
    // Assync pull of City Of Auburn smart parking data
    class func get(vc: ViewController){
        
        // Variable Setup
        var url: NSURL = NSURL(string: vars.auburnURL)!
        var request: NSURLRequest = NSURLRequest(URL: url)
        let queue:NSOperationQueue = NSOperationQueue()
        
        // Async Request
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var err: NSError
            AuburnImport.CoreDataImport(data)
            dispatch_async(dispatch_get_main_queue(), {
                vc.updateTrigger()
                return
            });
        })
        
        println("City of Auburn JSON Pulled")
    }
    
    // Auburn JSON Data to CoreData
    class func CoreDataImport(data: NSData){
        
        // Variable Setup
        let auburnJSON = JSON(data: data)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = vars.auburnDate
        
        // SwiftyJSON
        for (index:String, subJson:JSON) in auburnJSON["value"]{
            
            // Creation of CityOfAuburn managed object
            var spot: CityOfAuburn!
            
            // Search for Core Data entries by Stall number
            let predicate = NSPredicate(format: "stallnumber == %i", subJson["StallNumber"].int!)
            vars.fetchRequest.predicate = predicate
            
            let fetchResults = vars.managedContext.executeFetchRequest(vars.fetchRequest, error: nil)!
            
            // If we find a result, set as spot, otherwise make a new object
            if (!fetchResults.isEmpty){
                spot = fetchResults[0] as CityOfAuburn
            } else {
                spot = NSEntityDescription.insertNewObjectForEntityForName("CityOfAuburn", inManagedObjectContext: vars.managedContext) as CityOfAuburn
            }
            
            // Import the Data
            spot.id = subJson["ID"].int!
            spot.lotid = subJson["LotID"].int!
            spot.stallnumber = subJson["StallNumber"].int!
            spot.starttime = dateFormatter.dateFromString(subJson["StartTime"].string!)!
            spot.expirationtime = dateFormatter.dateFromString(subJson["ExpirationTime"].string!)!
            spot.occupidetime = dateFormatter.dateFromString(subJson["OccupiedTime"].string!)!
            spot.occupied = subJson["Occupied"].boolValue
            spot.x_coord = subJson["X_Coord"].doubleValue
            spot.y_coord = subJson["Y_Coord"].doubleValue
            spot.stalltype = subJson["StallType"].string!
            
        }
        
        // Save after we create all the objects
        var error: NSError?
        if !vars.managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    // Returns all spots
    class func allSpots() -> Array<CityOfAuburn>{
        
        let spots: Array = vars.managedContext.executeFetchRequest(vars.fetchRequest, error: nil) as [CityOfAuburn]!
        
        println("TotalSpots: \(spots.count)")
        return spots
    }
    
    class func openSpots() -> Array<CityOfAuburn>{
        
        //Predicate for Open Spots
        let predicate = NSPredicate(format: "occupied == NO")
        vars.fetchRequest.predicate = predicate
        
        let spots: Array = vars.managedContext.executeFetchRequest(vars.fetchRequest, error: nil) as [CityOfAuburn]!
        
        println("OpenSpots: \(spots.count)")
        return spots
    }
}
//
//  OtherLotsImport.swift
//  ParkingMan
//
//  Created by Richard Kosbab on 2/22/15.
//  Copyright (c) 2015 ParkingMan. All rights reserved.
//

import Foundation
import CoreData
import UIKit
@objc(OtherLots)

class OtherLotsImport: NSObject{
    
    // Workaround for Swifts lack of Class Variables
    private struct vars{
        // Strings
        static let auburnLotsURL:       String = "http://131.204.27.118:8080/parkingmen/phone.jsp?city=auburn"
        static let birminghamLotsURL:   String = "http://131.204.27.118:8080/parkingmen/phone.jsp?city=birmingham"
        
        // Core Data
        static let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        static let managedContext = vars.appDelegate.managedObjectContext!
        static let fetchRequest = NSFetchRequest(entityName: "OtherLots")
    }
    
    // Assync pull of OtherLots page
    class func get(vc: ViewController){
        
        // Variable Setup
        var auburl: NSURL = NSURL(string: vars.auburnLotsURL)!
        //var birurl: NSURL = NSURL(string: vars.birminghamLotsURL)!
        var aubrequest: NSURLRequest = NSURLRequest(URL: auburl)
        //var birrequest: NSURLRequest = NSURLRequest(URL: birurl)
        let queue1:NSOperationQueue = NSOperationQueue()
        //let queue2:NSOperationQueue = NSOperationQueue()
        
        // Async Requests
        NSURLConnection.sendAsynchronousRequest(aubrequest, queue: queue1, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var err: NSError
            OtherLotsImport.CoreDataOrtherLotsImport(data)
            // troubleshooting only one request first.
            /* NSURLConnection.sendAsynchronousRequest(birrequest, queue: queue2, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                var err: NSError
                OtherLotsImport.CoreDataOrtherLotsImport(data)
                dispatch_async(dispatch_get_main_queue(), {
                    vc.updateTrigger()
                    return
                });
            })*/
        })
        
        println("OtherLots Data Pulled")
    }
    
    // OtherLots Data to CoreData
    class func CoreDataOrtherLotsImport(data: NSData){
        
        // Data to String to Array conversion
        var dataString = NSString(data: data,encoding: NSUTF8StringEncoding)
        dataString = dataString?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        println(dataString!)
        
        var dataArray = dataString!.componentsSeparatedByString(";") as Array!
        
        // Drops blank data at end of array (UNSAFE, assumes data will ALWAYS end with extra semicolon)
        dataArray.removeLast()
        
        var lot: OtherLots!
        var count = 0
        var numberFormat = NSNumberFormatter()
        numberFormat.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        for item in dataArray{
            switch count{
            case 0:                             // Provider
                let predicate = NSPredicate(format: "provider == %@", item as String)
                vars.fetchRequest.predicate = predicate
                let fetchResults = vars.managedContext.executeFetchRequest(vars.fetchRequest, error: nil)!
                if (fetchResults.isEmpty){
                    lot = NSEntityDescription.insertNewObjectForEntityForName("OtherLots", inManagedObjectContext: vars.managedContext) as OtherLots
                    lot.provider = item as String
                    println("Creating Lot Provider: \(item)");
                } else {
                    lot = fetchResults [0] as OtherLots
                    println("Updating Lot Provider: \(item)")
                }
                count++
            case 1:                             // Address
                lot.address = item as String
                count++
            case 2:                             // Spots
                lot.spots = numberFormat.numberFromString(item as String)!
                count++
            case 3:                             // Cost
                lot.cost = NSDecimalNumber(string: item as? String)
                count = 0
            default:
                println("ERROR!")
            }
        }
        
        // Save after we create all the objects
        var error: NSError?
        if !vars.managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
            }
        }
    
    // Returns all lots
    class func allLots() -> Array<OtherLots>{
        
        let lots: Array = vars.managedContext.executeFetchRequest(vars.fetchRequest, error: nil) as [OtherLots]!
        
        println("TotalLots: \(lots.count)")
        return lots
    }
}
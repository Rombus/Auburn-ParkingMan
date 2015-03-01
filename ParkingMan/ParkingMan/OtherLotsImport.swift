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
        var birurl: NSURL = NSURL(string: vars.birminghamLotsURL)!
        var aubrequest: NSURLRequest = NSURLRequest(URL: auburl)
        var birrequest: NSURLRequest = NSURLRequest(URL: birurl)
        let queue1:NSOperationQueue = NSOperationQueue()
        let queue2:NSOperationQueue = NSOperationQueue()
        
        // Async Requests
        NSURLConnection.sendAsynchronousRequest(aubrequest, queue: queue1, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var err: NSError
            OtherLotsImport.CoreDataOrtherLotsImport(data)
            NSURLConnection.sendAsynchronousRequest(birrequest, queue: queue2, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                var err: NSError
                OtherLotsImport.CoreDataOrtherLotsImport(data)
                dispatch_async(dispatch_get_main_queue(), {
                    vc.updateTrigger()
                    return
                });
            })
        })
        
        println("OtherLots Data Pulled")
    }
    
    // OtherLots Data to CoreData
    class func CoreDataOrtherLotsImport(data: NSData){
        
        // Data to String to Array conversion
        let dataString = NSString(data: data,encoding: NSUTF8StringEncoding)
        let dataArray = dataString?.componentsSeparatedByString(";") as Array!
        
        var lot: OtherLots!
        var count = 0
        for item in dataArray{
            if item as NSString == NSCharacterSet.whitespaceAndNewlineCharacterSet() {
                continue
            }
            switch count{
            case 0:
                let predicate = NSPredicate(format: "provider == %@", item.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
                vars.fetchRequest.predicate = predicate
                let fetchResults = vars.managedContext.executeFetchRequest(vars.fetchRequest, error: nil)!
                if (!fetchResults.isEmpty){
                    lot = fetchResults[0] as OtherLots
                } else {
                   lot = NSEntityDescription.insertNewObjectForEntityForName("OtherLots", inManagedObjectContext: vars.managedContext) as OtherLots
                }
                lot.provider = item.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                count++
            case 1:
                lot.address = item.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                count++
            case 2:
                lot.spots = item as NSNumber
                count++
            case 3:
                lot.cost = item as NSDecimalNumber
                count = 0
            default:
                println("error!")
        }
        
        // Save after we create all the objects
        var error: NSError?
        if !vars.managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
            }
        }
    }
    
    
    // Returns all lots
    class func allLots() -> Array<OtherLots>{
        
        let lots: Array = vars.managedContext.executeFetchRequest(vars.fetchRequest, error: nil) as [OtherLots]!
        
        println("TotalLots: \(lots.count)")
        return lots
    }
}
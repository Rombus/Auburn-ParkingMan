//
//  Annotations.swift
//  ParkingMan
//
//  Created by Richard Kosbab on 2/22/15.
//  Copyright (c) 2015 ParkingMan. All rights reserved.
//

import Foundation
import MapKit

class Annotations{
    
    // Returns the current set of Map Annotations
    class func currentAnnotations() -> Array<MKPointAnnotation>{
        
        
        // Setup inital variables variables
        var annotations = Array<MKPointAnnotation>()
        
        for spot in AuburnImport.openSpots(){
            let annotation = MKPointAnnotation()
            
            // NOTE: Per COA API = X_Coord should be Lat, Y_Coord should be Long, but this seemes reveresed in JSON
            let spotcoords = CLLocationCoordinate2D(latitude: spot.y_coord.doubleValue, longitude: spot.x_coord.doubleValue)
            
            annotation.coordinate = spotcoords
            annotation.title = spot.stallnumber.stringValue
            annotation.subtitle = "Open"
            annotations.append(annotation)
        }
        
        println("Annotations Pulled")
        return annotations
    }
}
//
//  ViewController.swift
//  ParkingMan
//
//  Created by Richard Kosbab on 2/21/15.
//  Copyright (c) 2015 ParkingMan. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    var spots = [CityOfAuburn]()

    override func viewDidLoad() {
        super.viewDidLoad()
        AuburnImport.get(self)
        // OtherLotsImport.get(self)
        NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector:Selector("refresh"), userInfo: nil, repeats: true)
        
        func refresh(){
            // Things triggered @ 30 second refresh
            AuburnImport.get(self)
        }
        
        
        // Setup of MapView
        // Location of Smart Parking Lot
        let location = CLLocationCoordinate2D(latitude: 32.607437, longitude: -85.480376)

        // Controls Sized
        let span = MKCoordinateSpanMake(0.0005, 0.0005)
        let region = MKCoordinateRegion(center: location, span: span)
        
        // View Type
        mapView.mapType = MKMapType.Satellite
        mapView.setRegion(region, animated: true)
        mapView.addAnnotations(Annotations.currentAnnotations())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        println("ViewWillAppear")
    }
    func refresh(){
        // Things triggered @ 30 second refresh
        AuburnImport.get(self)
    }
    func updateTrigger() {
        println("updateMap triggered")
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(Annotations.currentAnnotations())
        self.view.setNeedsDisplay()
        
    }
    
}


//
//  MapViewController.swift
//  ExchangeAGram
//
//  Created by Nicholas Markworth on 6/9/15.
//  Copyright (c) 2015 Nick Markworth. All rights reserved.
//

import UIKit
import CoreData
import MapKit
/*
MKCoordinateSpan - determines the amount of area spanned by the map (the amount of map area to be shown)
MKCoordinateRegion - determines the center of the map
MKPointAnnotation - the actual pin that gets used
*/

class MapViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.requestFeedItems()
        
    }
    
    func requestFeedItems() {
        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        var error: NSError?
        let itemArray = context.executeFetchRequest(request, error: &error)
        println(error)
        
        self.addItemsToMap(itemArray)
    }
    
    func addItemsToMap(itemArray: [AnyObject]?) {
        let localArray: [FeedItem] = itemArray as! [FeedItem]
        if localArray.count > 0 {
            for item in localArray {
                // Get the location from the photo
                let location = CLLocationCoordinate2D(latitude: Double(item.latitude), longitude: Double(item.longitude))
                let span = MKCoordinateSpanMake(0.05, 0.05)
                let region = MKCoordinateRegionMake(location, span)
                // Set the area of focus to the location
                mapView.setRegion(region, animated: true)
                // Add a point onto the map for the location
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                annotation.title = item.caption
                mapView.addAnnotation(annotation)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

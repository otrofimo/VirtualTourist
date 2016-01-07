//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Oleg Trofimov on 12/18/15.
//  Copyright © 2015 Oleg Trofimov. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    let mapDictKey = "mapInfo"

    @IBOutlet weak var mapView: MKMapView!

    var annotations = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {}

        fetchedResultsController.delegate = self

        setMapRegion()
        addGestureRecognizers()
        loadAnnotations()
    }

    // MARK: - Core Data Convenience

    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()

    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }

    lazy var fetchedResultsController : NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "Pin")

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        return fetchedResultsController
    }()

    func loadAnnotations() {

        let pins = fetchedResultsController.fetchedObjects as! [Pin]

        let annotations = pins.map { pin -> MKPointAnnotation in
            return  pin.toMKPointAnnotation()
        }

        self.mapView.addAnnotations(annotations)
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {

        // load photo album view controller
        let photoAlbumVC = storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController

        let coordinate = view.annotation?.coordinate

        // Find pin
        let pins = fetchedResultsController.fetchedObjects as! [Pin]

        guard let index = pins.indexOf({ return $0.latitude == coordinate?.latitude && $0.longitude == coordinate?.longitude}) else {
            print("Error: Pin not found in map")
            return
        }

        print("Setting pin on photoAlbumVC with index \(index)")

        photoAlbumVC.pin = pins[index]

        let navigationVC = UINavigationController(rootViewController: photoAlbumVC)

        presentViewController(navigationVC, animated: true, completion: nil)
    }

    func handleLongTap(gestureRecognizer: UIGestureRecognizer) {

        if (gestureRecognizer.state == UIGestureRecognizerState.Ended || gestureRecognizer.state == UIGestureRecognizerState.Changed ) {
            return
        } else {
            let point = gestureRecognizer.locationInView(mapView)
            let touchMapCoordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)

            // Set region of map
            let region = MKCoordinateRegionMakeWithDistance(
                touchMapCoordinate, 2000, 2000)
            mapView.setRegion(region, animated: true)

            // Add annotation to map
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchMapCoordinate
            mapView.addAnnotation(annotation)

            // Add pin
            let pinDetails : [String : AnyObject] = [
                Pin.Keys.Latitude   : touchMapCoordinate.latitude as Double,
                Pin.Keys.Longitude  : touchMapCoordinate.longitude as Double,
            ]

            let _ = Pin(dictionary: pinDetails, context: sharedContext)
            print("Created new pin")
            self.saveContext()
            print("Saved context")
        }
    }

    func addGestureRecognizers() {
        // Long press to create pin
        let longTap = UILongPressGestureRecognizer(target: self, action: "handleLongTap:")
        longTap.numberOfTapsRequired = 0
        longTap.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longTap)
    }

    // MARK : NSFetchedResultsControllerDelegate methods

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }

    func saveMapRegion() {
        let mapRegionCenterLatitude: CLLocationDegrees = mapView.region.center.latitude
        let mapRegionCenterLongitude: CLLocationDegrees = mapView.region.center.longitude
        let mapRegionSpanLatitudeDelta: CLLocationDegrees = mapView.region.span.latitudeDelta
        let mapRegionSpanLongitudeDelta: CLLocationDegrees = mapView.region.span.longitudeDelta

        var mapDictionary: [ String : CLLocationDegrees ] = [ String : CLLocationDegrees ]()
        mapDictionary.updateValue( mapRegionCenterLatitude, forKey: "centerLatitude" )
        mapDictionary.updateValue( mapRegionCenterLongitude, forKey: "centerLongitude" )
        mapDictionary.updateValue( mapRegionSpanLatitudeDelta, forKey: "spanLatitudeDelta" )
        mapDictionary.updateValue( mapRegionSpanLongitudeDelta, forKey: "spanLongitudeDelta" )

        NSUserDefaults.standardUserDefaults().setObject( mapDictionary, forKey: mapDictKey )
    }

    func setMapRegion() {
        if let mapDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(mapDictKey) as? [String : CLLocationDegrees] {
            let centerLatitude = mapDict[ "centerLatitude" ]!
            let centerLongitude = mapDict[ "centerLongitude" ]!
            let spanLatDelta = mapDict[ "spanLatitudeDelta" ]!
            let spanLongDelta = mapDict[ "spanLongitudeDelta" ]!

            let mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: centerLatitude,
                    longitude: centerLongitude
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: spanLatDelta,
                    longitudeDelta: spanLongDelta
                )
            )

            self.mapView.setRegion(mapRegion, animated: true)
        } else {
            saveMapRegion()
        }

    }
}


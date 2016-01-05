//
//  Pin.swift
//  VirtualTourist
//
//  Created by Oleg Trofimov on 12/18/15.
//  Copyright © 2015 Oleg Trofimov. All rights reserved.
//

import CoreData
import MapKit

class Pin : NSManagedObject {
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Photos = "photos"
        static let CreatedAt = "createdAt"
    }

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var createdAt: NSDate
    @NSManaged var photos: [Photo]

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {

        // Core Data
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        // Dictionary
        latitude = dictionary[Keys.Latitude] as! Double
        longitude = dictionary[Keys.Longitude] as! Double
        createdAt = NSDate()
    }

    init(annotation: MKPointAnnotation, context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        // Dictionary
        latitude = annotation.coordinate.latitude as Double
        longitude = annotation.coordinate.longitude as Double
        createdAt = NSDate()
    }

    func toMKPointAnnotation() -> MKPointAnnotation {
        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)

        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate

        return annotation
    }
}
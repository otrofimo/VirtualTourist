//
//  Pin.swift
//  VirtualTourist
//
//  Created by Oleg Trofimov on 12/18/15.
//  Copyright © 2015 Oleg Trofimov. All rights reserved.
//

import CoreData

class Pin : NSManagedObject {
    struct Keys {
        static let Latitude = "name"
        static let Longitude = "profile_path"
        static let Photos = "photos"
        static let ID = "id"
    }

    @NSManaged var latitude: Float
    @NSManaged var longitude: String
    @NSManaged var id: NSNumber
    @NSManaged var photos: [Photo]

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

}
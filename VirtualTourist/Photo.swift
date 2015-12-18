//
//  Photo.swift
//  VirtualTourist
//
//  Created by Oleg Trofimov on 12/18/15.
//  Copyright © 2015 Oleg Trofimov. All rights reserved.
//

import Foundation
import CoreData

class Photo : NSManagedObject {

    struct Keys {
        static let ImagePath = "image_path"
    }

    @NSManaged var imagePath: String?

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {

        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)

        // Store imagePath
         imagePath = dictionary[Keys.ImagePath] as? String
    }

    var image: UIImage? {

        get {
            return Flickr.Caches.imageCache.imageWithIdentifier(imagePath)
        }

        set {
            Flickr.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath!)
        }
    }
}
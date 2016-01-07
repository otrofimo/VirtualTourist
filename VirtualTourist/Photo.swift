//
//  Photo.swift
//  VirtualTourist
//
//  Created by Oleg Trofimov on 12/18/15.
//  Copyright © 2015 Oleg Trofimov. All rights reserved.
//

import UIKit
import CoreData

class Photo : NSManagedObject {

    struct Keys {
        static let Id        = "id"
        static let Title     = "title"
        static let ImagePath = "image_path"

        static let Secret    = "secret"
        static let Farm    = "farm"
        static let Server    = "server"
    }

    struct ImageKeys {
        static let FarmId       = ":farm-id"
        static let ServerId     = ":server-id"
        static let Id           = ":id"
        static let Secret       = ":secret"
        static let SizeParam    = ":size-param"
    }

    struct ImageSizes {
        // Image Sizes
        static let SmallSquare  = "s" // 75x75
        static let LargeSquare  = "q" // 150x150
        static let Thumbnail    = "t" // 100 on longest side

        static let Small240     = "m" // 240 on longest side
        static let Small320     = "n" // 320 on longest side

        static let Medium500    = "-" // 500 on longest side
        static let Medium640    = "z" // 640 on longest side
        static let Medium800    = "c" // 800 on longest side

        static let Large1024    = "b" // 1024 on longest side
        static let Large1600    = "h" // 1600 on longest side
        static let Large2048    = "k" // 2048 on longest side

        static let Original     = "o" // original image
    }

    @NSManaged var id: NSNumber!
    @NSManaged var title: String
    @NSManaged var imagePath: String
    @NSManaged var pin: Pin?

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {

        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)

        // Store keys in object
        id = Int(dictionary[Keys.Id] as! String)!
        title = dictionary[Keys.Title] as! String

        // Create image path
        guard let secret = dictionary[Keys.Secret] as? String,
            let farmId = dictionary[Keys.Farm] as? NSNumber,
            let serverId = dictionary[Keys.Server] as? String
        else {
            print("Missing imagePath component")
            return
        }

        var mutableResource = Flickr.Constants.PhotoURL

        mutableResource = mutableResource.stringByReplacingOccurrencesOfString("{\(ImageKeys.FarmId)}", withString: "\(farmId)")
        mutableResource = mutableResource.stringByReplacingOccurrencesOfString("{\(ImageKeys.ServerId)}", withString: "\(serverId)")
        mutableResource = mutableResource.stringByReplacingOccurrencesOfString("{\(ImageKeys.Secret)}", withString: "\(secret)")
        mutableResource = mutableResource.stringByReplacingOccurrencesOfString("{\(ImageKeys.Id)}", withString: "\(id)")
        mutableResource = mutableResource.stringByReplacingOccurrencesOfString("[\(ImageKeys.SizeParam)]", withString: "\(ImageSizes.LargeSquare)")

        imagePath = mutableResource
    }

    var image: UIImage? {
        get {
            let identifier = "\(self.id)"
            return Flickr.Caches.imageCache.imageWithIdentifier(identifier)
        }
        set {
            let identifier = "\(self.id)"
            Flickr.Caches.imageCache.storeImage(newValue, withIdentifier: identifier)
        }
    }
}
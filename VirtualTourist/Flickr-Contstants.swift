//
//  Flickr-Contstants.swift
//  VirtualTourist
//
//  Created by Oleg Trofimov on 12/18/15.
//  Copyright © 2015 Oleg Trofimov. All rights reserved.
//

import Foundation

extension Flickr {

    struct Constants {
        static let BASE_URL = "https://api.flickr.com/services/rest/"
        static let METHOD_NAME = "flickr.photos.geo.photosForLocation"
        static let API_KEY = Flickr.sharedInstance().valueForAPIKey("FlickrAPIKey")
        static let EXTRAS = "url_m"
        static let DATA_FORMAT = "json"
        static let NO_JSON_CALLBACK = "1"

        static let PhotoURL = "https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg"
    }

    struct Keys {
        static let Latitude     = "lat"
        static let Longitude    = "lon"
        static let Accuracy     = "accuracy"
        static let PerPage      = "per_page"
        static let Page         = "page"

        static let ErrorStatusMessage = "message"
    }

    struct PhotoKeys {
        static let FarmId       = "farm-id"
        static let ServerId     = "server-id"
        static let Id           = "id"
        static let Secret       = "secret"

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

    func valueForAPIKey(keyname:String) -> String {
        let filePath = NSBundle.mainBundle().pathForResource("Api", ofType:"plist")
        let plist = NSDictionary(contentsOfFile:filePath!)

        let value:String = plist?.objectForKey(keyname) as! String
        return value
    }
}
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
        static let METHOD_NAME = "flickr.photos.search"
        static let API_KEY = Flickr.sharedInstance().valueForAPIKey("FlickrAPIKey")
        static let EXTRAS = "url_m"
        static let DATA_FORMAT = "json"
        static let NO_JSON_CALLBACK = "1"
        static let PER_PAGE = 21
        static let MAX_PHOTOS = 4000
        static let MAX_PAGES = MAX_PHOTOS/PER_PAGE + 1

        static let PhotoURL = "https://farm{:farm-id}.staticflickr.com/{:server-id}/{:id}_{:secret}_[:size-param].jpg"
    }

    struct Keys {
        static let Latitude     = "lat"
        static let Longitude    = "lon"
        static let Accuracy     = "accuracy"
        static let PerPage      = "per_page"
        static let Page         = "page"
        static let Method       = "method"
        static let Format       = "format"
        static let BBox         = "bbox"
        static let JSONCallback = "nojsoncallback"
        static let Photo_Count  = ""

        static let BOUNDING_BOX_HALF_WIDTH = 1.0
        static let BOUNDING_BOX_HALF_HEIGHT = 1.0
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0

        static let Photos       = "photos"
        static let Photo        = "photo"

        static let ErrorStatusMessage = "message"
    }

    func valueForAPIKey(keyname:String) -> String {
        let filePath = NSBundle.mainBundle().pathForResource("Api", ofType:"plist")
        let plist = NSDictionary(contentsOfFile:filePath!)

        let value:String = plist?.objectForKey(keyname) as! String
        return value
    }

    func createBBoxString(latitude : Double, longitude: Double ) -> String {
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - Keys.BOUNDING_BOX_HALF_WIDTH, Keys.LON_MIN)
        let bottom_left_lat = max(latitude - Keys.BOUNDING_BOX_HALF_HEIGHT, Keys.LAT_MIN)
        let top_right_lon = min(longitude + Keys.BOUNDING_BOX_HALF_HEIGHT, Keys.LON_MAX)
        let top_right_lat = min(latitude + Keys.BOUNDING_BOX_HALF_HEIGHT, Keys.LAT_MAX)

        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
}
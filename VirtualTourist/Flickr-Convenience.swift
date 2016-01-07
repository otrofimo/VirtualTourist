//
//  Flickr-Convenience.swift
//  VirtualTourist
//
//  Created by Oleg Trofimov on 12/21/15.
//  Copyright © 2015 Oleg Trofimov. All rights reserved.
//

import Foundation

extension Flickr {

    func getPhotos(page: Int, latitude: Double, longitude: Double, completionHandler: CompletionHander) -> NSURLSessionDataTask {

        let parameters : [String : AnyObject] = [
            Keys.Method    : Constants.METHOD_NAME,
            Keys.BBox      : Flickr.sharedInstance().createBBoxString(latitude, longitude: longitude),
            Keys.Page      : page,
            Keys.Format    : Constants.DATA_FORMAT,
            Keys.JSONCallback : Constants.NO_JSON_CALLBACK,
            Keys.PerPage : Constants.PER_PAGE
        ]

        let task = self.taskForResource(parameters) { JSONResult, error in

            if let error = error {
                print(error)
                completionHandler(result: [], error: error)
            } else {
                completionHandler(result: JSONResult, error: nil)
            }
        }

        task.resume()

        return task
    }

    func taskforImageFromPhoto(photo: Photo, completionHandler : (imageData: NSData?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let url = NSURL(string: photo.imagePath)!

        let request = NSURLRequest(URL: url)

        let task = session.dataTaskWithRequest(request) { data, response, downloadError in

            if let error = downloadError {
                let newError = Flickr.errorForData(data, response: response, error: error)
                completionHandler(imageData: nil, error: newError)
            } else {

                completionHandler(imageData: data, error: nil)
            }
        }

        task.resume()

        return task
    }
}

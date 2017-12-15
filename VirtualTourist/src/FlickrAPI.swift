//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Jean-Yves Jacaria on 09/11/2017.
//  Copyright © 2017 Jean-Yves Jacaria. All rights reserved.
//

import Foundation
import CoreLocation




struct FlickrAPI {
    
    static func photoURL(farmId: Int, serverId: String, photoId: String, secret: String) -> URL {
        let urlString = "https://farm\(farmId).staticflickr.com/\(serverId)/\(photoId)_\(secret)_c.jpg"
        let url = URL(string: urlString)!
        return url
    }
    
    
    
    
    /**
     Returns the formatted URL
     - Parameters:
       - latitude: Latitude of the pin
       - longitude: Longitude of the pin
       - page: Page of results to return. This is saved in the pin's core data 'pages' attribute
     */
    static func searchURL(latitude: CLLocationDegrees, longitude: CLLocationDegrees, page: Int = 1) -> URL {
        let key = Constants.FlickrAPI.key
        let searchMethodName = Constants.FlickrAPI.searchMethodName
        let endPoint = Constants.FlickrAPI.endPoint
        let queryString = "?api_key=\(key)&format=json&nojsoncallback=1&method=\(searchMethodName)&lon=\(longitude)&lat=\(latitude)&page=\(page)"
        let url = URL(string: endPoint + queryString)!
        return url
    }
}

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
    
    static let endPoint = "https://api.flickr.com/services/rest"
    static let key = "30ea6c99243c8de780e96f54608709ae"
    static let searchMethodName = "flickr.photos.search"
    
    static func photoURL(farmId: Int, serverId: String, photoId: String, secret: String) -> URL {
        let urlString = "https://farm\(farmId).staticflickr.com/\(serverId)/\(photoId)_\(secret)_z.jpg"
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
       /* var query = URLComponents(string: endPoint)!
        let apiQI = URLQueryItem(name: "api_key", value: key)
        let latitudeQI = URLQueryItem(name: "latitude", value: String(latitude))
        let longitudeQI = URLQueryItem(name: "longitude", value: String(longitude))
        let formatQI = URLQueryItem(name: "format", value: "json")
        let jsonCallbackQI = URLQueryItem(name: "nojsoncallback", value: "1")
        query.queryItems = [apiQI, latitudeQI, longitudeQI]*/
        let queryString = "?api_key=\(FlickrAPI.key)&format=json&nojsoncallback=1&per_page=500&method=\(searchMethodName)&lon=\(longitude)&lat=\(latitude)&page=\(page)"
        let url = URL(string: endPoint + queryString)!
        return url
    }
}

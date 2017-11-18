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
    
    static func photoURL(farmId: Int, serverId: String, photoId: String, secret: String) -> URL {
        let urlString = "https://farm\(farmId).staticflickr.com/\(serverId)/\(photoId)_\(secret).jpg"
        let url = URL(string: urlString)!
        return url
    }
    
    static func searchURL(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> URL {
        let queryString = "?api_key=\(FlickrAPI.key)&format=json&nojsoncallback=1&per_page=50&method=flickr.photos.search&lon=\(longitude)&lat=\(latitude)"
        let url = URL(string: endPoint + queryString)!
        return url
    }
}

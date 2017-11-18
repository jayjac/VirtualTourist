//
//  AlbumLocation.swift
//  VirtualTourist
//
//  Created by Jean-Yves Jacaria on 09/11/2017.
//  Copyright © 2017 Jean-Yves Jacaria. All rights reserved.
//

import Foundation
import CoreLocation


private enum LocationCodingKey: String {
    case latitude
    case longitude
}

class AlbumLocation: NSObject, NSCoding {
    
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    
    init(location: CLLocationCoordinate2D) {
        self.longitude = location.longitude
        self.latitude = location.latitude
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        let latitude = aDecoder.decodeDouble(forKey: LocationCodingKey.latitude.rawValue)
        let longitude = aDecoder.decodeDouble(forKey: LocationCodingKey.longitude.rawValue)
        self.latitude = latitude
        self.longitude = longitude
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(latitude, forKey: LocationCodingKey.latitude.rawValue)
        aCoder.encode(longitude, forKey: LocationCodingKey.longitude.rawValue)
    }
}

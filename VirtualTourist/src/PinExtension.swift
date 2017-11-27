//
//  PinExtension.swift
//  VirtualTourist
//
//  Created by Jean-Yves Jacaria on 22/11/2017.
//  Copyright © 2017 Jean-Yves Jacaria. All rights reserved.
//

import CoreLocation

extension Pin {
    
    func setLocation(_ location: CLLocationCoordinate2D) {
        self.longitude = location.longitude
        self.latitude = location.latitude
    }
}

//
//  ImageGalleryMapViewDelegate.swift
//  VirtualTourist
//
//  Created by Jean-Yves Jacaria on 13/12/2017.
//  Copyright © 2017 Jean-Yves Jacaria. All rights reserved.
//

import UIKit
import MapKit

class ImageGalleryMapViewDelegate: NSObject, MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") {
            pinAnnotationView.annotation = annotation
            return pinAnnotationView
        }
        else {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinAnnotationView.animatesDrop = false
            return pinAnnotationView
        }
    }
}

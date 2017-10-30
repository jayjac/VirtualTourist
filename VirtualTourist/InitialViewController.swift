//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Jean-Yves Jacaria on 25/10/2017.
//  Copyright © 2017 Jean-Yves Jacaria. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InitialViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnMap(_:)))
        mapView.addGestureRecognizer(longPress)
    }
    
    @objc private func longPressOnMap(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            let point = gesture.location(in: mapView)
            let location = mapView.convert(point, toCoordinateFrom: nil)
            print(location)
        }

    }




}


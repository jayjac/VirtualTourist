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
import CoreData

class InitialViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        if let pins = MapStatePersistor.retrievePins() {
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                mapView.addAnnotation(annotation)
            }
        }
    }
    

    

    
    private func setupMap() {
        mapView.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnMap(_:)))
        mapView.addGestureRecognizer(longPress)
        guard let state = MapStatePersistor.currentMapState else { return }
        mapView.region = state.coordinateRegion
    }

    private func saveMapState() {
        MapStatePersistor.saveMapState(with: mapView.region)
    }

    @objc private func longPressOnMap(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: mapView)
            addPinOntoMap(at: point)
        }
    }
    
    private func addPinOntoMap(at point: CGPoint) {
        let location = mapView.convert(point, toCoordinateFrom: nil)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
        MapStatePersistor.addPin(at: location)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showGallerySegue",
            let imageGallery = segue.destination as? ImageGalleryViewController else { return }
        let selectedAnnotation = mapView.selectedAnnotations[0]
        imageGallery.annotation = selectedAnnotation
    }
    
}


extension InitialViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapState()
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let pin = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") {
            pin.annotation = annotation
            return pin
        }
        else {
            let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pin.animatesDrop = true
            return pin
        }
    }

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: "showGallerySegue", sender: nil)
        mapView.deselectAnnotation(view.annotation, animated: false) // keep after 'performSegue'
    }
}


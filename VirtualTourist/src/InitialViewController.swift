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
    @IBOutlet weak var dismissButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var editButton: UIBarButtonItem!
    private var isDeletingMode = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        dismissButtonBottomConstraint.constant = -60.0
        if let pins = MapStatePersistor.retrievePins() {
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    private func toggleEditButton() {
        isDeletingMode = !isDeletingMode
        dismissButtonBottomConstraint.constant = isDeletingMode ? 0.0 : -60.0
        editButton.title = isDeletingMode ? "Done" : "Edit"
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func editButtonWasTaped(_ sender: Any) {
        toggleEditButton()
    }
    
    @IBAction func dismissButtonWasTapped(_ sender: Any) {
        toggleEditButton()
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
        let location = mapView.convert(point, toCoordinateFrom: mapView)
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
        if let pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") {
            pinAnnotationView.annotation = annotation
            return pinAnnotationView
        }
        else {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinAnnotationView.animatesDrop = true
            return pinAnnotationView
        }
    }

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            fatalError("No annotation attached to annotationView")
        }
        if isDeletingMode {
            MapStatePersistor.removePin(from: annotation.coordinate)
            mapView.removeAnnotation(annotation)
        } else {
            performSegue(withIdentifier: "showGallerySegue", sender: nil)
            mapView.deselectAnnotation(annotation, animated: false) // keep after 'performSegue'
        }

    }
}


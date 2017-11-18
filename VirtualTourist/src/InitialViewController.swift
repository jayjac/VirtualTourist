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
        //fetchAlbums()
    }
    
    /*func fetchAlbums() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        do {
            if let albums = try CoreDataStack.default.context.fetch(fetchRequest) as? [Album] {
                for album in albums {
                    let annotation = MKPointAnnotation()
                    let albumLocation = album.location as! AlbumLocation
                    annotation.coordinate = CLLocationCoordinate2D(latitude: albumLocation.latitude, longitude: albumLocation.longitude)
                    if let date = album.creationDate {
                        annotation.title = "Album from \(date.description)"
                    }
                    
                    mapView.addAnnotation(annotation)
                    print("album has \(album.photos?.count ?? 0) photos")
                }
            }
            
        }
        catch let error {
            print(error.localizedDescription)
        }
    }*/
    
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
            let location = mapView.convert(point, toCoordinateFrom: nil)
            PhotoDownloader.download(from: location)
        }
    }
}


extension InitialViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapState()
    }
}


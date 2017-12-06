//
//  ImageGalleryViewController.swift
//  VirtualTourist
//
//  Created by Jean-Yves Jacaria on 18/11/2017.
//  Copyright © 2017 Jean-Yves Jacaria. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation


class ImageGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    private var photosArray = [Photo]()
    private var cellSize = CGSize(width: 80, height: 80)
    private var coordinateToLoad: CLLocationCoordinate2D!
    var annotation: MKAnnotation?
    
    func setLocationToLoad(_ coordinate: CLLocationCoordinate2D) {
        self.coordinateToLoad = coordinate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        
        //TODO: add the delete capability
        // if not in delete mode, just open up in full screen and swipe thru pager-style
        let editButton = UIBarButtonItem(title: "Delete", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = editButton
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
        fetchAlbums()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let annotation = annotation {
            mapView.addAnnotation(annotation)
            mapView.setCenter(annotation.coordinate, animated: false)
        }
    }
    
    private func retrievePin() {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = view.bounds.width / 3 - 1
        cellSize = CGSize(width: width, height: width)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    
    func fetchAlbums() {
        photosArray.removeAll()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        do {
            if let pins = try CoreDataStack.default.context.fetch(fetchRequest) as? [Pin], pins.count > 0 {
                let pin = pins[0]
                guard let photos = pin.photos else { return }
                for item in photos {
                    if let photo = item as? Photo {
                        photosArray.append(photo)
                    }
                }
                imagesCollectionView.reloadData()
            }
            
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        let photo = photosArray[indexPath.row]
        if let data = photo.data, let image = UIImage(data: data) {
            cell.imageView.image = image
            cell.label.text = photo.title
        }

        return cell
    }



}

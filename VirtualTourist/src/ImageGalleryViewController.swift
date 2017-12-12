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

    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    private var photosArray = [Photo]()
    private var cellSize = CGSize(width: 80, height: 80)
    var annotation: MKAnnotation?
    

    
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

    }
    
    
    @IBAction func newCollectionButtonWasTapped(_ sender: Any) {
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let annotation = annotation else { return }
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: false)
        refreshPhotos(at: annotation.coordinate)
    }
    
    
    func refreshPhotos(at coordinate: CLLocationCoordinate2D) {
        guard let photos = DataPersistor.retrievePhotoArray(from: coordinate) else { return }
        photosArray = photos
        imagesCollectionView.reloadData()
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
    
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        let index = indexPath.row
        let photo = photosArray[index]
        cell.setupCell(with: photo.data, title: photo.title)
        if photo.data == nil {
            PhotoDownloader.downloadPhoto(photo, at: index, notify: self)
        }
        return cell
    }

}


extension ImageGalleryViewController: PhotoDownloadDelegate {
    
    func photoDownloadDidComplete(at index: Int) {
        print("photo downloaded at index \(index)")
        let indexPath = IndexPath(row: index, section: 0)
        imagesCollectionView.reloadItems(at: [indexPath])
    }
    
    func photoDownloadFailed(with message: String) {
        
    }
    
    func photoMetaRetrieved() {

    }
}

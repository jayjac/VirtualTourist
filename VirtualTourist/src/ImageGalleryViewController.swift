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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let annotation = annotation else { return }
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: false)
        PhotoDownloader.downloadPhotosMetaData(for: annotation.coordinate)
        guard let photos = DataPersistor.retrievePhotoArray(from: annotation.coordinate) else { return }
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
        let photo = photosArray[indexPath.row]
        if let data = photo.data, let image = UIImage(data: data) {
            cell.imageView.image = image
            cell.label.text = photo.title
        } else {
            cell.imageView.image = UIImage(named: "placeholder")
        }

        return cell
    }



}

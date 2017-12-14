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


extension Notification.Name {
    static let photosMetaRetrieved = Notification.Name("photosMetaRetrieved")
}


class ImageGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    private var photosArray = [Photo]()
    private var cellSize = CGSize(width: 80, height: 80)
    private let mapViewDelegate = ImageGalleryMapViewDelegate()
    private var isDeletingMode = false
    private var deleteButton: UIBarButtonItem!
    private var selectedCellIndex: Int?
    var location: CLLocationCoordinate2D!
    var annotation: MKAnnotation! {
        didSet {
            location = annotation.coordinate
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViews()
    }
    
    private func initializeViews() {
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.delegate = mapViewDelegate
        deleteButton = UIBarButtonItem(title: "Delete", style: UIBarButtonItemStyle.plain, target: self, action: #selector(toggleDeletingMode))
        newCollectionButton.isEnabled = false
        deleteButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = deleteButton
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
    }
    
    @objc private func toggleDeletingMode() {
        isDeletingMode = !isDeletingMode
        deleteButton.title = isDeletingMode ? "Done" : "Delete"
        animateDeleteIconOnVisibleCells()
    }
    
    private func animateDeleteIconOnVisibleCells() {
        let cells = imagesCollectionView.visibleCells as! [ImageCell]
        for cell in cells {
            cell.toggleDeleteImage(isDeletingMode)
        }
    }
    
    
    @IBAction func newCollectionButtonWasTapped(_ sender: Any) {
        DataPersistor.removeAllPhotos(photosArray)
        PhotoDownloader.downloadPhotosMetaData(for: annotation.coordinate)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupMapAnnotation()
        NotificationCenter.default.addObserver(self, selector: #selector(photoMetaDetaWasRetrieved(notification:)), name: .photosMetaRetrieved, object: nil)
        refreshPhotos()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupMapAnnotation() {
        //guard let annotation = annotation else { return }
        mapView.addAnnotation(annotation)
        mapView.setCenter(location, animated: false)
    }

    @objc func photoMetaDetaWasRetrieved(notification: Notification) {
        if let pin = notification.object as? Pin,
            pin.latitude == location.latitude,
            pin.longitude == location.longitude,
            let photos = pin.photos {
            if photos.count == 0 {
                showNoPhotoAlert()
            } else {
                refreshPhotos()
            }
        }
    }
    
    
    private func refreshPhotos() {
        guard let photos = DataPersistor.retrievePhotoArray(from: annotation.coordinate) else { return }
        photosArray = photos
        imagesCollectionView.reloadData()
        if photosArray.count > 0 {
            for (index, photo) in photos.enumerated() {
                if photo.data == nil {
                    PhotoDownloader.downloadPhoto(photo, at: index, notify: self)
                }
            }
            checkIfAllPhotosAreLoaded()
            return
        } else {
            showNoPhotoAlert()
        }
        
    }
    
    private func showNoPhotoAlert() {
        let alert = UIAlertController(title: "No photo", message: "There was no photo taken at that location", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func checkIfAllPhotosAreLoaded() {
        var loaded = true
        for photo in photosArray {
            if photo.data == nil {
                loaded = false
                break
            }
        }
        newCollectionButton.isEnabled = loaded
        deleteButton.isEnabled = loaded
    }
    

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = view.bounds.width / 3 - 1
        cellSize = CGSize(width: width, height: width)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SinglePhotoSegue",
            let selectedIndex = selectedCellIndex,
            let photoData = photosArray[selectedIndex].data {
            let singlePhotoVC = segue.destination as! SinglePhotoViewController
            singlePhotoVC.photoData = photoData
            selectedCellIndex = nil
        }
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
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isDeletingMode {
            let photo = photosArray[indexPath.row]
            DataPersistor.deleteOneSinglePhotoFromGallery(photo)
            photosArray.remove(at: indexPath.row)
            imagesCollectionView.deleteItems(at: [indexPath])
        } else {
            selectedCellIndex = indexPath.row
            performSegue(withIdentifier: "SinglePhotoSegue", sender: nil)
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        let index = indexPath.row
        let photo = photosArray[index]
        cell.setupCell(with: photo.data, title: photo.title, deletingMode: isDeletingMode)
        return cell
    }
    


}


extension ImageGalleryViewController: PhotoDownloadDelegate {
    
    func photoDownloadDidComplete(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        imagesCollectionView.reloadItems(at: [indexPath])
        checkIfAllPhotosAreLoaded()
    }
    
    func photoDownloadFailed(with message: String) {
        
    }

}

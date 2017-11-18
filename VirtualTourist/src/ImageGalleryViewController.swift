//
//  ImageGalleryViewController.swift
//  VirtualTourist
//
//  Created by Jean-Yves Jacaria on 18/11/2017.
//  Copyright © 2017 Jean-Yves Jacaria. All rights reserved.
//

import UIKit
import CoreData


class ImageGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var imagesCollectionView: UICollectionView!
    private var photosArray = [Photo]()
    private var cellSize = CGSize(width: 80, height: 80)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
        fetchAlbums()
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        do {
            if let albums = try CoreDataStack.default.context.fetch(fetchRequest) as? [Album] {
                let album = albums[0]
                guard let photos = album.photos else { return }
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

//
//  PhotoDownloader.swift
//  VirtualTourist
//
//  Created by Jean-Yves Jacaria on 17/11/2017.
//  Copyright © 2017 Jean-Yves Jacaria. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData


protocol PhotoDownloadDelegate {
    
    func photoDownloadDidComplete(at index: Int)
    func photoDownloadFailed(with message: String)

}



class PhotoDownloader {
    
    
    private static let PHOTO_GALLERY_SIZE = 48
    
    
    /*
     Downloads photos' URLs and title and saves it into Core Data
     Image data can be downloaded at a later time, when the user has internet access
     */
    static func downloadPhotosMetaData(for location: CLLocationCoordinate2D) {
        let randomPage = getRandomPageForLocation(location)
        let backgroundQueue = DispatchQueue.global(qos: .background)
        backgroundQueue.async {
            let url = FlickrAPI.searchURL(latitude: location.latitude, longitude: location.longitude, page: randomPage)
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                let photoMetaData = parsePhotoArray(from: data)
                guard let photosArray = photoMetaData.array else { return }
                let numberOfPages = photoMetaData.numberOfPages
                let randomArray = photosArray.count > PHOTO_GALLERY_SIZE ? randomizedPhotosArray(photosArray) : photosArray
                DataPersistor.persistPhotoMetaData(randomArray, to: location, totalPages: numberOfPages)
            })
            task.resume()
        }
    }
    
    private static func getRandomPageForLocation(_ location: CLLocationCoordinate2D) -> Int {
        guard let pin = DataPersistor.retrievePin(from: location) else {
            return 1
        }
        let maxNumberOfPages = min(pin.pages, 4000 / 250)
        let pages = UInt32(maxNumberOfPages)
        let randomPage = arc4random_uniform(pages) + 1
        return Int(randomPage)
    }
    
    /*
     * Get 60 random pictures from the returned pictures
     */
    static func randomizedPhotosArray(_ photos: [[String: Any]]) -> [[String: Any]] {
        var randomArray = [[String: Any]]()
        var arrayCopy = photos
        for _ in 0..<PHOTO_GALLERY_SIZE {
            let length = UInt32(arrayCopy.count)
            let random = Int(arc4random_uniform(length))
            let element = arrayCopy.remove(at: random)
            randomArray.append(element)
        }
        return randomArray
    }
    
    /*
     Returns a JSON array from the Flickr data
     */
    static func parsePhotoArray(from data: Data?) -> (array: [[String: Any]]?, numberOfPages: Int) {
        if let data = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let photoPage = json["photos"] as? [String: Any],
                    let photos = photoPage["photo"] as? [[String: Any]],
                    let pages = photoPage["pages"] as? Int {
                    //print(json)
                    return (photos, pages)
                }
            } catch {}
        }
        return (nil, 0)
    }
    
    static func downloadPhoto(_ photo: Photo, at index: Int, notify delegate: PhotoDownloadDelegate) {
        guard let pin = photo.pin, !pin.isDeleted else {
            print("pin wass deleted so canceling download of photos")
            return
        }
        guard let url = photo.photoURL else {
            DispatchQueue.main.async {
                delegate.photoDownloadFailed(with: "No URL provided for Photo at index \(index)")
            }
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    delegate.photoDownloadFailed(with: error.localizedDescription)
                }
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data {
                DataPersistor.updatePhoto(photo, with: data)
                DispatchQueue.main.async {
                    delegate.photoDownloadDidComplete(at: index)
                }
            }
        }
        task.resume()
    }

}



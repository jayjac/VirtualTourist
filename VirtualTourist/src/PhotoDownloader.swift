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



class PhotoDownloader {
    
    
    /*
     Downloads photos' URLs and title and saves it into Core Data
     Image data can be downloaded at a later time, when the user has internet access
     */
    static func downloadPhotosMetaData(for location: CLLocationCoordinate2D) {
        guard let pin = DataPersistor.retrievePin(from: location) else { return }
        if let photos = pin.photos, photos.count > 0 {
            print("already have photos, no need to download any more")
            return
        }
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            let url = FlickrAPI.searchURL(latitude: location.latitude, longitude: location.longitude)
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let photosArray = retrievePhotos(from: data) else { return }
                DataPersistor.addPhotos(photosArray, to: pin)
            })
            task.resume()
        }
    }
    
    /*
     Returns a JSON array from the Flickr data
     */
    static func retrievePhotos(from data: Data?) -> [[String: Any]]? {
        if let data = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let photoPage = json["photos"] as? [String: Any], let photos = photoPage["photo"] as? [[String: Any]] {
                    return photos
                }
            } catch {}
        }
        return nil
    }
    
    static func downloadOnePhoto(from url: URL) {
        
    }

    

}

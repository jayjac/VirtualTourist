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
    
    
    static func retrievePhotoMetaData(for pin: Pin) {
        let longitude = pin.longitude
        let latitude = pin.latitude
        
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            let url = FlickrAPI.searchURL(latitude: latitude, longitude: longitude)
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let photosArray = retrievePhotos(from: data) else { return }
                print("found \(photosArray.count) photos")
                for photoJSON in photosArray {
                    let photo = Photo(context: CoreDataStack.default.context)
                    let id = photoJSON["id"] as? String ?? "no id"
                    let secret = photoJSON["secret"] as? String ?? "no secret"
                    let server = photoJSON["server"] as? String ?? "no server"
                    let farm = photoJSON["farm"] as? Int ?? -1
                    let title = photoJSON["title"] as? String ?? "no title"
                    let url = FlickrAPI.photoURL(farmId: farm, serverId: server, photoId: id, secret: secret)
                    photo.photoURL = url
                    photo.pin = pin
                    photo.title = title
                    pin.addToPhotos(photo)
                    print(url)
                }
                CoreDataStack.default.save()
                print("saved photo meta")
            })
            task.resume()
        }
    }
    
    static func downloadOnePhoto(from url: URL) {
        
    }

    
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
}

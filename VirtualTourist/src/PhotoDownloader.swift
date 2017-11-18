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
    
    
    static func download(from location: CLLocationCoordinate2D) {
        let album = NSEntityDescription.insertNewObject(forEntityName: "Album", into: CoreDataStack.default.context) as! Album
        album.location = AlbumLocation(location: location)
        album.creationDate = Date()
        let latitude = location.latitude
        let longitude = location.longitude
        let url = FlickrAPI.searchURL(latitude: latitude, longitude: longitude)
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let photos = retrievePhotos(from: data) else { return }
            for p in photos {
                let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: CoreDataStack.default.context) as! Photo
                let id = p["id"] as? String ?? "no id"
                let secret = p["secret"] as? String ?? "no secret"
                let server = p["server"] as? String ?? "no server"
                let farm = p["farm"] as? Int ?? -1
                let title = p["title"] as? String ?? "no title"
                let url = FlickrAPI.photoURL(farmId: farm, serverId: server, photoId: id, secret: secret)
                let data = try? Data.init(contentsOf: url)
                print(url)
                photo.data = data
                photo.album = album
                photo.title = title
                album.addToPhotos(photo)
            }

            do {
                try CoreDataStack.default.context.save()
                print("saved to core data")
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    
    static func retrievePhotos(from data: Data?) -> [[String: Any]]? {
        if let data = data {
            //            let message = String.init(data: data, encoding: String.Encoding.utf8)
            //            print(message ?? "no message")
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

//
//  DataPersistor.swift
//  VirtualTourist
//
//  Created by Jean-Yves Jacaria on 12/12/2017.
//  Copyright © 2017 Jean-Yves Jacaria. All rights reserved.
//


import CoreData
import CoreLocation


struct DataPersistor {
    
    
    private static func pinExists(at location: CLLocationCoordinate2D) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let predicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", location.latitude, location.latitude)
        fetchRequest.predicate = predicate
        do {
            let count = try CoreDataStack.default.context.count(for: fetchRequest)
            return count > 0
        } catch {
            return false
        }
    }
    
    static func persistPin(at location: CLLocationCoordinate2D) {
        guard !pinExists(at: location) else { return }
        let pin = Pin(context: CoreDataStack.default.context)
        pin.latitude = location.latitude
        pin.longitude = location.longitude
        CoreDataStack.default.save()
    }
    
    static func retrievePersistedPins() -> [Pin]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        do {
            guard let pins = try CoreDataStack.default.context.fetch(fetchRequest) as? [Pin] else { return nil }
            return pins
        } catch {
            return nil
        }
    }
    
    static func removeAllPhotos(_ photos: [Photo]) {
        for photo in photos {
            CoreDataStack.default.context.delete(photo)
            //print("deleting photo")
        }
        CoreDataStack.default.save()
    }
    
    static func removePin(from location: CLLocationCoordinate2D) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let latitudeNumber = NSNumber(floatLiteral: location.latitude)
        let longitudeNumber = NSNumber(floatLiteral: location.longitude)
        let predicate = NSPredicate(format: "longitude == %@ AND latitude == %@", longitudeNumber, latitudeNumber)
        fetchRequest.predicate = predicate
        do {
            if let pins = try CoreDataStack.default.context.fetch(fetchRequest) as? [Pin], pins.count > 0 {
                for pin in pins {
                    CoreDataStack.default.context.delete(pin)
                }
                CoreDataStack.default.save()
                //print("pin was deleted successfully")
            }
        } catch {
            print("error deleting pin")
        }
    }
    
    
    static func retrievePin(from location: CLLocationCoordinate2D) -> Pin? {
        let longitude = location.longitude
        let latitude = location.latitude
        let pinRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let predicate = NSPredicate(format: "longitude == %lf AND latitude == %lf", longitude, latitude)
        pinRequest.predicate = predicate
        do {
            let results = try CoreDataStack.default.context.fetch(pinRequest)
            if let pins = results as? [Pin], pins.count > 0 {
                return pins[0]
            }
        }
        catch { }
        return nil
    }
    
    
    static func retrievePhotoArray(from location: CLLocationCoordinate2D) -> [Photo]? {
        let photoRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let predicate = NSPredicate(format: "pin.latitude == %lf AND pin.longitude == %lf", location.latitude, location.longitude)
        photoRequest.predicate = predicate
        do {
            if let results = try CoreDataStack.default.context.fetch(photoRequest) as? [Photo] {
                return results
            }
        } catch {}
        return nil
    }
    
    
    static func persistPhotoMetaData(_ photosArray: [[String: Any]], to location: CLLocationCoordinate2D, totalPages: Int) {
        DispatchQueue.main.async {
            guard let pin = retrievePin(from: location) else { return }
            if pin.isDeleted {
                //print("pin was deleted before metadata could be saved")
                return
            }
            
            for photoJSON in photosArray {
                guard let (id, secret, server, farm, title) = getJSONProperties(from: photoJSON) else { return }
                let photo = Photo(context: CoreDataStack.default.context)
                let url = FlickrAPI.photoURL(farmId: farm, serverId: server, photoId: id, secret: secret)
                photo.photoURL = url
                photo.pin = pin
                photo.title = title
                pin.pages = Int16(totalPages)
                CoreDataStack.default.save()
            }
            NotificationCenter.default.post(name: .photosMetaRetrieved, object: pin)
        }
    }
    
    /* Parses the JSON properties for one photo element returned from Flickr and returns them as a tuple */
    private static func getJSONProperties(from json: [String: Any]) -> (id: String, secret: String, server: String, farm: Int, title: String)? {
        guard let id = json["id"] as? String,
            let secret = json["secret"] as? String,
            let server = json["server"] as? String,
            let farm = json["farm"] as? Int else {
            return nil
        }
        let title = json["title"] as? String ?? ""
        return (id, secret, server, farm, title)
    }
    
    
    /* Once the data for one photo is downloaded, saves it to Core Data */
    static func updatePhoto(_ photo: Photo, with data: Data) {
        DispatchQueue.main.async {
            if photo.isDeleted {
                //print("photo was deleted")
                return
            }
            photo.data = data
            CoreDataStack.default.save()
        }
    }
    
    static func deleteOneSinglePhotoFromGallery(_ photo: Photo) {
        photo.pin?.removeFromPhotos(photo) // removes the photo from the Pin entity's photos collection
        CoreDataStack.default.context.delete(photo)
        CoreDataStack.default.save()
    }
    
}

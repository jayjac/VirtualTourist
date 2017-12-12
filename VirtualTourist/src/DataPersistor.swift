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
    
    static func addPin(at location: CLLocationCoordinate2D) {
        guard !pinExists(at: location) else { return }
        let pin = Pin(context: CoreDataStack.default.context)
        pin.latitude = location.latitude
        pin.longitude = location.longitude
        do {
            try CoreDataStack.default.context.save()
        } catch {
            //TODO: handle the error to let the user know
            print("could not save the pin")
        }
    }
    
    static func retrievePins() -> [Pin]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        do {
            guard let pins = try CoreDataStack.default.context.fetch(fetchRequest) as? [Pin] else { return nil }
            return pins
        } catch {
            return nil
        }
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
                print("pin was deleted successfully")
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
        catch {
            
        }
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
            else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    
    static func addPhotos(_ photosArray: [[String: Any]], to pin: Pin) {
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
    }
    
}

//
//  MapState.swift
//  VirtualTourist
//
//  Created by Jean-Yves Jacaria on 09/11/2017.
//  Copyright © 2017 Jean-Yves Jacaria. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import CoreData

enum CodingKey: String {
    case centerLatitude
    case centerLongitude
    case latitudeDelta
    case longitudeDela
    case mapState
}


/**
 Class to persist the map's coordinate region into UserDefaults.
 */
class MapState: NSObject, NSCoding {
    
    private(set) var coordinateRegion: MKCoordinateRegion
    
    fileprivate init(coordinateRegion: MKCoordinateRegion) {
        self.coordinateRegion = coordinateRegion
        super.init()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        let centerLatitude = aDecoder.decodeDouble(forKey: CodingKey.centerLatitude.rawValue)
        let centerLongitude = aDecoder.decodeDouble(forKey: CodingKey.centerLongitude.rawValue)
        let latitudeDelta = aDecoder.decodeDouble(forKey: CodingKey.latitudeDelta.rawValue)
        let longitudeDelta = aDecoder.decodeDouble(forKey: CodingKey.longitudeDela.rawValue)
        let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        self.coordinateRegion = MKCoordinateRegion(center: center, span: span)
        super.init()
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(coordinateRegion.center.latitude, forKey: CodingKey.centerLatitude.rawValue)
        aCoder.encode(coordinateRegion.center.longitude, forKey: CodingKey.centerLongitude.rawValue)
        aCoder.encode(coordinateRegion.span.latitudeDelta, forKey: CodingKey.latitudeDelta.rawValue)
        aCoder.encode(coordinateRegion.span.longitudeDelta, forKey: CodingKey.longitudeDela.rawValue)
    }
}



struct MapStatePersistor {
    
    static var currentMapState: MapState? {
        guard let stateData = UserDefaults.standard.object(forKey: CodingKey.mapState.rawValue) as? Data, let state = NSKeyedUnarchiver.unarchiveObject(with: stateData) as? MapState else { return nil }
        return state
    }
    
    static func saveMapState(with region: MKCoordinateRegion) {
        let mapState = MapState(coordinateRegion: region)
        let data = NSKeyedArchiver.archivedData(withRootObject: mapState)
        UserDefaults.standard.set(data, forKey: CodingKey.mapState.rawValue)
    }
    
    static func addPin(at location: CLLocationCoordinate2D) {
        let pin = Pin(context: CoreDataStack.default.context)
        pin.latitude = location.latitude
        pin.longitude = location.longitude
        do {
            try CoreDataStack.default.context.save()
            PhotoDownloader.retrievePhotoMetaData(for: pin)
            print("added the pin")
        } catch {
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
                //try CoreDataStack.default.context.save()
                print("pin was deleted successfully")
            }
        } catch {
            print("error deleting pin")
        }
        
    }
}

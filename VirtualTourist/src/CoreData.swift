//
//  CoreData.swift
//  VirtualTourist
//
//  Created by Jean-Yves Jacaria on 26/10/2017.
//  Copyright © 2017 Jean-Yves Jacaria. All rights reserved.
//

import Foundation
import CoreData


class CoreDataStack {
    
    private init() {}
    
    static var `default` = CoreDataStack()
    
    private lazy var modelURL: URL = {
        guard let url = Bundle.main.url(forResource: "Model", withExtension: "momd") else {
            fatalError("Could not find compiled model URL")
        }
        return url
    }()
    
    private lazy var objectModel: NSManagedObjectModel = {
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Could not create a model from the give URL")
        }
        return model
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let storeURL = URL(string: "dataModel.sql", relativeTo: directoryURL)
        let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        do {
            try storeCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        } catch {
            fatalError("Could not configure the store coordinator")
        }
        return storeCoordinator
    }()
    
    private(set) lazy var context: NSManagedObjectContext = {
        let ctx = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        ctx.persistentStoreCoordinator = persistentStoreCoordinator
       return ctx
    }()
    

    
    
    
}

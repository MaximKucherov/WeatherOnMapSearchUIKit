//
//  StorageManager.swift
//  WeatherForecast
//
//  Created by Maxim Kucherov on 11/12/2023.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeatherForecast")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {}
    
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Fetch Data
    func fetchData() -> [CityLocationEntity] {
        // Here, the array is returned non-asynchronously - it is convenient when the database is local (this is not for a remote database)
        let fetchRequest: NSFetchRequest<CityLocationEntity> = CityLocationEntity.fetchRequest()
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
    
    // MARK: - Save data
    func save(_ cityName: String, _ latitude: Double, _ longitude: Double, _ countryName: String, _ state: String, completion: (CityLocationEntity) -> Void) {
        /*
         This method always works
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "CityCountryEntity", in: context) else { return }
        guard let cityCountryEntity = NSManagedObject(entity: entityDescription, insertInto: context) as? CityCountryEntity else { return }
         
        */
        let cityLocationEntity = CityLocationEntity(context: viewContext) // sometimes it doesn't work - replace it with the upper one if anything
        cityLocationEntity.name = cityName
        cityLocationEntity.lat = latitude
        cityLocationEntity.lon = longitude
        cityLocationEntity.country = countryName
        cityLocationEntity.state = state
        
        completion(cityLocationEntity)
        saveContext()
    }
    
    // MARK: - Delete data
    func delete(_ cityCountryEntity: CityLocationEntity) {
        viewContext.delete(cityCountryEntity)
        saveContext()
    }
}

//
//  CoreDataHelper.swift
//  aerologix
//
//  Created by Karthi CK on 02/06/21.
//

import UIKit
import CoreData

class CoreDataHelper: NSObject {
    
    static let sharedInstance = CoreDataHelper()
    
    func writeProfileData(_ profileData: Data) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        if let result = self.fetchProfileData() {
            result.userDetail = profileData
        } else {
            let profileCoreDataObject = ProfileCoreDataObject(context: context)
            profileCoreDataObject.setValue("1", forKey: "key")
            profileCoreDataObject.setValue(profileData, forKey: "userDetail")
        }
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func fetchProfileData() -> ProfileCoreDataObject? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<ProfileCoreDataObject>()
        request.entity = ProfileCoreDataObject(context: context).entity
        request.predicate = NSPredicate(format: "key == %@", "1")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                return results.first
            }
        } catch let error {
            print(error)
            return nil
        }
        return nil
    }
}

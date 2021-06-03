//
//  ProfileCoreDataObject+CoreDataProperties.swift
//  aerologix
//
//  Created by Karthi CK on 02/06/21.
//
//

import Foundation
import CoreData


extension ProfileCoreDataObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfileCoreDataObject> {
        return NSFetchRequest<ProfileCoreDataObject>(entityName: "ProfileCoreDataObject")
    }

    @NSManaged public var userDetail: Data?

}

extension ProfileCoreDataObject : Identifiable {

}

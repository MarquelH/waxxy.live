//
//  Host+CoreDataProperties.swift
//  
//
//  Created by Marquel Hendricks on 1/19/21.
//
//

import Foundation
import CoreData


extension Host {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Host> {
        return NSFetchRequest<Host>(entityName: "Host")
    }

    @NSManaged public var email: String?
    @NSManaged public var hostType: String?
    @NSManaged public var region: String?
    @NSManaged public var username: String?
    @NSManaged public var numSubscribers: Int16
    @NSManaged public var topGenres: NSObject?

}

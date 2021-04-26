//
//  Listener+CoreDataProperties.swift
//  
//
//  Created by Marquel Hendricks on 1/19/21.
//
//

import Foundation
import CoreData


extension Listener {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Listener> {
        return NSFetchRequest<Listener>(entityName: "Listener")
    }

    @NSManaged public var email: String?
    @NSManaged public var liveStreamPlaybackId: String?
    @NSManaged public var name: String?

}

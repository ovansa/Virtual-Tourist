//
//  Locations+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Muhammed Ibrahim on 22/08/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//
//

import Foundation
import CoreData


extension Locations {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Locations> {
        return NSFetchRequest<Locations>(entityName: "Locations")
    }

    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double

}

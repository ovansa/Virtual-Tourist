//
//  Images+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Muhammed Ibrahim on 17/08/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//
//

import Foundation
import CoreData


extension Images {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Images> {
        return NSFetchRequest<Images>(entityName: "Images")
    }

    @NSManaged public var name: String?
    @NSManaged public var imageList: [String]?

}

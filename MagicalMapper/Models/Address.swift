//
//  Address.swift
//  Mapper
//
//  Created by Aryan on 8/29/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation
import CoreData

class Address: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var city: String
    @NSManaged var country: String
    @NSManaged var user: NSSet

}

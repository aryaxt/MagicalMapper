//
//  User.swift
//  Mapper
//
//  Created by Aryan on 8/29/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var age: NSNumber
    @NSManaged var address: Address
    @NSManaged var createdAt: NSDate
    @NSManaged var posts: NSSet
}

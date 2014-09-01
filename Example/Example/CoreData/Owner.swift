//
//  Owner.swift
//  Example
//
//  Created by Aryan on 8/31/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation
import CoreData

class Owner: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var username: String
    @NSManaged var avatarUrl: String
    @NSManaged var repositories: NSSet

}

//
//  Repository.swift
//  Example
//
//  Created by Aryan on 8/31/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation
import CoreData

class Repository: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var name: String
    @NSManaged var url: String
    @NSManaged var createdAt: NSDate
    @NSManaged var openIssuesCount: NSNumber
    @NSManaged var owner: Owner

}

//
//  Post.swift
//  Mapper
//
//  Created by Aryan on 8/30/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation
import CoreData

class Post : NSManagedObject {
    
    @NSManaged var id: NSNumber
    @NSManaged var title: String
    @NSManaged var body: String
    
}

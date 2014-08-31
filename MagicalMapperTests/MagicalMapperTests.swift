//
//  MapperTests.swift
//  MapperTests
//
//  Created by Aryan Ghassemi on 8/29/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//
//  https://github.com/aryaxt/MagicalMapper
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import XCTest
import CoreData

class MapperTests: XCTestCase {
    
    var mapper: Mapper?
    let firstName = "Aryan"
    let lastName = "Ghassemi"
    let age = 27
    let city = "San Francisco"
    let country = "United Satates"
    let createdAt = "1986-05-05"
    let postBody = "body"
    let postTitle = "title"
    
    // MARK: - Setup & Teardown -
    
    override func setUp() {
        CoreDataManager.sharedInstance.reset()
        mapper = Mapper(managedObjectContext: CoreDataManager.sharedInstance.managedObjectContext!)
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Tests -
    
    func testShouldMapFieldsWithoutCustomMapping() {
        var userDict = [String : AnyObject]()
        userDict["firstName"] = firstName
        userDict["lastName"] = lastName
        userDict["createdAt"] = createdAt
        userDict["age"] = age
        
        var user = mapper!.mapDictionary(userDict, toType: User.self)
        
        XCTAssert(user.firstName == firstName, "Pass")
        XCTAssert(user.lastName == lastName, "Pass")
        XCTAssert(user.age == age, "Pass")
        XCTAssert(user.createdAt == defaultDate(), "Pass")
    }
    
    func testShouldMapFieldsWithCustomMapping() {
        var userDict = [String : AnyObject]()
        userDict["fName"] = firstName
        userDict["lName"] = lastName
        userDict["someDate"] = createdAt
        userDict["How_Old-I*Am"] = age
        
        mapper![User.self] = [
            "fName"         : "firstName",
            "lName"         : "lastName",
            "someDate"      : "createdAt",
            "How_Old-I*Am"  : "age"
        ]
        
        var user = mapper!.mapDictionary(userDict, toType: User.self)
        
        XCTAssert(user.firstName == firstName, "Pass")
        XCTAssert(user.lastName == lastName, "Pass")
        XCTAssert(user.age == age, "Pass")
        XCTAssert(user.createdAt == defaultDate(), "Pass")
    }
    
    func testShouldMapOneToOneRelationshipWithoutCustomMapping() {
        var userDict = [String : AnyObject]()
        var addressDict = [String : AnyObject]()
        addressDict["city"] = city
        addressDict["country"] = country
        userDict["address"] = addressDict
        
        var user = mapper!.mapDictionary(userDict, toType: User.self)
        
        XCTAssert(user.address.city == city, "Pass")
        XCTAssert(user.address.country == country, "Pass")
    }
    
    func testShouldMapOneToOneRelationshipWithCustomMapping() {
        var userDict = [String : AnyObject]()
        var addressDict = [String : AnyObject]()
        addressDict["c1Ty"] = city
        addressDict["c0UnTrY"] = country
        userDict["4ddr3$$"] = addressDict
        
        mapper![Address.self] = [
            "c1Ty"      : "city",
            "c0UnTrY"   : "country"]
        
        mapper![User.self] = [
            "4ddr3$$"   : "address"]
        
        var user = mapper!.mapDictionary(userDict, toType: User.self)
        
        XCTAssert(user.address.city == city, "Pass")
        XCTAssert(user.address.country == country, "Pass")
    }
    
    func testShouldMapOneToManyRelationshipWithoutCustomMapping() {
        var post1Dict = [String: AnyObject]()
        post1Dict["id"] = 1
        post1Dict["title"] = postTitle
        post1Dict["body"] = postBody
        
        var post2Dict = [String: AnyObject]()
        post2Dict["id"] = 2
        post2Dict["title"] = postTitle
        post2Dict["body"] = postBody
        
        var userDict = [String : AnyObject]()
        userDict["posts"] = [post1Dict, post2Dict]
        
        var user = mapper!.mapDictionary(userDict, toType: User.self)
        
        // TODO: Findout why casting to Post errors out, and replace NSManagedObject cast to Post cast
        XCTAssert(user.posts.count == 2, "Pass")
        var post1 = user.posts.allObjects[0] as NSManagedObject
        var post2 = user.posts.allObjects[1] as NSManagedObject
        XCTAssert(post1.valueForKey("id").intValue == 1, "Pass")
        XCTAssert(post2.valueForKey("id").intValue == 2, "Pass")
        XCTAssert(post1.valueForKey("title") as String == postTitle, "Pass")
        XCTAssert(post1.valueForKey("body") as String == postBody, "Pass")
    }
    
    func testShouldMapOneToManyRelationshipWithCustomMapping() {
        var userDict = [String : AnyObject]()
        var postDict = [String: AnyObject]()
        postDict["id"] = 1
        postDict["title"] = postTitle
        postDict["body"] = postBody
        userDict["user_p0$ts"] = [postDict]
        
        mapper![User.self] = [
            "user_p0$ts"   : "posts"]
        var user = mapper!.mapDictionary(userDict, toType: User.self)
        
        XCTAssert(user.posts.count == 1, "Pass")
    }
    
    func testShouldUpdateExistingManagedObjectBasedOnASinleUniqueIdentifier() {
        var userDict = [String : AnyObject]()
        userDict["firstName"] = firstName
        userDict["id"] = 5
        
        var user = mapper!.mapDictionary(userDict, toType: User.self)
        
        mapper!.addUniqueIdentifiersForEntity(User.self, identifiers: "id")
        let newName = "Completely random name"
        userDict["firstName"] = newName
        var newUser = mapper!.mapDictionary(userDict, toType: User.self)
        
        XCTAssert(newUser.objectID == user.objectID, "Pass")
        XCTAssert(newUser.firstName == newName, "Pass")
    }
    
    func testShouldNotUpdateExistingManagedObjectWhenUniqueIdentifiersAreDifferent() {
        var userDict = [String : AnyObject]()
        userDict["firstName"] = firstName
        userDict["id"] = 5
        
        var user = mapper!.mapDictionary(userDict, toType: User.self)
        
        mapper!.addUniqueIdentifiersForEntity(User.self, identifiers: "id")
        let newName = "Completely random name"
        userDict["firstName"] = newName
        userDict["id"] = 6
        var newUser = mapper!.mapDictionary(userDict, toType: User.self)
        
        XCTAssert(newUser.objectID != user.objectID, "Pass")
        XCTAssert(newUser.firstName != user.firstName, "Pass")
    }
    
    func testShouldUpdateExistingRelationManagedObjectBasedOnASinleUniqueIdentifier() {
        var userDict = [String : AnyObject]()
        let addressId = 8
        userDict["id"] = 5
        userDict["address"] = [
            "id" : addressId,
            "city" : city]
        
        var user = mapper!.mapDictionary(userDict, toType: User.self)
        // 1 to many relationship between address and user causes address to be nolified
        // So in order to do the test we need to keep a referebce to address here
        var initialAddress = user.address;
        
        mapper!.addUniqueIdentifiersForEntity(User.self, identifiers: "id")
        mapper!.addUniqueIdentifiersForEntity(Address.self, identifiers: "id")
        let newCity = "Completely random city"
        userDict["id"] = 6
        userDict["address"] = [
            "id" : addressId,
            "city" : newCity]
        var newUser = mapper!.mapDictionary(userDict, toType: User.self)
        
        XCTAssert(newUser.objectID != user.objectID, "Pass")
        XCTAssert(newUser.address.objectID == initialAddress.objectID, "Pass")
        XCTAssert(newUser.address.city == newCity, "Pass")
    }
    
    func testPerformanceWith10UsersWith10PostsPerUserWithoutCustomMapping() {
        
        var userDict = [String : AnyObject]()
        userDict["firstName"] = firstName
        userDict["lastName"] = lastName
        userDict["createdAt"] = createdAt
        userDict["age"] = age
        
        var postDicts = [[String: AnyObject]]()
        
        for i in 1...10 {
            var postDict = [String: AnyObject]()
            postDict["id"] = i
            postDict["title"] = postTitle
            postDict["body"] = postBody
            postDicts.append(postDict)
        }
        
        userDict["posts"] = postDicts
        
        var addressDict = [String : AnyObject]()
        addressDict["city"] = city
        addressDict["countrty"] = country
        userDict["address"] = addressDict
        
        var userDicts = [[String: AnyObject]]()
        
        for i in 1...100 {
            userDicts.append(userDict)
        }
        
        self.measureBlock() {
            self.mapper!.mapDictionaries(userDicts, toType: User.self)
            return
        }
    }
    
    func testPerformanceWith10UsersWith100PostsPerUserWithCustomMapping() {
        
        var userDict = [String : AnyObject]()
        userDict["fName"] = firstName
        userDict["lName"] = lastName
        userDict["someDate"] = createdAt
        userDict["How_Old-I*Am"] = age
        
        var postDicts = [[String: AnyObject]]()
        
        for i in 1...10 {
            var postDict = [String: AnyObject]()
            postDict["i"] = i
            postDict["titl"] = postTitle
            postDict["bod"] = postBody
            postDicts.append(postDict)
        }
        
        userDict["posts"] = postDicts
        
        var addressDict = [String : AnyObject]()
        addressDict["cit"] = city
        addressDict["countr"] = country
        userDict["address"] = addressDict
        
        var userDicts = [[String: AnyObject]]()
        
        for i in 1...100 {
            userDicts.append(userDict)
        }
        
        mapper![User.self] = [
            "fName"         : "firstName",
            "lName"         : "lastName",
            "someDate"      : "createdAt",
            "How_Old-I*Am"  : "age"]
        
        mapper![Address.self] = [
            "cit"           : "city",
            "countr"        : "countrty"]
        
        mapper![Post.self] = [
            "i"             : "id",
            "titl"          : "title",
            "bod"           : "body"]
        
        mapper!.addUniqueIdentifiersForEntity(User.self, identifiers: "id")
        mapper!.addUniqueIdentifiersForEntity(Address.self, identifiers: "id")
        mapper!.addUniqueIdentifiersForEntity(Post.self, identifiers: "id")
        
        self.measureBlock() {
            self.mapper!.mapDictionaries(userDicts, toType: User.self)
            return
        }
    }
    
    // MARK: - Helpers -
    
    func defaultDate() -> NSDate {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.dateFromString(createdAt)
    }
}

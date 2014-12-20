//
//  File.swift
//  Example
//
//  Created by Aryan on 8/31/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import Foundation
import CoreData
import MagicalMapper

public class AlamofireAndMagicalMapperClient {
    
    class var sharedInstance : AlamofireAndMagicalMapperClient {
        struct Static {
            static let instance : AlamofireAndMagicalMapperClient = AlamofireAndMagicalMapperClient()
        }
        
        return Static.instance
    }
    
    let mapper: MagicalMapper
    
    init() {
        mapper = MagicalMapper(managedObjectContext: CoreDataManager.sharedInstance.managedObjectContext!)
        
        setupMapping()
    }
    
    /*
     *  These 2 methods are all we need to make any http call and persist data into core data
     *  Makes http call gets a list of dictionaries and mapps them to the specifid managed object type
     */
    public func fetchObjects <T: NSManagedObject>(method: Method, url: String, type: T.Type, completion: (results: [T]?, error: NSError?) -> ()) -> Request {
        
        return Manager.sharedInstance
            .request(method, url, parameters: nil, encoding: .JSON)
            .responseJSON { request, response, JSON, error in
                
                if let anError = error {
                    completion(results: nil, error: nil)
                }
                else {
                    if JSON == nil || JSON!.count == 0 {
                        completion(results: [], error: nil)
                    }
                    
                    var managedObjects = self.mapper.mapDictionaries(JSON as [[String: AnyObject]], toType: type)
                    completion(results: managedObjects, error: nil)
                }
        }
    }

    /*
     *  These 2 methods are all we need to make any http call and persist data into core data
     *  Makes http call gets a list of dictionaries and mapps them to the specifid managed object type
     */
    public func fetchObject <T: NSManagedObject>(method: Method, url: String, type: T.Type, completion: (results: T?, error: NSError?) -> ()) -> Request {
        
        return Manager.sharedInstance
            .request(method, url, parameters: nil, encoding: ParameterEncoding.JSON)
            .responseJSON {(request, response, JSON, error) in
                
                if let anError = error {
                    completion(results: nil, error: nil)
                }
                else {
                    if JSON == nil {
                        completion(results: nil, error: nil)
                    }
                    
                    var managedObject = self.mapper.mapDictionary(JSON as [String: AnyObject], toType: type)
                    completion(results: managedObject, error: nil)
                }
        }
    }

    
    public func setupMapping () {

        // Setting unique identifier for insert/update records
        
        mapper.addUniqueIdentifiersForEntity(Repository.self, identifiers: "id")
        mapper.addUniqueIdentifiersForEntity(Owner.self, identifiers: "id")
        
        // NOTE
        //
        // If we named our model properties the same as keys coming back from the server
        // the code below would not be needed and ALL mapping would be automatic
        
        mapper[Repository.self] = [
            "open_issues_count" : "openIssuesCount",
            "created_at" : "createdAt"
        ]
        
        mapper[Owner.self] = [
            "login" : "username",
            "avatar_url" : "avatarUrl"
        ]
    }
}

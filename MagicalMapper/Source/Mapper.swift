//
//  Mapper.swift
//  Mapper
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

import Foundation
import CoreData

/*
 *  Null or Default operator
 */
infix operator ||= {}
func ||= <T> (first: T?, second: T) -> T  {
    if let l = first {
        return l
    }
    
    return second
}

/*
 *  Array helper extension
 */
extension Array {
    func contains<T : Equatable>(obj: T) -> Bool {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

// TODO: Use this later
public enum UpsertPolicy {
    case UpdateExistingRecord
    case PurgeExistingRecord
}

public class Mapper {
    
    // MARK: - Initialization -
    
    public typealias SourceDictionary = [String: AnyObject] // [Key : Value]
    private final var uniqueIdentifierDictionary = [String : [String]]() //[Entity : [Keys]]
    private final var dateFormatters = [NSDateFormatter]()
    private final var mappingDictionary = [String : [String : String]]() //[Entity : [Key : Property]]
    private final let managedObjectContext: NSManagedObjectContext
    private final let workingManagedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext;
        self.workingManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        self.workingManagedObjectContext.parentContext = managedObjectContext
        
        addDefaultDateFormatters()
    }
    
    // MARK: - Public Methods -
    
    /*
     *  Takes a dictionary and a MetaType and generates and returns managed objects
     */
    public func mapDictionary <T: NSManagedObject>(dictionary: SourceDictionary, toType: T.Type) -> T {
        let entityName = NSStringFromClass(toType).pathExtension
        return generateManagedObjectFromDictionary(dictionary, entityName: entityName) as T
    }
    
    /*
     *  Takes a dictionary and a MetaType and generates and returns managed objects
     */
    public func mapDictionaries <T: NSManagedObject>(dictionaries: [SourceDictionary], toType: T.Type) -> [T] {
        var result = [T]()
        
        for dictionary in dictionaries {
            result.append(mapDictionary(dictionary, toType: toType))
        }
        
        return result
    }
    
    /*
     *  Adds a dateformatter to be used for string to date conversion
     */
    public func addDateFormatter(dateFormatter: NSDateFormatter) {
        dateFormatters.insert(dateFormatter, atIndex: 0)
    }
    
    /*
     *  Adds Unique identifiers for an entity, and uses these identifiers to determine whether it should insert or upsert
     */
    public func addUniqueIdentifiersForEntity<T: NSManagedObject>(type: T.Type, identifiers: String...) {
        let entityName = NSStringFromClass(type).pathExtension
        validateEntityMapping(entityName, propertyNames: identifiers)
        
        uniqueIdentifierDictionary[entityName] = identifiers
    }
    
    /*
     *  Adds key-to-property mapping for a class
     */
    public func addMapping<T: NSManagedObject>(type: T.Type, mapping: [String : String]) {
        mappingDictionary[(NSStringFromClass(type).pathExtension)] = mapping;
    }
    
    // MARK: - Subscripts -
    
    subscript (type: NSManagedObject.Type) -> Dictionary<String, String>? {
        get {
            return mappingDictionary[NSStringFromClass(type).pathExtension]
        }
        
        set (newValue) {
            mappingDictionary[NSStringFromClass(type).pathExtension] = newValue
        }
    }
    
    // MARK: - Private Methods -
    
    /*
     *  Validates existance of property names for a given entity
     */
    private func validateEntityMapping(entityName: String, propertyNames: [String]) {
        var entityPropertyNames = propertyNamesFromEntity(entityName)
        
        for propertyName in propertyNames {
            if !entityPropertyNames.contains(propertyName) {
                NSException(
                    name: "InvalidPropertyException",
                    reason: "Invalid property '\(propertyName)' on entity '\(entityName)'",
                    userInfo: nil).raise()
            }
        }
    }
    
    /*
     *  Returns a list of property names given an entity name
     */
    private func propertyNamesFromEntity(entityName: String)  -> [String] {
        var propertyNames = [String]();
        var entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: workingManagedObjectContext)
        
        for propertyDescription in entityDescription.properties {
            propertyNames.append(propertyDescription.name)
        }
        
        return propertyNames
    }
    
    /*
     *  Creates and populates a managed object given an entity name and a source dictionart
     */
    private func generateManagedObjectFromDictionary(dictionary: SourceDictionary, entityName: String) -> NSManagedObject {
        
        let managedObject = getNewManagedObject(entityName)
        
        for (key, value) in dictionary {
            autoreleasepool {
                
                let entityMapping = self.mappingDictionary[entityName]
                let propertyToMap = entityMapping?[key] ||= key
                
                // Handle Dictionary
                if let dictionaryValue = value as? SourceDictionary {
                    var relationshipDescription = self.relationshipDescriptionForProperty(propertyToMap, managedObject: managedObject)
                    
                    // If entity is found based on key
                    if let relationship = relationshipDescription {
                        var nestedManagedObject = self.generateManagedObjectFromDictionary(dictionaryValue, entityName: relationship.destinationEntity.name)
                        managedObject.setValue(nestedManagedObject, forKey: propertyToMap)
                    }
                }
                // Handle Array
                else if let arrayValue = value as? Array<AnyObject> {
                    var relationshipDescription = self.relationshipDescriptionForProperty(propertyToMap, managedObject: managedObject)
                    
                    if let relationship = relationshipDescription {
                        var managedObjects = [NSManagedObject]()
                        
                        for dictionary in arrayValue {
                            autoreleasepool {
                                var nestedManagedObject = self.generateManagedObjectFromDictionary(dictionary as SourceDictionary, entityName: relationship.destinationEntity.name)
                                managedObjects.append(nestedManagedObject)
                            }
                        }
                        
                        var managedObjectSet = relationship.ordered
                            ? NSOrderedSet(array: managedObjects)
                            : NSSet(array: managedObjects)
                        
                        managedObject.setValue(managedObjectSet, forKey: propertyToMap)
                    }
                }
                    // Handle everything else
                else {
                    if let attributeDescription = self.attributeDescriptionForProperty(propertyToMap, managedObject: managedObject){
                        // If attribute is date convert before setting value
                        if (attributeDescription.attributeType == .DateAttributeType) {
                            managedObject.setValue(self.dateFromString(value as String), forKey: propertyToMap);
                        }
                        else {
                            managedObject.setValue(value, forKey: propertyToMap);
                        }
                    }
                }
                
            }
        }
        
        // TODO: look for existing managedObject, and perform upsert based on UpsertPolicy
        
        return managedObject
    }
    
    /*
     *  Returns an NSAttributeType given a managedObject and property name
     */
    private func attributeDescriptionForProperty(property: String, managedObject: NSManagedObject) -> NSAttributeDescription? {
        for propertyDescription in managedObject.entity.properties {
            if (propertyDescription.name == property) {
                
                if let attributeDescription = propertyDescription as? NSAttributeDescription {
                    return attributeDescription
                }
                else if let relationshipDescription = propertyDescription as? NSRelationshipDescription {
                    return nil
                }
            }
        }
        
        return nil
    }
    
    /*
     *  Returns an NSRelationshipDescription given a managedObject and property name
     */
    private func relationshipDescriptionForProperty(property: String, managedObject: NSManagedObject) -> NSRelationshipDescription? {
        for propertyDescription in managedObject.entity.properties {
            if (propertyDescription.name == property) {
                
                if let relationshipDescription = propertyDescription as? NSRelationshipDescription {
                    return relationshipDescription
                }
                else {
                    return nil
                }
            }
        }
        
        return nil
    }
    
    /*
     *  Attempts to convert string to date using dateformatters
     */
    private func dateFromString(dateString: String) -> NSDate? {
        for dateFormatter in dateFormatters {
            if let date = dateFormatter.dateFromString(dateString) {
                return date
            }
        }
        
        return nil
    }

    /*
     *  Adding default date formatters to be used for date conversion
     */
    private func addDefaultDateFormatters() {

        func addWithFormat(format: String) {
            var formatter = NSDateFormatter()
            formatter.dateFormat = format
            dateFormatters.append(formatter)
        }
        
        addWithFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ")
        addWithFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
        addWithFormat("MM/dd/yyyy HH:mm:ss aaa")
        addWithFormat("yyyy-MM-dd HH:mm:ss")
        addWithFormat("MM/dd/yyyy")
        addWithFormat("yyyy-MM-dd")
    }
    
    /*
     *  Returns a new instance of NSManagedObject given an entity name
     */
    private func getNewManagedObject(entityName: String) -> NSManagedObject {
        return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: workingManagedObjectContext) as NSManagedObject
    }
    
    /*
     *  Finds and returns and existing managedObject based on provided unique identifiers for entity
     *  Returns nil if either 0 or more than 1 record were found
     */
    private func getExistingManagedObject(managedObject: NSManagedObject) -> NSManagedObject? {
        var predicateKeys = uniqueIdentifierDictionary[managedObject.entity.name]
        
        if let keys = predicateKeys {
            var predicates = [NSPredicate]()
            predicates.append(NSPredicate(format: "SELF != %@", argumentArray: [managedObject]))
            
            for key in keys {
                predicates.append(NSPredicate(format: "%K == %@", argumentArray: [key, managedObject.valueForKey(key)]))
            }
            
            var compundPredicate = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
            var fetchRequest = NSFetchRequest(entityName: managedObject.entity.name)
            fetchRequest.predicate = compundPredicate
            
            var error: NSError?
            var existingObjects = workingManagedObjectContext.executeFetchRequest(fetchRequest, error: &error)
            
            if let anError = error {
                println("Fix this error")
            }
            else {
                if (existingObjects.count == 0) {
                    return nil
                }
                else if (existingObjects.count > 1) {
                    println("Multiple records with the same key were found")
                    return nil
                }
                else {
                    return existingObjects.first as? NSManagedObject
                }
            }
        }
        
        return nil
    }
    
    private func updateManagedObject(managedObject: NSManagedObject, withManagedObject: NSManagedObject) {
        
    }
    
}


//
//  AppDelegate.swift
//  MagicalMapper
//
//  Created by Aryan on 8/31/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        
        var addressDict = [String: AnyObject]()
        addressDict["city"] = "San Francisco"
        addressDict["country"] = "USA"
        
        var userDict = [String : AnyObject]()
        userDict["first__name"] = "Aryan"
        userDict["lastName"] = "Gh"
        userDict["createdAt"] = "05/05/1986"
        userDict["age"] = 12
        userDict["address"] = addressDict
        
        var post1Dict = [String: AnyObject]()
        post1Dict["id"] = 1
        post1Dict["title"] = "Title"
        post1Dict["title"] = "Body"
        
        var post2Dict = [String: AnyObject]()
        post2Dict["id"] = 2
        post2Dict["title"] = "Title 2"
        post2Dict["title"] = "Body 2"
        
        userDict["posts"] = [post1Dict, post2Dict]
        
        
        var mapper = Mapper(managedObjectContext: CoreDataManager.sharedInstance.managedObjectContext!)
        mapper[User.self] = ["first__name" : "firstName"]
        var user = mapper.mapDictionary(userDict, toType: User.self)
        
        println(user)
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


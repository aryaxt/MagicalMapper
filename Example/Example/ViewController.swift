//
//  ViewController.swift
//  Example
//
//  Created by Aryan on 8/31/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController: NSFetchedResultsController?
    @IBOutlet var table: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var moc = CoreDataManager.sharedInstance.managedObjectContext;
        var fetchRequest = NSFetchRequest(entityName: "Repository")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: "Root")
        fetchedResultsController!.delegate = self
        fetchedResultsController?.performFetch(nil)
        
        self.table?.reloadData()
        
        AlamofireAndMagicalMapperClient.sharedInstance.fetchObjects(
            Method.GET,
            url: "https://api.github.com/users/aryaxt/repos?type=owner&per_page=25&sort=updated",
            type: Repository.self) { (results, error) -> () in
                
                println(results)
        }
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var repository: Repository = fetchedResultsController?.fetchedObjects[indexPath.row] as Repository
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("repositoryCell") as UITableViewCell
        cell.textLabel.text = repository.name
        cell.detailTextLabel.text = "Owner: \(repository.owner.username)\n" +
            "Created At: \(repository.createdAt)\n" +
        "Open Issues: \(repository.openIssuesCount)"
        
        return cell
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if let count =  fetchedResultsController?.fetchedObjects?.count {
            return count
        }
        
        return 0
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        table?.reloadData()
    }
    
}


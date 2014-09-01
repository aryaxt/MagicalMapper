//
//  ViewController.swift
//  Example
//
//  Created by Aryan on 8/31/14.
//  Copyright (c) 2014 aryaxt. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    
    var repositories = [Repository]()
    @IBOutlet var table: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        AlamofireAndMagicalMapperClient.sharedInstance.fetchObjects(
            Method.GET,
            url: "https://api.github.com/users/aryaxt/repos",
            type: Repository.self) { (results, error) -> () in
            
            self.repositories = results!
            self.table?.reloadData()
        }
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        var repository: Repository = repositories[indexPath.row]
        println(repository)
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("repositoryCell") as UITableViewCell
        cell.detailTextLabel.text = repository.description
//        cell.detailTextLabel.text =
//            "Author: \(repository.owner.username) \n" +
//            "Created At: \(repository.createdAt) \n" +
//            "Open Issues: \(repository.openIssuesCount)"
        
        return cell
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

}


//
//  PKOBookAddTableViewController.swift
//  CoreDataStudy
//
//  Created by apple on 15/12/30.
//  Copyright © 2015年 www.ixx.com. All rights reserved.
//

import UIKit
import CoreData

class PKOBookAddTableViewController: PKOBookDetailTableViewController {
    
    var addObjectContext: NSManagedObjectContext!
    var delegate: PKOBooksTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置撤回管理器
        self.setUpundoManager()
        //初始化时既为编辑状态
        self.editing = true
    }
    
    deinit{
        self.cleanUpUndoManager()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.delegate!.addViewController(self, isSave: false)
    }
    
    @IBAction func save(sender: AnyObject) {
        self.delegate!.addViewController(self, isSave: true)
    }
    
}

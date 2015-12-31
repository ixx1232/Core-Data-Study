//
//  PKOBooksTableViewController.swift
//  CoreDataStudy
//
//  Created by apple on 15/12/30.
//  Copyright © 2015年 www.ixx.com. All rights reserved.
//

import UIKit
import CoreData

class PKOBooksTableViewController: UITableViewController,NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext?
    //获取数据的控制器
    var fetchedResultsController: NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //为导航栏左边按钮设置编辑按钮
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        //执行获取数据，并处理异常
        var error: NSError? = nil
        do {
            try self.initFetchedResultsController().performFetch()
        } catch let error1 as NSError {
            error = error1
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //设置单元格的信息
    func setCellInfo(cell: UITableViewCell, indexPath: NSIndexPath) {
        let book = self.fetchedResultsController?.objectAtIndexPath(indexPath) as! Book
        NSLog("======\(book.title)")
        cell.textLabel!.text = book.title
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //分组数量
        return self.fetchedResultsController!.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //每个分组的数据数量
        let section = self.fetchedResultsController!.sections![section] as NSFetchedResultsSectionInfo
        return section.numberOfObjects
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        // 为列表Cell赋值
        self.setCellInfo(cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //分组表头显示
        return self.fetchedResultsController!.sections![section].name
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    // 自定义编辑单元格时的动作，可编辑样式包括UITableViewCellEditingStyleInsert（插入）、UITableViewCellEditingStyleDelete（删除）。
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //删除sqlite库中对应的数据
            let context = self.fetchedResultsController?.managedObjectContext
            context!.deleteObject(self.fetchedResultsController?.objectAtIndexPath(indexPath) as! NSManagedObject)
            //删除后要进行保存
            let error: NSError? = nil
            if context?.save(&error) == nil {
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        } else if editingStyle == .Insert {
        }
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // 移动单元格时不要重新排序
        return false
    }
    
    // MARK: - NSFetchedResultsController delegate methods to respond to additions, removals and so on.
    
    //初始化获取数据的控制器
    func initFetchedResultsController() ->NSFetchedResultsController
    {
        if self.fetchedResultsController != nil {
            return self.fetchedResultsController!
        }
        // 创建一个获取数据的实例，用来查询实体
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Book", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // 创建排序规则
        let authorDescriptor = NSSortDescriptor(key: "author", ascending: true)
        let titleDescriptor = NSSortDescriptor(key: "title", ascending: true)
        let sortDescriptors = [authorDescriptor, titleDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // 创建获取数据的控制器，将section的name设置为author，可以直接用于tableViewSourceData
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "author", cacheName: "Root")
        fetchedResultsController.delegate = self
        self.fetchedResultsController = fetchedResultsController
        return fetchedResultsController
    }
    
    //通知控制器即将开始处理一个或多个的单元格变化，包括添加、删除、移动或更新。在这里处理变化时对tableView的影响，例如删除sqlite数据时同时要删除tableView中对应的单元格
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
  
        switch(type) {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Update:
            self.setCellInfo(self.tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    //通知控制器即将开始处理一个或多个的分组变化，包括添加、删除、移动或更新。
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch(type) {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Update:
            break
        case .Move:
            break
        }
    }
    
    //通知控制器即将有变化
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        //tableView启动变更，需要endUpdates来结束变更，类似于一个事务，统一做变化处理
        self.tableView.beginUpdates()
    }
    
    //通知控制器变化完成
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    
    //通过segue跳转前所做的工作
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //明细查询页面
        if segue.identifier == "BookDetail" {
            //将所选择的当前数据赋值给所打开页面的控制器
            let bookDetailTableViewController = segue.destinationViewController as! PKOBookDetailTableViewController
            let currentRow = tableView.indexPathForSelectedRow
            let book = self.fetchedResultsController?.objectAtIndexPath(currentRow!) as! Book
            bookDetailTableViewController.book = book
        }
        else if segue.identifier == "BookAdd"{
            let navigationController = segue.destinationViewController as! UINavigationController
            let bookAddTableViewController = navigationController.topViewController as! PKOBookAddTableViewController
            
            //这里注意要new一个NSManagedObjectContext，然后将self.fetchedResultsController?.managedObjectContext为其父context，这样我们在addView操作时就不会对self.fetchedResultsController?.managedObjectContext产生影响
            let addContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
            addContext.parentContext = self.fetchedResultsController?.managedObjectContext
            
            let newBook = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: addContext) as! Book
            newBook.author = "Author1"//这里要初始化信息，不然为空的化swift会报错
            newBook.title = "Titel1"
            newBook.theDate = NSDate()
            
            bookAddTableViewController.book = newBook
            bookAddTableViewController.addObjectContext = addContext
            bookAddTableViewController.delegate = self
        }
    }
    
    // MARK: - Add controller delegate
    
    func addViewController(controller:PKOBookAddTableViewController, isSave: Bool){
        
        if isSave {
            NSLog("===dismissViewControllerAnimated 1===")
            var error: NSError? = nil
            do {
                try controller.addObjectContext.save()
            } catch let error1 as NSError {
                error = error1
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
            NSLog("===dismissViewControllerAnimated 2===")
            if self.fetchedResultsController?.managedObjectContext.save() == nil {
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
        NSLog("===dismissViewControllerAnimated 3===")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
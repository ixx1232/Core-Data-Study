//
//  AppDelegate.swift
//  CoreDataStudy
//
//  Created by apple on 15/12/28.
//  Copyright © 2015年 www.ixx.com. All rights reserved.
//



/**
 (1)NSManagedObjectContext（数据上下文）
     操作实际内容（操作持久层）
     作用：插入数据，查询数据，删除数据
 (2)NSManagedObjectModel（数据模型）
     数据库所有数据结构，包含各实体的定义信息，相当于表
     作用：添加实体的属性，建立属性之间的关系
 (3)NSPersistentStoreCoordinator（持久化存储连接器）
     相当于数据库的连接器
     作用：设置数据存储的名字，位置，存储方式，和存储时机
 (4)NSManagedObject（数据记录）
     相当于数据库中的表记录
 (5)NSFetchRequest（数据请求）
     相当于查询语句
 (6)NSEntityDescription（实体结构）
     相当于表结构
 (7)后缀为.xcdatamodeld的文件
     里面是.xcdatamodel文件，用数据模型编辑器编辑
     编译后为.momd或.mom文件
 
*/

import UIKit
import CoreData

@UIApplicationMain
class CoreDataBooksAppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //app开始启动时调用
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        var navigationViewController = self.window?.rootViewController as! UINavigationController
        var booksTableViewController = navigationViewController.viewControllers[0] as! PKOBooksTableViewController
        booksTableViewController.managedObjectContext = self.managedObjectContext
        return true
    }
    
    //app将要入非活动状态时调用，在此期间，应用程序不接收消息或事件，比如来电话了；保存数据
    func applicationWillResignActive(application: UIApplication) {
        self.saveContext()
    }
    
    //app被推送到后台时调用，所以要设置后台继续运行，则在这个函数里面设置即可；保存数据
    func applicationDidEnterBackground(application: UIApplication) {
        self.saveContext()
    }
    
    //app从后台将要重新回到前台非激活状态时调用
    func applicationWillEnterForeground(application: UIApplication) {
    }
    
    //app进入活动状态执行时调用
    func applicationDidBecomeActive(application: UIApplication) {
    }
    
    //app将要退出是被调用，通常是用来保存数据和一些退出前的清理工作；保存数据
    func applicationWillTerminate(application: UIApplication) {
        self.saveContext()
    }
    
    // MARK: - Core Data stack ，coreData所用
    
    //应用程序沙箱下的Documents目录路径，自动生成，无需修改
    lazy var applicationDocumentsDirectory: NSURL = {
        //NSSearchPathDirectory.DocumentDirectory，可以省略前面的类名
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    //NSManagedObjectModel（数据模型），数据库所有模型，包含各实体的定义信息
    //作用：添加实体的属性，建立属性之间的关系
    //操作方法：视图编辑器，或代码
    lazy var managedObjectModel: NSManagedObjectModel = {
        //xcdatamodeld编译后为momd
        let modelURL = NSBundle.mainBundle().URLForResource("PKO_Sample_CoreDataBooks", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        
    }()
    
    //NSPersistentStoreCoordinator（持久化存储连接器），相当于数据库的连接器，大部分都是自动生成，可以自行调整
    //作用：设置数据存储的名字，位置，存储方式，和存储时机
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var fileManager = NSFileManager.defaultManager()
        //sqlite的库路径
        var storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("PKO_swift_coreDataBooks.sqlite")
        //应用程序沙箱目录中的sqlite文件是否已经存在,如果它不存在(即应用程序第一次运行),则将包中的sqlite文件复制到沙箱文件目录。即加载初始化库数据
        //若想重新在模拟器（simulator）中重新使用该sqlite初始化，点击IOS Simulator->Reset Contents and Settings，重置模拟器即可
        if !fileManager.fileExistsAtPath(storeURL.path!){
            var defaultStoreURL = NSBundle.mainBundle().URLForResource("PKO_swift_coreDataBooks", withExtension: "sqlite")
            if (defaultStoreURL != nil) {
                do {
                    try fileManager.copyItemAtURL(defaultStoreURL!, toURL: storeURL)
                } catch _ {
                }
            }
        }
        //NSMigratePersistentStoresAutomaticallyOption是否自动迁移数据，
        //NSInferMappingModelAutomaticallyOption是否自动创建映射模型
        var options = [NSMigratePersistentStoresAutomaticallyOption:true, NSInferMappingModelAutomaticallyOption:true]
        // 根据managedObjectModel创建coordinator
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var error: NSError? = nil
        // 指定持久化存储的数据类型，默认的是NSSQLiteStoreType，即SQLite数据库
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        return coordinator
    }()
    
    //NSManagedObjectContext（数据上下文），操作实际内容（操作持久层）
    //作用：插入数据，查询数据，删除数据
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    //持久化数据，数据落地
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
}


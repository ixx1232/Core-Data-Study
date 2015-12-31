//
//  PKOBookDetailTableViewController.swift
//  CoreDataStudy
//
//  Created by apple on 15/12/30.
//  Copyright © 2015年 www.ixx.com. All rights reserved.
//

import UIKit

class PKOBookDetailTableViewController: UITableViewController {
    
    var book: Book!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //加载view时调用
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("==viewDidLoad==")
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //编辑的时候允许选择
        self.tableView.allowsSelectionDuringEditing = true
        
        //监听到NSCurrentLocaleDidChangeNotification时，即系统语言变化时触发的方法，与removeObserver是一对
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeChanged:", name: NSCurrentLocaleDidChangeNotification, object: nil)
    }
    
    //析构方法
    deinit{
        NSLog("==deinit==")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSCurrentLocaleDidChangeNotification, object: nil)
    }
    
    
    /*
    The view controller must be first responder in order to be able to receive shake events for undo. It should resign first responder status when it disappears.指定是否可以时第一响应者，通俗来讲就是焦点
    */
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    //view显示时设置焦点
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    
    //view销毁前取消焦点
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignFirstResponder()
    }
    
    //视图即将可见时调用，每次显示view就会调用
    override func viewWillAppear(animated: Bool) {
        NSLog("==viewWillAppear==")
        super.viewWillAppear(animated)
        
        //重载数据
        self.updateInterface()
        //改变右侧按钮状态
        self.updateRightBarButtonItemState()
    }
    
    //设置为编辑模式时调用
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        NSLog("==setEditing==\(editing)")
        
        self.navigationItem.setHidesBackButton(editing, animated: animated)
        
        //编辑状态时设置撤销管理器
        if(editing){
            self.setUpundoManager()
        }else
            //非编辑状态时取消撤销管理器并保存数据
        {
            self.cleanUpUndoManager()
            let error: NSError? = nil
            if (self.book.managedObjectContext?.save(&error) == nil) {
                NSLog("Unresolved error \(error), \(error?.userInfo)")
                abort()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //更新数据
    func updateInterface() {
        self.authorLabel.text = self.book.author
        self.titleLabel.text = self.book.title
        self.dateLabel.text = self.dateFormatter().stringFromDate(self.book.theDate)
    }
    
    func updateRightBarButtonItemState() {
        NSLog("==updateRightBarButtonItemState==")
        // 如果实体对象在保存状态，则允许右侧按钮
        var error: NSError? = nil
        self.navigationItem.rightBarButtonItem?.enabled = self.book.validateForUpdate(&error)
    }
    
    
    // MARK: - Table view data source
    
    //点击编辑按钮时的row编辑样式，默认delete，row前有一个删除标记，这里用none，没有任何标记
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    //点击编辑按钮时row是否需要缩进，这里不需要
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    //在行将要选择的时候执行。通常，你可以使用这个方法来阻止选定特定的行。返回结果是选择的行
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if(self.editing){
            return indexPath
        }
        return nil
    }
    
    //在选择行后执行，这里是编辑状态选中一行时创建一个编辑页面
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(self.editing){
            self.performSegueWithIdentifier("DetailToEdit", sender: self)
        }
    }
    
    // MARK: - Undo support
    
    //设置撤回管理器
    func setUpundoManager() {
        if self.book.managedObjectContext?.undoManager == nil {
            self.book.managedObjectContext?.undoManager =  NSUndoManager()
            self.book.managedObjectContext?.undoManager?.levelsOfUndo = 3//撤销最大数
        }
        
        let bookUndoManager = self.book.managedObjectContext?.undoManager
        
        //监听撤回和取消撤回
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "undoManagerDidUndo:", name: NSUndoManagerDidUndoChangeNotification, object: bookUndoManager)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "undoManagerDidRedo:", name: NSUndoManagerDidRedoChangeNotification, object: bookUndoManager)
    }
    
    //取消撤回管理器
    func cleanUpUndoManager() {
        let bookUndoManager = self.book.managedObjectContext?.undoManager
        
        //移除撤回和取消撤回监听
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUndoManagerWillUndoChangeNotification, object: bookUndoManager)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUndoManagerWillRedoChangeNotification, object: bookUndoManager)
        
        //置空context的撤回管理器
        self.book.managedObjectContext?.undoManager = nil
    }
    
    //监听到撤回触发，重载数据和导航右侧按钮状态
    func undoManagerDidUndo(notification : NSNotification){
        NSLog("==undoManagerDidUndo==")
        //重载数据
        self.updateInterface()
        //改变右侧按钮状态
        self.updateRightBarButtonItemState()
    }
    
    //监听到取消撤回触发，重载数据和导航右侧按钮状态
    func undoManagerDidRedo(notification : NSNotification){
        NSLog("==undoManagerDidRedo==")
        //重载数据
        self.updateInterface()
        //改变右侧按钮状态
        self.updateRightBarButtonItemState()
    }
    
    // MARK: - Date Formatter
    
    //日期格式化
    func dateFormatter() -> NSDateFormatter{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        return dateFormatter
    }
    
    // MARK: - Navigation
    
    //通过segue跳转前所做的工作
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "DetailToEdit"){
            let bookEditViewController = segue.destinationViewController as! PKOBookEditViewController
            
            bookEditViewController.editedObject = self.book
            //根据选择的不同行为编辑view赋不同的值
            switch(self.tableView.indexPathForSelectedRow!.row) {
            case 0:
                bookEditViewController.editedFieldKey = "title"
                bookEditViewController.editedFieldName = "title"
            case 1:
                bookEditViewController.editedFieldKey = "author"
                bookEditViewController.editedFieldName = "author"
            case 2:
                bookEditViewController.editedFieldKey = "theDate"
                bookEditViewController.editedFieldName = "theDate"
            default:
                break
            }
        }
    }
    
    // MARK: - Locale changes
    
    //监听到语言变化时，重载数据
    func localeChanged(notification : NSNotification) {
        NSLog("==localeChanged==")
        //重载数据
        self.updateInterface()
    }
    
}
//
//  Book.swift
//  CoreDataStudy
//
//  Created by apple on 15/12/30.
//  Copyright © 2015年 www.ixx.com. All rights reserved.
//

import UIKit
import CoreData

//@objc(Book)
class Book: NSManagedObject {

    @NSManaged var author: String
    @NSManaged var title: String
    @NSManaged var theDate: NSDate
}

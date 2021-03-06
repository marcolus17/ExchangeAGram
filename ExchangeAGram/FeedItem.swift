//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Nicholas Markworth on 5/14/15.
//  Copyright (c) 2015 Nick Markworth. All rights reserved.
//

import Foundation
import CoreData

// NOTE: remember to remove the extra text in the Class property for the datamodel
@objc(FeedItem)
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData
    // NOTE: When we added this attribute we needed to delete the existing
    // FeedItem class and create a new one
    @NSManaged var thumbnail: NSData
    @NSManaged var uniqueID: String

}

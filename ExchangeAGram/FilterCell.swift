//
//  FilterCell.swift
//  ExchangeAGram
//
//  Created by Nicholas Markworth on 5/13/15.
//  Copyright (c) 2015 Nick Markworth. All rights reserved.
//

import Foundation
import UIKit

class FilterCell: UICollectionViewCell {

    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        // Use contentView instead of self.view
        contentView.addSubview(imageView)
    }
    
    // Need this as a desegnated initializer if the custom initializer is not used
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not beed implemented")
    }
}
//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Nicholas Markworth on 5/13/15.
//  Copyright (c) 2015 Nick Markworth. All rights reserved.
//

import UIKit

// This ViewController was written completely in code (no storyboard implementation)
class FilterViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Holds the currently chosen item
    var thisFeedItem: FeedItem!
    // A CollectionView that displays all of the filter options
    var collectionView: UICollectionView!
    // Holds the filters
    var filters: [CIFilter] = []
    
    // Expensive to make, does the processing of adding the filter
    var context: CIContext = CIContext(options: nil)
    
    // Used to change the properties of our filters
    let kSaturation = 0.5
    let kIntensity = 0.7

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Determines how the items in the CollectionView are organized
        let layout = UICollectionViewFlowLayout()
        // Gives the layout borders
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        // The size of each item in the CollectionView
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = UIColor.whiteColor()
        
        // Have to register the FilterCell class so that the CollectionView knows which cell to use
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        self.view.addSubview(collectionView)
        
        // Add the filters to the array
        self.filters = photoFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UICollectionViewDataSource Functions
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! FilterCell
        // Grab the selected photo and apply the currently selected filter
        cell.imageView.image = filteredImageFromImage(thisFeedItem.image, filter: filters[indexPath.row])
        return cell
    }
    
    // Return an array of the CIFilters that Apple has provided
    // Reference: https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
    func photoFilters() -> [CIFilter] {
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        // Edit filter properties
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(kSaturation, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        // RGBA values for the upper and lower end of the range
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        // Add a composite filter - a mix between two filters
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
    }
    
    // A helper function that saves a filter to our image
    func filteredImageFromImage(imageData: NSData, filter: CIFilter) -> UIImage {
        
        // CIImage holds the data of the image
        let unfilteredImage = CIImage(data: imageData)
        // Pass the unfiltered image to the filter
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        // Grab the filtered image data
        let filteredImage: CIImage = filter.outputImage
        
        // Used to create an appropriately sized and optimized image for our CollectionView
        let extent = filteredImage.extent()
        // Creates a sample image (bitmap) using the filtered image and the extent
        let cgImage: CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        
        // Create the UIImage to return
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage!
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
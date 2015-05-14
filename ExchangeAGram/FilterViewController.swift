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
    
    // Optimization - Holds a placeholder image for our CollectionView cells
    let placeHolderImage = UIImage(named: "Placeholder")
    
    let tmpDirectory = NSTemporaryDirectory()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Determines how the items in the CollectionView are organized
        let layout = UICollectionViewFlowLayout()
        // Gives the layout borders
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        // The size of each item in the CollectionView
        layout.itemSize = CGSize(width: 140.0, height: 140.0)
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
        
        // Optimization - Prevents the CollectionView from adding a filter to our image each time we scroll, etc.
        if cell.imageView.image == nil {
            // Optimization - Using the property to prevent the creation of the placeholder image over and over again
            cell.imageView.image = placeHolderImage
            
            // Use Grand Central Dispatch (GCD) to apply filters without interrupting the main thread
            // NOTE: Always make UI changes on the main thread!
            
            // Create a new queue
            let filterQueue: dispatch_queue_t = dispatch_queue_create("filter queue", nil)
            
            // Run this block of code when the queue is ready to be processed on a background thread
            dispatch_async(filterQueue, { () -> Void in
                // Apply the filter to the currently selected photo
                // Optimization - Apply the filter to the thumbnail instead of the high res photo
                    // let filterImage = self.filteredImageFromImage(self.thisFeedItem.thumbnail, filter: self.filters[indexPath.row])
                // Use the cached thumbnail instead of recreating it
                let filterImage = self.getCachedImage(indexPath.row)
                
                // Jump back to the main thread to apply the UI changes
                // The ImageViews will populate over time because the main thread is waiting for the filters to finish being applied
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.imageView.image = filterImage
                })
            })
        }
        
        return cell
    }
    
    // Apply the filtered image and save it to CoreData
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
        self.thisFeedItem.image = imageData
        let thumbnailData = UIImageJPEGRepresentation(filterImage, 0.1)
        self.thisFeedItem.thumbnail = thumbnailData
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        self.navigationController?.popViewControllerAnimated(true)
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
    
    // MARK: - Caching Functions
    
    // Cache the filtered thumbnail image
    // Image number = indexPath.row
    func cacheImage(imageNumber: Int) {
        let fileName = "\(thisFeedItem.uniqueID)\(imageNumber)"
        // Create the file path
        let uniquePath = tmpDirectory.stringByAppendingPathComponent(fileName)
        // Check to see if the filtered thumbnail already exists in the cache
        if !NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            // Add a filter to the thumbnail
            let thumbnailData = self.thisFeedItem.thumbnail
            let filter = self.filters[imageNumber]
            // Get the UIImage
            let image = filteredImageFromImage(thumbnailData, filter: filter)
            // Get a JPEG representation for the image and write it to the file path
            // Atomically set to true means that the JPEG is written to a backup file, and if
            // there are no errors it is then saved to the direct path
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        }
    }
    
    // Grab a cached image from the cache
    func getCachedImage(imageNumber: Int) -> UIImage {
        let fileName = "\(thisFeedItem.uniqueID)\(imageNumber)"
        let uniquePath = tmpDirectory.stringByAppendingPathComponent(fileName)
        
        var image: UIImage
        
        // Check to see if the filtered thumbnail already exists in the cache
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            image = UIImage(contentsOfFile: uniquePath)!
        }
        else {
            self.cacheImage(imageNumber)
            image = UIImage(contentsOfFile: uniquePath)!
        }
        
        return image
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

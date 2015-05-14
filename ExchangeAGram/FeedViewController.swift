//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Nicholas Markworth on 5/12/15.
//  Copyright (c) 2015 Nick Markworth. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

// Add the DataSource and Delegates. Make sure to add connections in SB for UICollectionView
class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // UI Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var photosBarButtonItem: UIBarButtonItem!
    
    var feedArray: [AnyObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Perform fetch request
        let request = NSFetchRequest(entityName: "FeedItem")
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        feedArray = managedObjectContext.executeFetchRequest(request, error: nil)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UICollectionViewDataSource Functions
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // The number of photos in the CollectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedArray.count
    }
    
    // Add the photos to the CollectionView
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Create a new FeedCell for putting in our CollectionView
        var cell: FeedCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! FeedCell
        
        // Grab each photo in the array and add it to the CollectionView
        let thisItem = feedArray[indexPath.row] as! FeedItem
        cell.imageView.image = UIImage(data: thisItem.image)
        cell.captionLabel.text = thisItem.caption
        
        return cell
    }
    
    // Chooses a photo in the CollectionView
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let thisItem = feedArray[indexPath.row] as! FeedItem
        
        // Create a new FilterViewController for adding a filter to our photo
        var filterVC = FilterViewController()
        filterVC.thisFeedItem = thisItem
        
        self.navigationController?.pushViewController(filterVC, animated: false)
    }
    
    // MARK: - UIImagePickerControllerDelegate Functions
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        // Save a high res version of our image
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        // Save a thumbnail version that is 1/10th the size
        let thumbNailData = UIImageJPEGRepresentation(image, 0.1)
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext!)
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
        feedItem.image = imageData
        feedItem.caption = "test caption"
        feedItem.thumbnail = thumbNailData
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        
        feedArray.append(feedItem)
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        self.collectionView.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // Show the image picker when the camera button is pressed
    @IBAction func cameraBarButtonItemPressed(sender: UIBarButtonItem) {
        // Check to see if the camera is available
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            // UIImagePickerController is a subclass of UINavigationController; used to access a phone's images and movies
            var cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            
            // The types of media the ImagePicker is going to access
            let mediaTypes: [AnyObject] = [kUTTypeImage] // typedefs to CFString: image
            cameraController.mediaTypes = mediaTypes
            // Don't allow the user to edit the photos
            cameraController.allowsEditing = false
            
            self.presentViewController(cameraController, animated: true, completion: nil)
        }
        else {
            Alert.showAlertWithText(viewController: self, header: "Camera Error", message: "The camera is not available.")
            photosBarButtonItemPressed(photosBarButtonItem)
        }
    }
    
    // Show the photo library when the photos button is pressed
    @IBAction func photosBarButtonItemPressed(sender: UIBarButtonItem) {
        // Check if the photo library is available
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            var photoLibraryController = UIImagePickerController()
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            let mediaTypes: [AnyObject] = [kUTTypeImage]
            photoLibraryController.mediaTypes = mediaTypes
            photoLibraryController.allowsEditing = false
            
            // Show the photo library
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
        }
        else {
            Alert.showAlertWithText(viewController: self, header: "Photo Library Error", message: "The photo library is not available.")
        }
    }

}

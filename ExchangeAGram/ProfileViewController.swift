//
//  ProfileViewController.swift
//  ExchangeAGram
//
//  Created by Nicholas Markworth on 5/14/15.
//  Copyright (c) 2015 Nick Markworth. All rights reserved.
//

import UIKit
import FBSDKLoginKit

// RESOURCE: - Facebook Login https://developers.facebook.com/docs/facebook-login/ios/v2.3#access-tokens
class ProfileViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.fbLoginButton.delegate = self
        // Gives us access to the user's Facebook profile picture, email, and friends
        self.fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        // Allows us to publish our photos to the user's Facebook account
        self.fbLoginButton.publishPermissions = ["publish_actions"]
        
        // Allows the profile to track the currentAccessToken
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        // Create an event handler that runs when the Facebook profile changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fbProfileChanged:", name: FBSDKProfileDidChangeNotification, object: nil)
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            // User is already logged in and permissions have been granted
            // Force the profile change event handler
            self.fbProfileChanged(self)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - FBSDKLoginButtonDelegate Functions
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            println("\(error.localizedDescription)")
        }
        else if !result.isCancelled {
            println("Login cancelled")
        }
        else {
            println("Logged in")
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // Implementation
    }
    
    // MARK: - FBProfileDidChangeNotification Event Handler
    func fbProfileChanged(sender: AnyObject) {
        // Get the current FB profile
        let fbProfile = FBSDKProfile.currentProfile()
        
        if fbProfile != nil {
            // Fetch, format, and display the profile picture
            let strProfilePicURL = fbProfile.imagePathForPictureMode(FBSDKProfilePictureMode.Square, size: self.profileImageView.frame.size)
            let url = NSURL(string: strProfilePicURL, relativeToURL: NSURL(string: "http://graph.facebook.com/"))
            // Change the URL data into image data
            let imageData = NSData(contentsOfURL: url!)
            // Change the image data into a UIImage
            let image = UIImage(data: imageData!)
            
            // Set our name label to be the name of the FB user
            self.nameLabel.text = fbProfile.name
            self.profileImageView.image = image
            
            // Unhide the ImageView and the name label
            self.nameLabel.hidden = false
            self.profileImageView.hidden = false
        }
        else {
            // Clear our the data in our views
            self.nameLabel.text = ""
            self.profileImageView.image = UIImage(named: "Placeholder")
            
            // Hide our views
            self.nameLabel.hidden = true
            self.profileImageView.hidden = true
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func mapViewButtonPressed(sender: UIButton) {
        performSegueWithIdentifier("mapSegue", sender: nil)
    }

}

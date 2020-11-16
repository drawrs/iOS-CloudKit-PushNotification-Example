//
//  ViewController.swift
//  iOS-CloudKit-PushNotification-Example
//
//  Created by Rizal Hilman on 16/11/20.
//

import UIKit
import CloudKit

class ViewController: UIViewController {

    // Init cloudkit container
    let database = CKContainer(identifier: "iCloud.www.khilman.com.iOS-CloudKit-PushNotification-Example").publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func actionSubscribe(_ sender: Any) {
        
        // Subscribe with predicate
        // Only if the content contains x string
        // NOTE: To be able to use custom predicate, the field (let say "content") must be QUERYABLE
        // let predicate = NSPredicate(format: "content == %@", "promotion")
        
        // Subscribe all records
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        
        // firesOnRecordCreation -> trigerred when new record created
        let subscription = CKQuerySubscription(recordType: "Notifications", predicate: predicate, options: .firesOnRecordCreation)
    
        let info = CKSubscription.NotificationInfo()
        
        // this will use the 'title' field in the Record type 'notifications' as the title of the push notification
        info.titleLocalizationKey = "%1$@"
        info.titleLocalizationArgs = ["title"]
        
        // if you want to use multiple field combined for the title of push notification
        // info.titleLocalizationKey = "%1$@ %2$@" // if want to add more, the format will be "%3$@", "%4$@" and so on
        // info.titleLocalizationArgs = ["title", "subtitle"]
        // this will use the 'content' field in the Record type 'notifications' as the content of the push notification
        info.alertLocalizationKey = "%1$@"
        info.alertLocalizationArgs = ["content"]
        
        // increment the red number count on the top right corner of app icon
        info.shouldBadge = true
        
        // use system default notification sound
        info.soundName = "default"
        
        subscription.notificationInfo = info
        
        // Save the subscription to Public Database in Cloudkit
        database.save(subscription, completionHandler: { subscription, error in
            if error == nil {
                // Subscription saved successfully
                print("Subscribed!")
            } else {
                // Error occurred
                print("Failed to subscribe", error?.localizedDescription)
            }
        })
    }
    
    @IBAction func actionUnsubscribe(_ sender: Any) {
        // fetch all subscriptions by the user and delete them
        database.fetchAllSubscriptions(completionHandler: { subscriptions, error in
          if error != nil {
            // failed to fetch all subscriptions, handle error here
            // end the function early
            print("failed to fetch all subscriptions: ", error?.localizedDescription)
            return
          }

          if let subscriptions = subscriptions {
            for subscription in subscriptions {
              CKContainer.default().publicCloudDatabase.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: { string, error in
                if(error != nil){
                    // deletion of subscription failed, handle error here
                    print("Deletion of subscription failed: ", error?.localizedDescription)
                }
                print("Canceled")
              })
            }
          }

        })
    }
    
    
}


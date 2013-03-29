//
//  InitialViewController.h
//  Shredder
//
//  Created by Shredder on 12/02/2013.
//
//

#import <UIKit/UIKit.h>
#import "SignUpPhoneNumberViewController.h"
#import "ContactsDatabaseManager.h"


// This controller initialises the application

@interface InitialViewController : UIViewController <SignUpPhoneNumberViewControllerDelegate>

// 1. Check if a signed in user is present
-(void)checkForSignedInUser;

// 2. Obtain access to contacts database
@property (nonatomic, strong) ContactsDatabaseManager *contactsDatabaseManager;

// 3. Launch Inbox View

@end

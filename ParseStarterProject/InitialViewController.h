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


// View Controller which presents SignUp View route on first run of app

@interface InitialViewController : UIViewController <SignUpPhoneNumberViewControllerProtocol>

@property (nonatomic, strong) ContactsDatabaseManager *contactsDatabaseManager;

-(void)directLoggedInOrNotLoggedInUserRespectively;

@end

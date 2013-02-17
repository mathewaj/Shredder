//
//  ContactsViewController.h
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ContactsDatabaseManager.h"
#import "ShredderUser.h"

@protocol ContactsViewControllerDelegate <NSObject>

// Control: Choose Receiver and inform delegate
-(void)didSelectShredderUser:(ShredderUser *)contact;

@end

@interface ContactsViewController : UIViewController <MFMessageComposeViewControllerDelegate>

// Model: Contacts Database
@property (nonatomic, strong) ContactsDatabaseManager *contactsDatabaseManager;

// Model: Contacts Array
@property (nonatomic, strong) NSArray *contacts;

// Control: Invite Non-Shredder User
-(void)inviteNonShredderUser;

@property (nonatomic, weak) id <ContactsViewControllerDelegate> delegate;

@end

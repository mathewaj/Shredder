//
//  InboxViewController.h
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import <UIKit/UIKit.h>
#import "ContactsDatabaseManager.h"
#import "ContactsViewController.h"
#import "MGScrollView.h"

@interface InboxViewController : UIViewController <ContactsViewControllerDelegate>

// Model: Messages Array from Parse DB
@property(nonatomic, strong) NSArray *messagesArray;

// Model: MessagePermissions Array from Parse DB
@property(nonatomic, strong) NSArray *reportsArray;

// Model: Contacts Database
@property (nonatomic, strong) ContactsDatabaseManager *contactsDatabaseManager;

// Control: Open Settings Page
-(IBAction)presentSettingsPage:(id)sender;

// Control Model: Compose or Shred
@property (nonatomic, assign, getter=isComposeRequest) BOOL composeRequest;

// Control: Compose Message
-(IBAction)presentComposeMessagePage:(id)sender;

// Control: View Message Detail
-(IBAction)viewMessageDetail:(id)sender;

// Control: View Message Permission Detail
// TO BE IMPLEMENTED

// View: Scroll View
@property (nonatomic, strong) MGScrollView *scrollView;

@end

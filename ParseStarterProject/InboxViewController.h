//
//  InboxViewController.h
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import <UIKit/UIKit.h>

@interface InboxViewController : UIViewController

// Model: Messages Array from Parse DB
@property(nonatomic, strong) NSArray *messagesArray;

// Model: MessagePermissions Array from Parse DB
@property(nonatomic, strong) NSArray *messagePermissionsArray;

// Control: Open Settings Page
-(IBAction)presentSettingsPage:(id)sender;

// Control: Open Contacts Selection Page
-(IBAction)presentContactsSelectionPage:(id)sender;

// Control: View Message Detail
-(IBAction)viewMessageDetail:(id)sender;

// Control: View Message Permission Detail
// TO BE IMPLEMENTED

@end

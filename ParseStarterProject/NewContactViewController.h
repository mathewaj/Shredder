//
//  NewContactViewController.h
//  ParseStarterProject
//
//  Created by Alan Mathews on 19/11/2012.
//
//

#import <UIKit/UIKit.h>
#import "Contact+Create.h"
#import <MessageUI/MessageUI.h>

// Typedef a block called ParseReturned which receives a contact and returns a BOOL
//typedef void (^ParseReturned) (BOOL signedUp);

@interface NewContactViewController : UITableViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate>

// Model is a contact
@property (nonatomic, readwrite) Contact *contact;


// Model is the contacts database
@property (nonatomic, strong) UIManagedDocument *contactsDatabase;

@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *contactNameCell;
@property (weak, nonatomic) IBOutlet UILabel *contactEmailLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *contactEmailCell;
@property (weak, nonatomic) IBOutlet UILabel *contactInviteLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *contactInviteCell;
@property (strong, nonatomic) NSNumber *inviteCellRowHeight;

@property (strong, nonatomic) UITextField *contactNameTextField;
@property (strong, nonatomic) UITextField *contactEmailTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

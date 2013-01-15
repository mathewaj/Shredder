//
//  ContactDetailViewController.h
//  ParseStarterProject
//
//  Created by Alan Mathews on 16/11/2012.
//
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import <MessageUI/MessageUI.h>

// Typedef a block called ParseReturned which receives a contact and returns a BOOL
typedef void (^ParseReturned) (BOOL signedUp);

@interface ContactDetailViewController : UITableViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate>

// Model is a contact
@property (nonatomic, readwrite) Contact *contact;
@property (nonatomic, strong) UIManagedDocument *contactsDatabase;

@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *contactEmailTextField;
@property (weak, nonatomic) IBOutlet UITableViewCell *contactEmailCell;
@property (weak, nonatomic) IBOutlet UILabel *contactInviteLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *contactInviteCell;
@end

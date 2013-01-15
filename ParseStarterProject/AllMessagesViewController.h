//
//  AllMessagesViewController.h
//  ParseStarterProject
//
//  Created by Alan Mathews on 17/11/2012.
//
//

#import <Parse/Parse.h>
#import "ShredderContactsViewController.h"

@interface AllMessagesViewController : PFQueryTableViewController <ShredderContactsViewControllerDelegate>

// Model is the contacts database which is set on segue
@property (nonatomic, strong) UIManagedDocument *contactsDatabase;


@end

//
//  ContactsTableViewController.h
//  ParseStarterProject
//
//  Created by Alan Mathews on 12/11/2012.
//
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import <Parse/Parse.h>
#import "AddressBookHelper.h"

@interface ContactsTableViewController : CoreDataTableViewController <AddressBookHelperDelegate>

// Model is the contacts database
@property (nonatomic, strong) UIManagedDocument *contactsDatabase;


@end

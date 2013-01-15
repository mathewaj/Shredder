//
//  ShredderContactsViewController.h
//  ParseStarterProject
//
//  Created by Alan Mathews on 13/11/2012.
//
//

#import "CoreDataTableViewController.h"
#import "Contact.h"

@protocol ShredderContactsViewControllerDelegate <NSObject>

-(void)didSelectContact:(Contact *)contact;

@end

@interface ShredderContactsViewController : CoreDataTableViewController

// Model is the contacts database
@property (nonatomic, strong) UIManagedDocument *contactsDatabase;

@property (nonatomic, assign) id <ShredderContactsViewControllerDelegate> delegate;

@end

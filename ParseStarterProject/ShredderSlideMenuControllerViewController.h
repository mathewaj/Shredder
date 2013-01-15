//
//  ShredderSlideMenuControllerViewController.h
//  ParseStarterProject
//
//  Created by Alan Mathews on 20/11/2012.
//
//

#import "SASlideMenuViewController.h"
#import <Parse/Parse.h>
#import "AddressBookHelper.h"

@interface ShredderSlideMenuControllerViewController : SASlideMenuViewController <SASlideMenuDataSource, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, AddressBookHelperDelegate>

// This controller handles the delegate calls from the Login and Sign Up view controllers

// This controller creates and opens a UIManagedDocument to access the contacts database

// On first use, this controller will trigger the import of address book contacts
// It will then cross-check against the users on the server

// Model is the contacts database
@property (nonatomic, strong) UIManagedDocument *contactsDatabase;

// Helper object to manage contacts
@property (nonatomic, strong) AddressBookHelper *addressBookHelper;

@end

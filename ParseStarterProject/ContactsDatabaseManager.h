//
//  ContactsDatabaseManager.h
//  Shredder
//
//  Created by Shredder on 08/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "AddressBookHelper.h"
#import "ParseManager.h"
#import "Blocks.h"

@class Contact;

@protocol ContactsDatabaseManagerDelegate <NSObject>

@optional

-(void)databaseIsReady:(UIManagedDocument *)contactsDatabase;

@end


@interface ContactsDatabaseManager : NSObject <AddressBookHelperDelegate>

@property (nonatomic, strong) UIManagedDocument *contactsDatabase;
@property (nonatomic, strong) ParseManager *parseManager;
@property (weak, nonatomic) id <ContactsDatabaseManagerDelegate> delegate;

// Helper object to import contacts from Address Book
@property (nonatomic, strong) AddressBookHelper *addressBookHelper;

-(void)populateDatabaseWithCompletionHandler:(ContactsDatabaseReturned)completionBlock;
@property (nonatomic, copy) ContactsDatabaseReturned accessCompletionBlock;
@property (nonatomic, copy) ContactsDatabaseReturned populateCompletionBlock;

// Database Access
-(void)accessContactsDatabaseWithCompletionHandler:(ContactsDatabaseReturned)contactsDatabaseReturned;

// Contact Synchronising
-(void)syncAddressBookContacts;
-(NSString *)getNameForUser:(PFUser *)user;

@end

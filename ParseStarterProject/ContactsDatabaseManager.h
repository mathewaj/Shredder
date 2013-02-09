//
//  ContactsDatabaseManager.h
//  Shredder
//
//  Created by Shredder on 08/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "AddressBookHelper.h"

@class Contact;

@protocol ContactsDatabaseManagerDelegate <NSObject>

@optional

-(void)databaseIsReady:(UIManagedDocument *)contactsDatabase;

@end


@interface ContactsDatabaseManager : NSObject <AddressBookHelperDelegate>

@property (nonatomic, strong) UIManagedDocument *contactsDatabase;
@property (nonatomic, strong) NSArray *newlyUpdatedContacts;
@property (weak, nonatomic) id <ContactsDatabaseManagerDelegate> delegate;

// Helper object to import contacts from Address Book
@property (nonatomic, strong) AddressBookHelper *addressBookHelper;

-(void)createContactsDatabase;

-(Contact *)retrieveContactwithParseID:(NSString *)parseID inManagedObjectContext:(UIManagedDocument *)document;

-(void)updateContacts:(NSArray *)updatedContacts;



@end

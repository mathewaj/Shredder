//
//  Contact+Create.h
//  ParseStarterProject
//
//  Created by Alan Mathews on 12/11/2012.
//
//

#import "Contact.h"
#import <AddressBook/AddressBook.h>

// Category to help create Contact objects

@interface Contact (Create)

// Probably should be in contacts DB file
+(void)updateContactsWithAddressBookInfo:(ABRecordRef)person inContext:(NSManagedObjectContext *)context;

@end

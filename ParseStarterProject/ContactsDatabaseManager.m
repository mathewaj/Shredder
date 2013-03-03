//
//  ContactsDatabaseManager.m
//  Shredder
//
//  Created by Shredder on 08/02/2013.
//
//

#import "ContactsDatabaseManager.h"
#import "Contact.h"
#import "ParseManager.h"
#import "PhoneNumberManager.h"


@implementation ContactsDatabaseManager

-(Contact *)retrieveContactwithParseID:(NSString *)parseID inManagedObjectContext:(UIManagedDocument *)document{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    request.predicate = [NSPredicate predicateWithFormat:@"parseID = %@", parseID];
    NSArray *contacts = [document.managedObjectContext executeFetchRequest:request error:nil];
    Contact *contact = [contacts lastObject];
    return contact;
}

-(Contact *)retrieveContactWithPhoneNumber:(NSString *)phoneNumber inManagedObjectContext:(UIManagedDocument *)document{
    
    NSString *normalisedPhoneNumber = [PhoneNumberManager normalisedPhoneNumberWithContactNumber:phoneNumber countryCode:[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentCountryCallingCode"]];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    request.predicate = [NSPredicate predicateWithFormat:@"normalisedPhoneNumber = %@", normalisedPhoneNumber];
    NSArray *contacts = [document.managedObjectContext executeFetchRequest:request error:nil];
    Contact *contact = [contacts lastObject];
    return contact;
}

#pragma mark - Contacts Database Creation

-(void)accessContactsDatabaseWithCompletionHandler:(ContactsDatabaseReturned)contactsDatabaseReturned{
    
    // Create UIManagedDocument to access database
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"ContactsDatabase"];
    
    self.contactsDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    self.contactsDatabase.persistentStoreOptions = options;
    
    // File exists so open
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        
        [self.contactsDatabase openWithCompletionHandler:^(BOOL success) {
            
            if (success) {
                
                contactsDatabaseReturned(YES, self);
                
            } else {
                
                contactsDatabaseReturned(NO, self);
            }
        }];
        
    } else {
        
        // File does not exist so create
        [self.contactsDatabase saveToURL:url forSaveOperation:UIDocumentSaveForCreating
                       completionHandler:^(BOOL success) {
                           
                           
                           if (success) {
                               
                               [self databaseIsNew];
                               contactsDatabaseReturned(YES, self);
                               
                           } else {
                               NSLog(@"couldn’t create document at %@", url);
                           }
                       }];
    }
    
}

// Fired on creatin of database
-(void)databaseIsNew{
    
    [self syncAddressBookContacts];
    
}


// Fired by first creation and called periodically to update contact database
-(void)syncAddressBookContacts{
    [self initialiseAddressBookHelper];
    [self scanAddressBookForNewContactDetails];
}

#pragma mark - Address Book Import

-(void)initialiseAddressBookHelper{
    
    // Initialise address book helper
    self.addressBookHelper = [[AddressBookHelper alloc] init];
    self.addressBookHelper.delegate = self;
}

-(void)scanAddressBookForNewContactDetails{
    
    [self.addressBookHelper retrieveAddressBookContacts];
    
}

-(void)addressBookHelper:(AddressBookHelper *)helper retrieved:(NSArray *)recentlyUpdatedAddressBookRecords{
    
    [self saveAddressBookRecordsToDatabase:recentlyUpdatedAddressBookRecords];
    [self databaseIsReady];
}

-(void)saveAddressBookRecordsToDatabase:(NSArray *)recentlyUpdatedAddressBookRecords{
    
    [self updateContactsWithAddressBookRecords:recentlyUpdatedAddressBookRecords];
    //[self.contactsDatabase.managedObjectContext save:nil];
}

-(void)updateContactsWithAddressBookRecords:(NSArray *)recentlyUpdatedAddressBookRecords{
        
    // Iterate through Address Book Records and update Contacts DB
    for(int i=0; i<[recentlyUpdatedAddressBookRecords count]; i++){
        
        // Obtain current record reference from array
        ABRecordRef person = (__bridge ABRecordRef)([recentlyUpdatedAddressBookRecords objectAtIndex:i]);
        
        // Update contact details
        [Contact updateContactsWithAddressBookInfo:person inContext:self.contactsDatabase.managedObjectContext];
    }
    
    [self checkContactsDBForShredderUsers];

}

-(void)databaseIsReady{
    
    [self.delegate databaseIsReady:self.contactsDatabase];
    
}

// Send the address book to Parse to seek Shredder Users
-(void)checkContactsDBForShredderUsers{
        
    // Retrieve all contacts
    NSArray *allContacts = [self fetchAllContacts];
    
    [ParseManager checkShredderDBForContacts:allContacts withCompletionBlock:^(BOOL success, NSError *error, NSArray *matchedUsers) {
       
        [self updateContactsDBWithListOfShredderUsers:matchedUsers];
        
    }];
    
}

-(NSArray *)fetchAllContacts{
    
    // Retrieve all contacts
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    return [self.contactsDatabase.managedObjectContext executeFetchRequest:request error:nil];
}

-(void)updateContactsDBWithListOfShredderUsers:(NSArray *)matchedUsers{
    
    NSMutableArray *newlySignedOnUsers = [[NSMutableArray alloc] init];
    
    for(PFUser *user in matchedUsers)
    {
        // Iterate through matched Parse Users
        NSString *normalisedPhoneNumberString = user.username;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"normalisedPhoneNumber = %@", normalisedPhoneNumberString];
        request.predicate = predicate;
        NSArray *emailMatches = [self.contactsDatabase.managedObjectContext executeFetchRequest:request error:nil];
        
        for(Contact *contact in emailMatches)
        {
            if(![contact.signedUp isEqualToNumber:[NSNumber numberWithBool:YES]])
            {
                contact.signedUp = [NSNumber numberWithBool:YES];
                contact.parseID = user.objectId;
                [newlySignedOnUsers addObject:contact];
            }
            
        }
        
        
    }
    //[self.contactsDatabase.managedObjectContext save:nil];
}

-(NSString *)getName:(PFUser *)user{
    
    // Really belongs in ShredderUser but don't have database access there
    // Find contact for a give PFUser
    NSString *name;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    request.predicate = [NSPredicate predicateWithFormat:@"normalisedPhoneNumber = %@", user.username];
    NSArray *contacts = [self.contactsDatabase.managedObjectContext executeFetchRequest:request error:nil];
    Contact *contact = [contacts lastObject];
    if(contact){
        name = contact.name;
    } else {
        // Use phone number until custom name field included. TBC
        return nil;
    }
    
    return name;
}

-(NSString *)getNameForUser:(PFUser *)user{
    
    NSString *name;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    request.predicate = [NSPredicate predicateWithFormat:@"normalisedPhoneNumber = %@", user.username];
    NSArray *contacts = [self.contactsDatabase.managedObjectContext executeFetchRequest:request error:nil];
    Contact *contact = [contacts lastObject];
    if(contact){
        name = contact.name;
    } else {
        // Use phone number until custom name field included. TBC
        return nil;
    }
    
    return name;
    
}


-(void)addressBookHelperError:(AddressBookHelper *)addressBookHelper{
    
}
-(void)addressBookHelperDeniedAccess:(AddressBookHelper *)addressBookHelper{
    
}



@end

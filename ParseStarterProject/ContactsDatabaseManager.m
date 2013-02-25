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


@implementation ContactsDatabaseManager

-(Contact *)retrieveContactwithParseID:(NSString *)parseID inManagedObjectContext:(UIManagedDocument *)document{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    request.predicate = [NSPredicate predicateWithFormat:@"parseID = %@", parseID];
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

-(void)databaseIsNew{
    
    [self importAddressBookContactsToContactsDatabase];
    
}

// Every time database is opened, scan for new contacts
-(void)databaseIsReady{
    
    [self.delegate databaseIsReady:self.contactsDatabase];

}

-(void)importAddressBookContactsToContactsDatabase{
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
    [self checkIfNewContactsAreOnShredder];
    [self databaseIsReady];
}

-(void)saveAddressBookRecordsToDatabase:(NSArray *)recentlyUpdatedAddressBookRecords{
    
    [self createContactsWithAddressBookRecords:recentlyUpdatedAddressBookRecords];
    //[self.contactsDatabase.managedObjectContext save:nil];
}

-(void)createContactsWithAddressBookRecords:(NSArray *)recentlyUpdatedAddressBookRecords{
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    // Copy any contacts in array to database contacts list
    for(int i=0; i<[recentlyUpdatedAddressBookRecords count]; i++){
        
        // Obtain current record reference from array
        ABRecordRef person = (__bridge ABRecordRef)([recentlyUpdatedAddressBookRecords objectAtIndex:i]);
        
        Contact *contact = [Contact contactWithAddressBookInfo:person inContext:self.contactsDatabase.managedObjectContext];
        
        if(contact){
            [contacts addObject:contact];
        }
        
    }
    
    self.newlyUpdatedContacts = contacts;
}

-(void)checkIfNewContactsAreOnShredder{
    
    // Send the new contact details to Parse Manager to process
    ParseManager *parseManager = [[ParseManager alloc] init];
    parseManager.contactsDatabase = self.contactsDatabase;
    [parseManager checkIfNewContactsAreOnShredder:self.newlyUpdatedContacts];
    //[self.contactsDatabase.managedObjectContext save:nil];
    
}

-(NSArray *)fetchContacts{
    
    // Retrieve all contacts
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSArray *allContacts = [self.contactsDatabase.managedObjectContext executeFetchRequest:request error:nil];
    return allContacts;
}

-(NSString *)getName:(PFUser *)user{
    
    // A little bit of a hacky place for this possibly
    // Really belongs in ShredderUser but don't have database access there
    // Find contact for a give PFUser
    NSLog(user.username);
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
        name = user.username;
    }
    
    return name;
    
}


-(void)addressBookHelperError:(AddressBookHelper *)addressBookHelper{
    
}
-(void)addressBookHelperDeniedAccess:(AddressBookHelper *)addressBookHelper{
    
}



@end

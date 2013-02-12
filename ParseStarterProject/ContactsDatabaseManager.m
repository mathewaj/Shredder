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

-(void)createContactsDatabase{
    
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
                
                [self databaseIsOpen];
                
            } else {
                NSLog(@"couldn’t open document at %@", url);
            }
        }];
        
    } else {
        
        // File does not exist so create
        [self.contactsDatabase saveToURL:url forSaveOperation:UIDocumentSaveForCreating
                       completionHandler:^(BOOL success) {
                           
                           
                           if (success) {
                               
                               [self databaseIsOpen];
                               
                           } else {
                               NSLog(@"couldn’t create document at %@", url);
                           }
                       }];
    }
    
}

-(void)databaseIsOpen{
    
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
        
        
        
        /* Obtain name information
         
        int personID = ABRecordGetRecordID(person);
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *surname = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        
        NSString *fullName = @"";
        
        if(firstName){
            
            fullName = [fullName stringByAppendingString:firstName];
            
            if(surname)
            {
                fullName = [fullName stringByAppendingString:@" "];
                fullName = [fullName stringByAppendingString:surname];
            }
            
        } else if(surname)
        {
            fullName = [fullName stringByAppendingString:surname];
        }
        
        
        if(![fullName isEqualToString:@""]){
            
            NSLog(@"Full name: %@", fullName);
            
            // Create a contact for every phone entry
            Contact *contact = [Contact contactWithName:fullName inContext:self.contactsDatabase.managedObjectContext];
            
            // Set ID
            contact.addressBookID = [NSNumber numberWithInt:personID];
            
            //Set name initial
            NSString *initial = [fullName substringToIndex:1];
            NSString *capitalisedInitial = [initial capitalizedString];
            
            contact.nameInitial = capitalisedInitial;
            
            // Obtain the phone number for the contact
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            NSString* phone = nil;
            if (ABMultiValueGetCount(phoneNumbers) > 0) {
                
                phone = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumbers, 0));
                contact.phoneNumber = phone;
            }
            
            // Obtain email information from record and then iterate through
            ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
            
            for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
                
                // For first email, add to existing contact
                if(j==0){
                    contact.email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                } else {
                    NSString* emailString = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                    
                    Contact *duplicateContactWithSeparateEmail = [Contact contactWithName:fullName inContext:self.contactsDatabase.managedObjectContext];
                    duplicateContactWithSeparateEmail.email = emailString;
                    [contacts addObject:duplicateContactWithSeparateEmail];
                }
                
            }
            
            [self.contactsDatabase.managedObjectContext save:nil];
            [contacts addObject:contact];
            
            
        }*/
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
/*
-(void)promptUserForPermissionToUploadContacts
{
    // Check if user has granted permission to Shredder to upload contacts
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"PermissionToUploadContactsToShredder"] isEqualToNumber:[NSNumber numberWithBool:NO]])
    {
        // Prompt user to allow cross-check with server
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Shredder would like to upload your contacts to check which of your contacts are on Shredder. \n Your contacts will not be saved on our server." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert show];
    } else {
        
        [self scanShredderForContacts];
        //[self.delegate finishedMatchingContacts];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"PermissionToUploadContactsToShredder"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Shredder will not function fully without access to contacts \n\nPlease restart the app at your convenience to scan contacts" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        //[self.delegate finishedMatchingContacts];
        
    } else {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"PermissionToUploadContactsToShredder"];
        [self scanShredderForContacts];
        //[self.delegate finishedMatchingContacts];
    }
}

-(void)scanShredderForContacts{
    
    
    
    // Send contacts to Parse manager to process
    
}

// Address Book Helper object returns with array of contacts
-(void)addressBookHelper:(AddressBookHelper *)addressBookHelper finishedLoading:(NSArray *)addressBookContacts
{
    // If there are new contacts 
    if([addressBookContacts count]!=0)
    {
        [self saveAddressBookContactsToDatabase:addressBookContacts];
        
        // Otherwise return
    } else {
        //[self finishedMatchingContacts];
    }
    
}

// // Extract new contacts to database
-(void)saveAddressBookContactsToDatabase:people;
{
    
    // Copy any contacts in array to database contacts list
    for(int i=0; i<[people count]; i++){
        
        // Obtain current record reference from array
        ABRecordRef person = (__bridge ABRecordRef)([people objectAtIndex:i]);
        int personID = ABRecordGetRecordID(person);
        
        // Obtain name information
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *surname = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        
        NSString *fullName = @"";
        
        if(firstName){
            
            fullName = [fullName stringByAppendingString:firstName];
            
            if(surname)
            {
                fullName = [fullName stringByAppendingString:@" "];
                fullName = [fullName stringByAppendingString:surname];
            }
            
        } else if(surname)
        {
            fullName = [fullName stringByAppendingString:surname];
        }
        
        
        if(![fullName isEqualToString:@""]){
            
            // Create a contact for every phone entry
            Contact *contact = [Contact contactWithName:fullName inContext:self.contactsDatabase.managedObjectContext];
            
            // Set ID
            contact.addressBookID = [NSNumber numberWithInt:personID];
            
            //Set name initial
            NSString *initial = [fullName substringToIndex:1];
            NSString *capitalisedInitial = [initial capitalizedString];
            
            contact.nameInitial = capitalisedInitial;
            
            // Obtain the phone number for the contact
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            NSString* phone = nil;
            if (ABMultiValueGetCount(phoneNumbers) > 0) {
                
                phone = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumbers, 0));
                contact.phoneNumber = phone;
            }
            
            // Obtain email information from record and then iterate through
            ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
            
            for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
                
                // For first email, add to existing contact
                if(j==0){
                    contact.email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                } else {
                    NSString* emailString = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                    
                    Contact *duplicateContactWithSeparateEmail = [Contact contactWithName:fullName inContext:self.contactsDatabase.managedObjectContext];
                    duplicateContactWithSeparateEmail.email = emailString;
                }
                
            }
            
        }
        
        
        
    }
    
    
    
    
    // Check if user has granted permission to Shredder to upload contacts
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"PermissionToUploadContactsToShredder"] isEqualToNumber:[NSNumber numberWithBool:NO]])
    {
        // Prompt user to allow cross-check with server
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Shredder would like to upload your contacts to check which of your contacts are on Shredder. \n Your contacts will not be saved on our server." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert show];
    } else {
        
        //[self checkWhichContactsSignedUp];
        //[self.delegate finishedMatchingContacts];
    }
    
}*/

-(void)addressBookHelperError:(AddressBookHelper *)addressBookHelper{
    
}
-(void)addressBookHelperDeniedAccess:(AddressBookHelper *)addressBookHelper{
    
}



@end

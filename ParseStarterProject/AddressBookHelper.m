//
//  AddressBookHelper.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 14/11/2012.
//
//

#import "AddressBookHelper.h"
#import <AddressBook/AddressBook.h>
#import "Contact+Create.h"
#import <Parse/Parse.h>


@implementation AddressBookHelper

-(BOOL)isABAddressBookCreateWithOptionsAvailable {
    return &ABAddressBookCreateWithOptions != NULL;
}

// This method accesses the address book and retrieves an array of the contacts
-(void)retrieveAddressBookContacts {
        
    ABAddressBookRef addressBook;
    
    if ([self isABAddressBookCreateWithOptionsAvailable]) {
        
        CFErrorRef error = nil;
        addressBook = ABAddressBookCreateWithOptions(NULL,&error);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // callback can occur in background, address book must be accessed on thread it was created on
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [self.delegate addressBookHelperError:self];
                } else if (!granted) {
                    [self.delegate addressBookHelperDeniedAccess:self];
                } else {
                    // Access granted, fire delegate
                    AddressBookUpdated(addressBook, nil, (__bridge void *)(self));
                    CFRelease(addressBook);
                }
            });
        });
    } else {
        
        // iOS 4/5
        addressBook = ABAddressBookCreate();
        AddressBookUpdated(addressBook, NULL, (__bridge void *)(self));
        CFRelease(addressBook);
    }
}

// This method receives an array of contacts, and returns an array of contacts which have not been scanned
void AddressBookUpdated(ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
    AddressBookHelper *helper = (__bridge AddressBookHelper *)context;
    ABAddressBookRevert(addressBook);
    CFArrayRef addressBookArray = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    NSMutableArray *recentlyUpdatedContacts = [[NSMutableArray alloc] init];
    
    // Retrieve date last checked
    NSDate *lastScanDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastScanDate"];
    
    // Iterate through all people in address book
    for (CFIndex i = 0; i < CFArrayGetCount(addressBookArray); i++) {
        
        // Obtain current record reference from array
        ABRecordRef person = CFArrayGetValueAtIndex(addressBookArray, i);
        CFDateRef modifyDate = ABRecordCopyValue(person, kABPersonModificationDateProperty);
        NSDate *modifiedDate = (__bridge NSDate *)modifyDate;
        
        if (!lastScanDate || [modifiedDate compare:lastScanDate] == NSOrderedDescending) {
            // Modified date is later than scan date so add to array
            [recentlyUpdatedContacts addObject:(__bridge id)(person)];
            
        } else if ([modifiedDate compare:lastScanDate] == NSOrderedAscending) {
            // Ignore
            
        } else {
            // Unlikely
        }
        
    }
    
    NSDate* now = [NSDate date];
    
    [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"lastScanDate"];
    
    
    [[helper delegate] addressBookHelper:helper finishedLoading:recentlyUpdatedContacts];
};

// This method takes an array of contacts, and saves them as Contact objects in the DB
-(void)fetchAddressBookData:(NSArray *)people IntoDocument:(UIManagedDocument *)document
{
    // Copy any contacts in array to database contacts list
    for(int i=0; i<[people count]; i++){
        
        // Obtain current record reference from array
        //ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        ABRecordRef person = (__bridge ABRecordRef)([people objectAtIndex:i]);
        
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
            Contact *contact = [Contact contactWithName:fullName inContext:document.managedObjectContext];
            
            // Obtain email information from record and then iterate through
            ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
            
            for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
                
                // For first email, add to existing contact
                if(j==0){
                    contact.email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                } else {
                    NSString* emailString = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                    
                    Contact *duplicateContactWithSeparateEmail = [Contact contactWithName:fullName inContext:document.managedObjectContext];
                    duplicateContactWithSeparateEmail.email = emailString;
                }
                
            }
            
        }
        
        
        
    }
    
    // Save contacts to Shredder Contacts DB
    [document.managedObjectContext save:nil];
    
    
    // Check if user has granted permission to Shredder to upload contacts
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"PermissionToUploadContactsToShredder"] isEqualToNumber:[NSNumber numberWithBool:NO]])
    {
        // Prompt user to allow cross-check with server
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Shredder would like to upload your contacts to check which of your contacts are on Shredder. \n Your contacts will not be saved on our server." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert show];
    } else {
        
        [self checkWhichContactsSignedUp];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"PermissionToUploadContactsToShredder"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Shredder will not function fully without access to contacts \n\nPlease restart the app at your convenience to scan contacts" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        [self.delegate finishedMatchingContacts];
        
    } else {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"PermissionToUploadContactsToShredder"];
        [self checkWhichContactsSignedUp];
    }
}

// This method uploads the new contacts to Parse and tags all signed up users
-(void)checkWhichContactsSignedUp
{
    
    // Retrieve all contacts
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSArray *allContacts = [self.contactsDatabase.managedObjectContext executeFetchRequest:request error:nil];
    
    // Array of email addresses
    NSMutableArray *emailArray = [[NSMutableArray alloc] init];
    
    for(Contact *contact in allContacts)
    {
        if(contact.email)
        {
            [emailArray addObject:contact.email];
        }
        
    }
    
    // Find Parse contacts which have these email addresses
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" containedIn:emailArray];
    
    // CALL TO PARSE
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            for(PFUser *user in objects)
            {
                // Iterate through matched Parse Users
                NSString *emailString = user.username;
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email = %@", emailString];
                request.predicate = predicate;
                NSArray *emailMatches = [self.contactsDatabase.managedObjectContext executeFetchRequest:request error:nil];
                
                for(Contact *contact in emailMatches)
                {
                    if(![contact.signedUp isEqualToNumber:[NSNumber numberWithBool:YES]])
                    {
                        contact.signedUp = [NSNumber numberWithBool:YES];
                        contact.parseID = user.objectId;
                    }
                    
                }
                
                
            }
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
        [self.contactsDatabase.managedObjectContext save:nil];
        
        [self.delegate finishedMatchingContacts];
    }];
    
}

@end

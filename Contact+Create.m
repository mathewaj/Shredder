//
//  Contact+Create.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 12/11/2012.
//
//

#import "Contact+Create.h"
#import "PhoneNumberManager.h"



@implementation Contact (Create)

+(Contact *)contactWithName:(NSString *)name inContext:(NSManagedObjectContext *)context
{
    Contact *contact = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    NSArray *matches = [context executeFetchRequest:request error:nil];
    
    if(!matches || [matches count]>1)
    {
        
    } else if([matches count]==0)
    {
        
        contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
        contact.name = name;
                
        
    } else {
        contact = [matches lastObject];
    }
    
    return contact;
    
}

+(Contact *)contactWithPhoneNumber:(NSString *)normalisedPhoneNumber inContext:(NSManagedObjectContext *)context
{
    Contact *contact = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
    request.predicate = [NSPredicate predicateWithFormat:@"normalisedPhoneNumber = %@", normalisedPhoneNumber];
    
    NSArray *matches = [context executeFetchRequest:request error:nil];
    
    if(!matches || [matches count]>1)
    {
        
    } else if([matches count]==0)
    {
        
        contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
        contact.normalisedPhoneNumber = normalisedPhoneNumber;
        
        
    } else {
        contact = [matches lastObject];
    }
    
    return contact;
    
}

+(void)updateContactsWithAddressBookInfo:(ABRecordRef)person inContext:(NSManagedObjectContext *)context{
    
    Contact *contact;
    
    // Check if contacts exist for this address book info and if so delete
    [Contact removeExistingContactInfoForAddressBookRef:person inContext:context];
    
    // Now create contact for each phone number listing
    
    // Obtain name information
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *surname = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString *fullName = [Contact createFullNameWithFirstName:firstName surname:surname];
    
    if(![fullName isEqualToString:@""]){
        
        // Obtain the phone number for the contact
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        // Iterate through phone numbers
        for(int i=0;i<ABMultiValueGetCount(phoneNumbers);i++) {
            
            NSString *phone = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
            
            // Create a contact for every phone entry
            NSString *currentCountryCallingCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentCountryCallingCode"];
            NSString *normalisedPhoneNumber = [PhoneNumberManager normalisedPhoneNumberWithContactNumber:phone countryCode:currentCountryCallingCode];
            contact = [Contact contactWithPhoneNumber:normalisedPhoneNumber inContext:context];
            
            contact.phoneNumber = phone;
            contact.name = fullName;
            contact.addressBookID = [NSNumber numberWithInt:ABRecordGetRecordID(person)];
            
            //Set name initial
            NSString *initial = [fullName substringToIndex:1];
            NSString *capitalisedInitial = [initial capitalizedString];
            contact.nameInitial = capitalisedInitial;
            
            
            NSLog(@"Contact Name: %@", contact.name);
            NSLog(@"Contact Initial: %@", contact.nameInitial);
            NSLog(@"Normalised Number: %@", contact.normalisedPhoneNumber);
            
        }
        
        
            
    }
    
}

+(void)removeExistingContactInfoForAddressBookRef:(ABRecordRef)person inContext:(NSManagedObjectContext *)context{
    
    // Obtain current record reference from array
    int personID = ABRecordGetRecordID(person);
    NSNumber *personIDNumber = [NSNumber numberWithInt:personID];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    request.predicate = [NSPredicate predicateWithFormat:@"addressBookID = %@",  personIDNumber];
    NSArray *contacts = [context executeFetchRequest:request error:nil];
    
    for(Contact *contact in contacts){
        
        NSLog(@"Contact Being Deleted: %@", contact.name);
        
        [context deleteObject:contact];
    }
    
}

+(NSString *)createFullNameWithFirstName:(NSString *)firstName surname:(NSString *)surname
{
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
    
    return fullName;
}

    



@end

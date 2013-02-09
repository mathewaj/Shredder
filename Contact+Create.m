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


// Method to create a contact with certain data
+(Contact *)contactWithEmail:(NSString *)email inContext:(NSManagedObjectContext *)context
{
    Contact *contact = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
    request.predicate = [NSPredicate predicateWithFormat:@"email = %@", email];
    
    NSArray *matches = [context executeFetchRequest:request error:nil];
    
    if(!matches || [matches count]>1)
    {
        
    } else if([matches count]==0)
    {

        contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
        contact.email = email;
        
    } else {
        contact = [matches lastObject];
    }
    
    //[context save:nil];

    return contact;

}

+(BOOL)checkIfContactExists:(NSString *)email inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
    request.predicate = [NSPredicate predicateWithFormat:@"email = [c]%@", email];
    
    NSArray *matches = [context executeFetchRequest:request error:nil];
    
    if(!matches || [matches count]>1)
    {
        return YES;
    } else if([matches count]==0)
    {
        
        return NO;
        
    } else {
        return YES;
    }
}

-(Email *)addEmailAddress:(NSString *)address inContext:(NSManagedObjectContext *)context
{
    Email *email = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Email"];
    request.predicate = [NSPredicate predicateWithFormat:@"address = %@", email];
    
    NSArray *matches = [context executeFetchRequest:request error:nil];
    
    if(!matches || [matches count]>1)
    {
        
    } else if([matches count]==0)
    {
        
        email = [NSEntityDescription insertNewObjectForEntityForName:@"Email" inManagedObjectContext:context];
        email.address = address;
        
    } else {
        email = [matches lastObject];
    }
    
    //[context save:nil];
    
    return email;
}

+(Contact *)contactWithAddressBookInfo:(ABRecordRef)person inContext:(NSManagedObjectContext *)context{
    
    Contact *contact;
    
    // Obtain current record reference from array
    //ABRecordRef person = (__bridge ABRecordRef)([recentlyUpdatedAddressBookRecords objectAtIndex:i]);
    int personID = ABRecordGetRecordID(person);
    
    // Obtain name information
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *surname = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString *fullName = [Contact createFullNameWithFirstName:firstName surname:surname];
    
    
    if(![fullName isEqualToString:@""]){
        
        NSLog(@"Full name: %@", fullName);
        
        // Create a contact for every phone entry
        contact = [Contact contactWithName:fullName inContext:context];
        
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
            
            contact.normalisedPhoneNumber = [PhoneNumberManager normalisedPhoneNumberWithContactNumber:phone countryCode:@"353"];
            
             NSLog(@"Normalised Number: %@", contact.normalisedPhoneNumber);
            
        }
        
        // Obtain email information from record and then iterate through
        ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
        
        for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
            
            // For first email, add to existing contact
            if(j==0){
                contact.email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
            } else {
                /*NSString* emailString = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                
                Contact *duplicateContactWithSeparateEmail = [Contact contactWithName:fullName inContext:context];
                duplicateContactWithSeparateEmail.email = emailString;*/
            }
            
        }
        
    }
    
    return contact;
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

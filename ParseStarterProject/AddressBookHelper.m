//
//  AddressBookHelper.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 14/11/2012.
//
//

#import "AddressBookHelper.h"

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
                
                [self.delegate addressBookHelperError:self];
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

// This receives all address book records, and returns an array of updated address book records
void AddressBookUpdated(ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
    AddressBookHelper *helper = (__bridge AddressBookHelper *)context;
    
    ABAddressBookRevert(addressBook);
    CFArrayRef addressBookArray = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    NSMutableArray *recentlyUpdatedAddressBookRecords = [[NSMutableArray alloc] init];
    
    // Retrieve date last checked
    NSDate *lastScanDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastScanDate"];
    
    // Iterate through all people in address book
    for (CFIndex i = 0; i < CFArrayGetCount(addressBookArray); i++) {
        
        // Obtain current record reference from array
        ABRecordRef person = CFArrayGetValueAtIndex(addressBookArray, i);
        CFDateRef modifyDate = ABRecordCopyValue(person, kABPersonModificationDateProperty);
        NSDate *modifiedDate = (__bridge NSDate *)modifyDate;
        
        // If new contact or first time running version 1.1
        if (!lastScanDate || [modifiedDate compare:lastScanDate] == NSOrderedDescending) {
            
            // Check if contact has phone number, if so add to array
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            if (ABMultiValueGetCount(phoneNumbers) > 0){
                [recentlyUpdatedAddressBookRecords addObject:(__bridge id)(person)];
            }
            
        } else if ([modifiedDate compare:lastScanDate] == NSOrderedAscending) {
            // Ignore
            
        } else {
            // Unlikely
        }
        
    }
    
    NSDate* now = [NSDate date];
    
    [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"lastScanDate"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"firstRunVersion1.1"];
    
    // Pass array of new address book records back to contacts database manager
    [[helper delegate] addressBookHelper:helper retrieved:recentlyUpdatedAddressBookRecords];
    
};

+(ABRecordRef)createAddressBookRecordWithPhoneNumber:(NSString *)phoneNumber {
    
    ABRecordRef person = ABPersonCreate();
    CFErrorRef  error = NULL;
    
    //Phone number is a list of phone number, so create a multivalue
    ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phoneNumberMultiValue, (__bridge CFTypeRef)(phoneNumber),kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, &error); // set the phone number property
    
    if (error != NULL)
        NSLog(@"Error: %@", error);

    return person;
}

@end

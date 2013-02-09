//
//  AddressBookHelper.h
//  ParseStarterProject
//
//  Created by Alan Mathews on 14/11/2012.
//
//

#import <Foundation/Foundation.h>
#import "Contact+Create.h"
#import <AddressBook/AddressBook.h>

@class AddressBookHelper;

@protocol AddressBookHelperDelegate <NSObject>

@optional

-(void)addressBookHelperError:(AddressBookHelper *)addressBookHelper;
-(void)addressBookHelperDeniedAccess:(AddressBookHelper *)addressBookHelper;
-(void)addressBookHelper:(AddressBookHelper *)addressBookHelper retrieved:(NSArray *)recentlyUpdatedAddressBookRecords;
-(void)finishedMatchingContacts;

@end

@interface AddressBookHelper : NSObject

@property (weak, nonatomic) id <AddressBookHelperDelegate> delegate;

-(void)retrieveAddressBookContacts;

-(void)fetchAddressBookData:(NSArray *)people IntoDocument:(UIManagedDocument *)document;

-(void)checkWhichContactsSignedUp;

-(void)convertAddressBookRecordsToContacts:(NSArray *)addressBookRecords;

-(Contact *)createContactwithAddressRecord:(ABRecordRef)person;

@property (nonatomic, strong) UIManagedDocument *contactsDatabase;


@end

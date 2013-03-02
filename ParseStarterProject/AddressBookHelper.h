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
#import <AddressBookUI/AddressBookUI.h>
#import "ParseManager.h"

@class AddressBookHelper;

@protocol AddressBookHelperDelegate <NSObject>

@optional

-(void)addressBookHelperError:(AddressBookHelper *)addressBookHelper;
-(void)addressBookHelperDeniedAccess:(AddressBookHelper *)addressBookHelper;
-(void)addressBookHelper:(AddressBookHelper *)addressBookHelper retrieved:(NSArray *)recentlyUpdatedAddressBookRecords;

@end

@interface AddressBookHelper : NSObject

@property (nonatomic, strong) UIManagedDocument *contactsDatabase;
@property (weak, nonatomic) id <AddressBookHelperDelegate> delegate;

-(void)retrieveAddressBookContacts;
+(ABRecordRef)createAddressBookRecordWithPhoneNumber:(PFUser *)contact;



@end

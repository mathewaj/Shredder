//
//  AddressBookHelper.h
//  ParseStarterProject
//
//  Created by Alan Mathews on 14/11/2012.
//
//

#import <Foundation/Foundation.h>

@class AddressBookHelper;

@protocol AddressBookHelperDelegate <NSObject>

@optional

-(void)addressBookHelperError:(AddressBookHelper *)addressBookHelper;
-(void)addressBookHelperDeniedAccess:(AddressBookHelper *)addressBookHelper;
-(void)addressBookHelper:(AddressBookHelper *)addressBookHelper finishedLoading:(NSArray *)people;
-(void)finishedMatchingContacts;

@end

@interface AddressBookHelper : NSObject

@property (weak, nonatomic) id <AddressBookHelperDelegate> delegate;

-(void)retrieveAddressBookContacts;

-(void)fetchAddressBookData:(NSArray *)people IntoDocument:(UIManagedDocument *)document;

-(void)checkWhichContactsSignedUp;

@property (nonatomic, strong) UIManagedDocument *contactsDatabase;


@end

//
//  ParseManager.h
//  Shredder
//
//  Created by Shredder on 08/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "Blocks.h"
#import "ShredderUser.h"
#import "Message.h"

@interface ParseManager : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) UIManagedDocument *contactsDatabase;

#pragma mark - User Methods

+(void)signUpWithPhoneNumber:(NSString *)phoneNumber andPassword:(NSString *)password withCompletionBlock:(ParseReturned)parseReturned;

+(void)loginWithPhoneNumber:(NSString *)phoneNumber andPassword:(NSString *)password withCompletionBlock:(ParseReturned)parseReturned;

#pragma mark - Message Methods

+(void)retrieveMessagesForCurrentUser:(PFUser *)user withCompletionBlock:(ParseReturnedArray)parseReturnedArray;

+(void)retrieveAllMessagePermissionsForShredderUser:(ShredderUser *)user withCompletionBlock:(ParseReturnedArray)parseReturnedArray;

+(void)sendMessage:(Message *)message withCompletionBlock:(ParseReturned)parseReturned;
+(void)shredMessage:(Message *)message withCompletionBlock:(ParseReturned)parseReturned;

#pragma mark - Contact Methods

+(void)shredderUserForContact:(Contact *)contact withCompletionBlock:(ParseReturnedArray)parseReturnedArray;

-(void)checkIfNewContactsAreOnShredder:(NSArray *)newlyUpdatedContacts;

#pragma mark - Image Methods

+(void)startUploadingImages:(NSArray *)imagesArray;

@end

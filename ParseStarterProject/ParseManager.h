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
#import "MessagePermission.h"
#import <Parse/Parse.h>

@interface ParseManager : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) UIManagedDocument *contactsDatabase;

#pragma mark - User Methods

+(void)signUpWithPhoneNumber:(NSString *)phoneNumber andPassword:(NSString *)password withCompletionBlock:(ParseReturned)parseReturned;

+(void)loginWithPhoneNumber:(NSString *)phoneNumber andPassword:(NSString *)password withCompletionBlock:(ParseReturned)parseReturned;

#pragma mark - Message Methods

+(void)retrieveReceivedMessagePermissionsForCurrentUser:(PFUser *)user withCompletionBlock:(ParseReturnedArray)parseReturnedArray;

+(void)retrieveAllReportsForCurrentUser:(ShredderUser *)user withCompletionBlock:(ParseReturnedArray)parseReturnedArray;

+(void)sendMessage:(MessagePermission *)messagePermission withCompletionBlock:(ParseReturned)parseReturned;
//+(void)shredMessage:(Message *)message withCompletionBlock:(ParseReturned)parseReturned;
+(void)shredMessage:(MessagePermission *)messagePermission withCompletionBlock:(ParseReturned)parseReturned;
+(void)deleteReport:(PFObject *)messagePermission withCompletionBlock:(ParseReturned)parseReturned;
+(PFObject *)attachImages:(NSArray *)images toMessage:(PFObject *)message;

+(PFObject *)createNewMessageForShredderUserRecipient:(PFUser *)recipient;
+(PFObject *)createMessagePermissionForMessage:(PFObject *)message andShredderUserRecipient:(PFUser *)recipient;

#pragma mark - Contact Methods

+(void)shredderUserForContact:(Contact *)contact withCompletionBlock:(ParseReturnedArray)parseReturnedArray;

-(void)checkIfNewContactsAreOnShredder:(NSArray *)newlyUpdatedContacts;

#pragma mark - Image Methods

+(void)startUploadingImages:(NSArray *)imagesArray;

@end

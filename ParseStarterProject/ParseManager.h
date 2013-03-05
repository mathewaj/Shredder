//
//  ParseManager.h
//  Shredder
//
//  Created by Shredder on 08/02/2013.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Contact.h"
#import "Blocks.h"

@interface ParseManager : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) UIManagedDocument *contactsDatabase;

#pragma mark - User Methods

+(void)signUpWithPhoneNumber:(NSString *)phoneNumber andPassword:(NSString *)password withCompletionBlock:(ParseReturned)parseReturned;

+(void)loginWithPhoneNumber:(NSString *)phoneNumber andPassword:(NSString *)password withCompletionBlock:(ParseReturned)parseReturned;

#pragma mark - Message Builder Methods

+(PFObject *)createNewMessage;
+(PFObject *)createMessagePermissionForMessage:(PFObject *)message andShredderUserRecipient:(PFUser *)recipient;

#pragma mark - Message Database Reading Methods

+(void)retrieveReceivedMessagePermissionsForCurrentUser:(PFUser *)user withCompletionBlock:(ParseReturnedArray)parseReturnedArray;
+(void)retrieveAllReportsForCurrentUser:(PFUser *)user withCompletionBlock:(ParseReturnedArray)parseReturnedArray;

#pragma mark - Message Database Writing Methods

+(void)sendMessage:(PFObject *)messagePermission withCompletionBlock:(ParseReturned)parseReturned;
+(void)shredMessage:(PFObject *)messagePermission withCompletionBlock:(ParseReturned)parseReturned;
+(void)deleteReport:(PFObject *)messagePermission withCompletionBlock:(ParseReturned)parseReturned;
+(void)grantAccessToWelcomeMessageForUser:(PFUser *)user;

#pragma mark - Contact Methods

+(void)checkShredderDBForContacts:(NSArray *)allContacts withCompletionBlock:(ParseReturnedArray)parseReturned;
+(void)shredderUserForContact:(Contact *)contact withCompletionBlock:(ParseReturnedArray)parseReturnedArray;


#pragma mark - Attachment Methods

+(PFObject *)attachImages:(NSArray *)images toMessage:(PFObject *)message;
+(void)startUploadingImages:(NSArray *)imagesArray;

#pragma mark - Installation Methods

+(void)setBadgeWithNumberOfMessages:(NSNumber *)messagesCount;

@end

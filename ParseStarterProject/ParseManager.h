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

#pragma mark - Message Methods

+(PFObject *)createNewMessage;
+(PFObject *)createMessagePermissionForMessage:(PFObject *)message andShredderUserRecipient:(PFUser *)recipient;

+(void)retrieveReceivedMessagePermissionsForCurrentUser:(PFUser *)user withCompletionBlock:(ParseReturnedArray)parseReturnedArray;
+(void)retrieveAllReportsForCurrentUser:(PFUser *)user withCompletionBlock:(ParseReturnedArray)parseReturnedArray;

+(void)sendMessage:(PFObject *)messagePermission withCompletionBlock:(ParseReturned)parseReturned;
+(void)shredMessage:(PFObject *)messagePermission withCompletionBlock:(ParseReturned)parseReturned;

+(void)deleteReport:(PFObject *)messagePermission withCompletionBlock:(ParseReturned)parseReturned;

+(PFObject *)attachImages:(NSArray *)images toMessage:(PFObject *)message;


#pragma mark - Contact Methods

+(void)shredderUserForContact:(Contact *)contact withCompletionBlock:(ParseReturnedArray)parseReturnedArray;

-(void)checkIfNewContactsAreOnShredder:(NSArray *)newlyUpdatedContacts;

#pragma mark - Image Methods

+(void)startUploadingImages:(NSArray *)imagesArray;

@end

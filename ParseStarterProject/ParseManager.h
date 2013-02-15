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

@interface ParseManager : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) UIManagedDocument *contactsDatabase;

+(void)signUpWithPhoneNumber:(NSString *)phoneNumber andPassword:(NSString *)password withCompletionBlock:(ParseReturned)parseReturned;

+(void)loginWithPhoneNumber:(NSString *)phoneNumber andPassword:(NSString *)password withCompletionBlock:(ParseReturned)parseReturned;

+(void)retrieveAllMessagesForShredderUser:(ShredderUser *)user withCompletionBlock:(ParseReturnedArray)parseReturnedArray;

+(void)retrieveAllMessagePermissionsForShredderUser:(ShredderUser *)user withCompletionBlock:(ParseReturnedArray)parseReturnedArray;


-(void)checkIfNewContactsAreOnShredder:(NSArray *)newlyUpdatedContacts;

@end

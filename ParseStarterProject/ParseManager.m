//
//  ParseManager.m
//  Shredder
//
//  Created by Shredder on 08/02/2013.
//
//

#import "ParseManager.h"
#import <CoreData/CoreData.h>
#import "Contact.h"


@interface ParseManager()

@property (nonatomic, strong) NSArray *contactsForUserCheck;

@end

@implementation ParseManager

#pragma mark - User Functions

+(void)signUpWithPhoneNumber:(NSString *)phoneNumber andPassword:(NSString *)password withCompletionBlock:(ParseReturned)parseReturned {
    
    PFUser *user = [PFUser user];
    user.username = phoneNumber;
    user.password = password;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!error) {
            // Hooray! Let them use the app now.
            if(succeeded)
            {
                // Set the device's installation object to this user
                PFInstallation *installation = [PFInstallation currentInstallation];
                [installation setObject:[PFUser currentUser] forKey:@"owner"];
                [installation saveEventually];
                
                parseReturned(YES, error);
            } else {
                parseReturned(NO, error);
            }
            
        } else {
            parseReturned(NO, error);
        }
    }];
    
}

+(void)loginWithPhoneNumber:(NSString *)phoneNumber andPassword:(NSString *)password withCompletionBlock:(ParseReturned)parseReturned{
    
    PFUser *user = [PFUser user];
    user.username = phoneNumber;
    user.password = password;
    
    [PFUser logInWithUsernameInBackground:phoneNumber password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            // Do stuff after successful login.
                                            
                                            // Set the device's installation object to this user
                                            PFInstallation *installation = [PFInstallation currentInstallation];
                                            [installation setObject:[PFUser currentUser] forKey:@"owner"];
                                            [installation saveEventually];
                                            
                                            parseReturned(YES, error);
                                        } else {
                                            // The login failed. Check error to see why.
                                            parseReturned(NO, error);
                                        }
                                    }];
    
}

#pragma mark - Messaging Functions

+(void)retrieveReceivedMessagePermissionsForCurrentUserWithCompletionBlock:(ParseReturnedArray)parseReturnedArray{
    
    if([[PFUser currentUser] username]){
        
        PFQuery *query = [PFQuery queryWithClassName:@"MessagePermission"];
        [query whereKey:@"recipient" equalTo:[PFUser currentUser]];
        [query whereKey:@"permissionShredded" equalTo:[NSNumber numberWithBool:NO]];
        [query includeKey:@"sender"];
        [query includeKey:@"message"];
        [query orderByDescending:@"createdAt"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                
                // If success, clean up any zombie permissions that may be in the system
                NSMutableArray *mutableObjects = [objects mutableCopy];
                
                for(int i=0; i < [objects count]; i++){
                    
                    PFObject *permission = [objects objectAtIndex:i];
                    
                    if(![permission objectForKey:@"message"]){
                        
                        [TestFlight passCheckpoint:@"Zombie Permissions Deletion"];
                        [permission deleteInBackground];
                        [mutableObjects removeObject:permission];
                    }
                    
                }
            
                parseReturnedArray(YES, error, mutableObjects);
                
            } else {
                // Log details of the failure
                parseReturnedArray(NO, error, objects);
            }
        }];
        
    } else {
        parseReturnedArray(NO, nil, nil);
    }
    
}

+(void)retrieveAllReportsForCurrentUserWithCompletionBlock:(ParseReturnedArray)parseReturnedArray{
    
    TFLog(@"In retrieveAllReportsForCurrentUserWithCompletionBlock");
    
    if([[PFUser currentUser] username]){
        
        PFQuery *query = [PFQuery queryWithClassName:@"MessagePermission"];
        [query whereKey:@"sender" equalTo:[PFUser currentUser]];
        [query whereKey:@"permissionShredded" equalTo:[NSNumber numberWithBool:YES]];
        [query includeKey:@"recipient"];
        [query includeKey:@"message"];
        [query orderByDescending:@"createdAt"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            TFLog(@"In retrieveAllReportsForCurrentUserWithCompletionBlockReturn");
            if (!error) {
                parseReturnedArray(YES, error, objects);
            } else {
                // Log details of the failure
                parseReturnedArray(NO, error, objects);
            }
        }];
        
    } else {
        parseReturnedArray(NO, nil, nil);
    }
    
}


+(void)sendMessage:(PFObject *)messagePermission withCompletionBlock:(ParseReturned)parseReturned{
    
    TFLog(@"In sendMessage: withCompletionBlock:");
    
    [messagePermission saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        TFLog(@"In sendMessage: withCompletionBlock: Return");
        
        // If message permission doesn't save, make sure message is also deleted
        if (!succeeded) {
            
            PFObject *message = [messagePermission objectForKey:@"message"];
            [message deleteInBackground];
            
        }
        
        parseReturned(succeeded, error);
        
    }];
    
}

+(void)sendNewMessageNotificationTo:(PFUser *)recipient{
    
    if([recipient username]){
        // Create our installation query
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"owner" equalTo:recipient];
        
        // Send push notification to query
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"You have received a message on Shredder", @"alert",
                              @"Increment", @"badge",
                              @"chainsaw-02.wav", @"sound",
                              nil];
        [push setData:data];
        [push sendPushInBackground];
    }
    
}

+(void)shredMessage:(PFObject *)messagePermission withCompletionBlock:(ParseReturned)parseReturned{
    
    TFLog(@"In shredMessage: withCompletionBlock:");
    
    PFObject *message = [messagePermission objectForKey:@"message"];
    
    if(message){
        
        // Delete message permissions of Welcome Shredder Message
        if([message.objectId isEqualToString:@"BQaxVDuxzn"]){
            
            [messagePermission deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                TFLog(@"In shredMessage: withCompletionBlock: Return Welcome Message");
                parseReturned(succeeded, error);
            }];
            
        } else {
            
            // Turn Message Permission Shredded Value to True and Record Time Shredded
            [messagePermission setObject:[NSNumber numberWithBool:YES] forKey:@"permissionShredded"];
            [messagePermission setObject:[NSDate date] forKey:@"permissionShreddedAt"];
            
            [messagePermission saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                TFLog(@"In shredMessage: withCompletionBlock: Return");
                
                // Notify of result
                parseReturned(succeeded, error);
                
                // If message permission successfully saved as shredded, check if message can be deleted
                if(succeeded)
                {
                    // If last message permission delete message
                    PFQuery *query = [PFQuery queryWithClassName:@"MessagePermission"];
                    [query whereKey:@"message" equalTo:message];
                    [query whereKey:@"permissionShredded" equalTo:[NSNumber numberWithBool:NO]];
                    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                        
                        if(number == 0)
                        {
                            [message deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                
                                // If message deletion fails, reinstate message and undelete permission
                                if(!succeeded){
                                    
                                    [messagePermission setObject:[NSNumber numberWithBool:NO] forKey:@"permissionShredded"];
                                    [messagePermission setObject:message forKey:@"message"];
                                    [messagePermission saveInBackground];
                                    
                                }
                                
                            }];
                        }
                    }];
                    
                }
                
                
            }];
            
        }

        
    } else {
        parseReturned(NO, nil);
    }
    
        
    
    

}

+(void)deleteReport:(PFObject *)messagePermission withCompletionBlock:(ParseReturned)parseReturned{
    
    TFLog(@"In deleteReport: withCompletionBlock:");
    
    [messagePermission deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        TFLog(@"In deleteReport: withCompletionBlock: Return");
        parseReturned(succeeded, error);
    }];
    
    
}

+(PFObject *)createNewMessage{
    
    TFLog(@"In createNewMessage:");
    
    PFObject *blankMessage = [PFObject objectWithClassName:@"Message"];
    [blankMessage setObject:[PFUser currentUser] forKey:@"sender"];
    //[blankMessage setObject:recipient forKey:@"recipient"];
        
    return blankMessage;
    
}

+(PFObject *)createMessagePermissionForMessage:(PFObject *)message andShredderUserRecipient:(PFUser *)recipient{
    
    TFLog(@"In createMessagePermissionForMessage: andShredderUserRecipient:");
    
    // Create Message Permissions
    // These cannot rely on the message still being present so must incorporate all the info
    PFObject *messagePermission = [PFObject objectWithClassName:@"MessagePermission"];
    [messagePermission setObject:[PFUser currentUser] forKey:@"sender"];
    [messagePermission setObject:recipient forKey:@"recipient"];
    [messagePermission setObject:[NSNumber numberWithBool:NO] forKey:@"permissionShredded"];
    
    // Set Message Permission Access
    PFACL *messagePermissionACL = [PFACL ACL];
    [messagePermissionACL setReadAccess:YES forUser:[PFUser currentUser]];
    [messagePermissionACL setWriteAccess:YES forUser:[PFUser currentUser]];
    [messagePermissionACL setReadAccess:YES forUser:recipient];
    [messagePermissionACL setWriteAccess:YES forUser:recipient];
    messagePermission.ACL = messagePermissionACL;
    
    // Set Message Access
    PFACL *messageACL = [PFACL ACL];
    [messageACL setReadAccess:YES forUser:[PFUser currentUser]];
    [messageACL setWriteAccess:YES forUser:[PFUser currentUser]];
    [messageACL setReadAccess:YES forUser:recipient];
    [messageACL setWriteAccess:YES forUser:recipient];
    //[messageACL setPublicReadAccess:YES];
    //[messageACL setPublicWriteAccess:YES];
    message.ACL = messageACL;
    
    [messagePermission setObject:message forKey:@"message"];
    
    return messagePermission;
    
}

+(PFObject *)attachImages:(NSArray *)images toMessage:(PFObject *)message{
    
    TFLog(@"In attachImages:");
    
    PFFile *photoFile = [images objectAtIndex:0];
    PFFile *thumbnailFile = [images objectAtIndex:1];
    
    [message setObject:thumbnailFile forKey:@"attachmentThumbnail"];
    [message setObject:photoFile forKey:@"attachment"];
    
    return message;
    
}

+(void)grantAccessToWelcomeMessageForUser:(PFUser *)user;
{
    
     TFLog(@"In grantAccessToWelcomeMessageForUser:");
    
    // Retrieve welcome message object
    PFQuery *welcomeMessageQuery = [PFQuery queryWithClassName:@"Message"];
    [welcomeMessageQuery includeKey:@"sender"];
    [welcomeMessageQuery getObjectInBackgroundWithId:@"BQaxVDuxzn"
                                 block:^(PFObject *message, NSError *error) {
                                     
                                     TFLog(@"In grantAccessToWelcomeMessageForUser: return");
                                     if (!error) {
                                         
                                        
                                         
                                         // Retrieved message
                                         PFObject *messagePermission = [self createMessagePermissionForWelcomeMessage:message andShredderUserRecipient:[PFUser currentUser]];
                                         [ParseManager sendMessage:messagePermission withCompletionBlock:^(BOOL success, NSError *error) {
                                             
                                         }];
                                         
                                         
                                         
                                     } else {
                                         // Log details of our failure
                                         NSLog(@"Error: %@ %@", error, [error userInfo]);
                                     }
                                 }];
}

+(PFObject *)createMessagePermissionForWelcomeMessage:(PFObject *)message andShredderUserRecipient:(PFUser *)recipient{
    
     TFLog(@"In createMessagePermissionForWelcomeMessage: andShredderUserRecipient:");
    
    // Create Message Permissions
    // These cannot rely on the message still being present so must incorporate all the info
    PFObject *messagePermission = [PFObject objectWithClassName:@"MessagePermission"];
    [messagePermission setObject:[message objectForKey:@"sender"] forKey:@"sender"];
    [messagePermission setObject:[PFUser currentUser] forKey:@"recipient"];
    [messagePermission setObject:[NSNumber numberWithBool:NO] forKey:@"permissionShredded"];
    
    // Set Message Permission Access
    PFACL *messagePermissionACL = [PFACL ACL];
    [messagePermissionACL setReadAccess:YES forUser:[PFUser currentUser]];
    [messagePermissionACL setWriteAccess:YES forUser:[PFUser currentUser]];
    [messagePermissionACL setReadAccess:YES forUser:recipient];
    [messagePermissionACL setWriteAccess:YES forUser:recipient];
    messagePermission.ACL = messagePermissionACL;
    
    // Message Access Already Set
    //PFACL *messageACL = [PFACL ACL];
    //[messageACL setReadAccess:YES forUser:[PFUser currentUser]];
    //[messageACL setWriteAccess:YES forUser:[PFUser currentUser]];
    //[messageACL setReadAccess:YES forUser:recipient];
    //[messageACL setWriteAccess:YES forUser:recipient];*/
    //message.ACL = messageACL;
    
    [messagePermission setObject:message forKey:@"message"];
    
    return messagePermission;
    
}

+(void)setBadgeWithNumberOfMessages:(NSNumber *)messagesCount{
    
    TFLog(@"In setBadgeWithNumberOfMessages");
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = [messagesCount intValue];
    [currentInstallation saveInBackground];
    
}


#pragma mark - Contact Functions

-(void)promptUserForPermissionToUploadContacts
{
     TFLog(@"In promptUserForPermissionToUploadContacts:");
    
    // Check if user has granted permission to Shredder to upload contacts
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"PermissionToUploadContactsToShredder"] isEqualToNumber:[NSNumber numberWithBool:NO]])
    {
        // Prompt user to allow cross-check with server
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Shredder would like to upload your contacts to check which of your contacts are on Shredder. \n The details of your contacts will not be saved" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert show];
        
    } else {
        
        // Go straight to uploading contacts
        //[self uploadAndCheckContacts];

    }
    
}

+(void)checkShredderDBForContacts:(NSArray *)allContacts withCompletionBlock:(ParseReturnedArray)parseReturned{
    
    TFLog(@"In checkShredderDBForContacts: withCompletionBlock:");

    // Array of phone numbers
    NSMutableArray *phoneNumberArray = [[NSMutableArray alloc] init];
    
    // Add all contacts with valid phone numbers
    for(Contact *contact in allContacts)
    {
        if(contact.normalisedPhoneNumber)
        {
            [phoneNumberArray addObject:contact.normalisedPhoneNumber];
        }
        
    }
    
    // Find Parse contacts which have these phone numbers
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" containedIn:phoneNumberArray];
    
    // CALL TO PARSE
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        TFLog(@"In checkShredderDBForContacts: withCompletionBlock: Return");
        
        if (!error) {
            
            // Returns an array of matching users
            parseReturned(YES, error, objects);
  
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            parseReturned(NO, error, nil);
        }
     
    }];
    
}

+(void)shredderUserForContact:(Contact *)contact withCompletionBlock:(ParseReturnedArray)parseReturnedArray{
    
    TFLog(@"In  shredderUserForContact withCompletionBlock");
    
    if(contact){
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"username" equalTo:contact.normalisedPhoneNumber];
        
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            TFLog(@"In  shredderUserForContact withCompletionBlock Return");
            
            parseReturnedArray(YES, error, objects);
            
        }];
    } else {
        parseReturnedArray(NO, nil, nil);
    }
    
    TFLog(@"Closing shredderUserForContact");
    
    
    
}

#pragma mark - Image Functions

+(void)startUploadingImages:(NSArray *)imagesArray{
    
    TFLog(@"In startUploadingImages");
    
    PFFile *thumbnailFile = [imagesArray objectAtIndex:0];
    PFFile *photoFile = [imagesArray objectAtIndex:1];
    
    [thumbnailFile saveInBackground];
    [photoFile saveInBackground];

    
}

@end

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

+(void)retrieveReceivedMessagePermissionsForCurrentUser:(PFUser *)user withCompletionBlock:(ParseReturnedArray)parseReturnedArray{
    
    PFQuery *query = [PFQuery queryWithClassName:@"MessagePermission"];
    [query whereKey:@"recipient" equalTo:user];
    [query whereKey:@"permissionShredded" equalTo:[NSNumber numberWithBool:NO]];
    [query includeKey:@"sender"];
    [query includeKey:@"message"];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            NSLog(@"Messages Found: %i", [objects count]);
            parseReturnedArray(YES, error, objects);
        } else {
            // Log details of the failure
            parseReturnedArray(NO, error, objects);
        }
    }];
    
}

+(void)retrieveAllReportsForCurrentUser:(PFUser *)user withCompletionBlock:(ParseReturnedArray)parseReturnedArray{
    
    PFQuery *query = [PFQuery queryWithClassName:@"MessagePermission"];
    [query whereKey:@"sender" equalTo:user];
    [query whereKey:@"permissionShredded" equalTo:[NSNumber numberWithBool:YES]];
    [query includeKey:@"recipient"];
    [query includeKey:@"message"];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            parseReturnedArray(YES, error, objects);
        } else {
            // Log details of the failure
            parseReturnedArray(NO, error, objects);
        }
    }];
    
}


+(void)sendMessage:(PFObject *)messagePermission withCompletionBlock:(ParseReturned)parseReturned{
    
    [messagePermission saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [ParseManager sendNewMessageNotificationTo:[messagePermission objectForKey:@"recipient"]];
        parseReturned(succeeded, error);
        
    }];
    
}

+(void)sendNewMessageNotificationTo:(PFUser *)recipient{
    
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

+(void)shredMessage:(PFObject *)messagePermission withCompletionBlock:(ParseReturned)parseReturned{
    
    PFObject *message = [messagePermission objectForKey:@"message"];
    
    // Turn Message Permission Shredded Value to True and Record Time Shredder
    [messagePermission setObject:[NSNumber numberWithBool:YES] forKey:@"permissionShredded"];
    [messagePermission setObject:[NSDate date] forKey:@"permissionShreddedAt"];
    
    [messagePermission saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        parseReturned(succeeded, error);
        
        // Check if this is the there are outstanding permissions for this message,
        // If not delete message
        PFQuery *query = [PFQuery queryWithClassName:@"MessagePermission"];
        [query whereKey:@"message" equalTo:message];
        [query whereKey:@"permissionShredder" equalTo:[NSNumber numberWithBool:NO]];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            
            if(number == 0)
            {
                [message deleteInBackground];
            }
        }];
    }];
    
    // Check if this is the last message permission
    // If so, destroy message
    
    
}

+(void)deleteReport:(PFObject *)messagePermission withCompletionBlock:(ParseReturned)parseReturned{
    
    [messagePermission deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        parseReturned(succeeded, error);
    }];
    
    
}

+(PFObject *)createNewMessage{
    
    PFObject *blankMessage = [PFObject objectWithClassName:@"Message"];
    [blankMessage setObject:[PFUser currentUser] forKey:@"sender"];
    //[blankMessage setObject:recipient forKey:@"recipient"];
        
    return blankMessage;
    
}

+(PFObject *)createMessagePermissionForMessage:(PFObject *)message andShredderUserRecipient:(PFUser *)recipient{
    
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
    message.ACL = messageACL;
    
    [messagePermission setObject:message forKey:@"message"];
    
    return messagePermission;
    
}

+(PFObject *)attachImages:(NSArray *)images toMessage:(PFObject *)message{
    
    PFFile *photoFile = [images objectAtIndex:0];
    PFFile *thumbnailFile = [images objectAtIndex:1];
    
    [message setObject:thumbnailFile forKey:@"attachmentThumbnail"];
    [message setObject:photoFile forKey:@"attachment"];
    
    return message;
    
}

+(void)sendWelcomeMessageToUser:(PFUser *)user
{
    
    PFObject *welcomeMessage = [self createNewMessage];
    
    [welcomeMessage setObject:@"Welcome to Shredder!\n\nThis new private messaging app is designed to ensure that sensitive information is permanently erased once it has been viewed.\n\nImages may be attached to your messages, please hold the thumbnail in the top right to view. Beware the sender will be informed if you take a screenshot! \n\nWhen you are finished reading, please press the Shred button below to delete this message forever." forKey:@"body"];
    
    
    PFObject *welcomeMessagePermission = [self createMessagePermissionForMessage:welcomeMessage andShredderUserRecipient:user];
    PFUser *shredder = [PFQuery getUserObjectWithId:@"RmRaaHMn9o"];
    [welcomeMessagePermission setObject:shredder forKey:@"sender"];
    [welcomeMessagePermission setObject:[PFUser currentUser] forKey:@"recipient"];
    
    [ParseManager sendMessage:welcomeMessagePermission withCompletionBlock:^(BOOL success, NSError *error) {
        
    }];
}

+(void)setBadgeWithNumberOfMessages:(NSNumber *)messagesCount{
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = [messagesCount intValue];
    [currentInstallation saveInBackground];
    
}


#pragma mark - Contact Functions

-(void)promptUserForPermissionToUploadContacts
{
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"PermissionToUploadContactsToShredder"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Shredder will not function fully without access to contacts \n\nPlease restart the app at your convenience to scan contacts" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        //[self.delegate finishedMatchingContacts];
        
    } else {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"PermissionToUploadContactsToShredder"];
        //[self uploadAndCheckContacts];
        //[self.delegate finishedMatchingContacts];
    }
}

+(void)checkShredderDBForContacts:(NSArray *)allContacts withCompletionBlock:(ParseReturnedArray)parseReturned{

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
        if (!error) {
            
            // Returns an array of matching users
            parseReturned(YES, error, objects);
            
            
            /*for(PFUser *user in objects)
            {
                // Iterate through matched Parse Users
                NSString *normalisedPhoneNumberString = user.username;
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"normalisedPhoneNumber = %@", normalisedPhoneNumberString];
                request.predicate = predicate;
                NSArray *emailMatches = [self.contactsDatabase.managedObjectContext executeFetchRequest:request error:nil];
                
                for(Contact *contact in emailMatches)
                {
                    if(![contact.signedUp isEqualToNumber:[NSNumber numberWithBool:YES]])
                    {
                        contact.signedUp = [NSNumber numberWithBool:YES];
                        contact.parseID = user.objectId;
                    }
                    
                }
                
                
            }*/
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            parseReturned(NO, error, nil);
        }
        
        
        
        //[self.delegate finishedMatchingContacts];
    }];
    
}

+(void)shredderUserForContact:(Contact *)contact withCompletionBlock:(ParseReturnedArray)parseReturnedArray{
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" equalTo:contact.normalisedPhoneNumber];
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        parseReturnedArray(YES, error, objects);
        
    }];
    
}

#pragma mark - Image Functions

+(void)startUploadingImages:(NSArray *)imagesArray{
    
    PFFile *thumbnailFile = [imagesArray objectAtIndex:0];
    PFFile *photoFile = [imagesArray objectAtIndex:1];
    
    [thumbnailFile saveInBackground];
    [photoFile saveInBackground];

    
}

@end

//
//  ParseManager.m
//  Shredder
//
//  Created by Shredder on 08/02/2013.
//
//

#import "ParseManager.h"
#import <Parse/Parse.h>
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
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Messages Found: %i", [objects count]);
            NSArray *messagePermissionsArray = [MessagePermission convertPFObjectArraytoMessagePermissionsArray:objects];
            parseReturnedArray(YES, error, messagePermissionsArray);
        } else {
            // Log details of the failure
            parseReturnedArray(NO, error, objects);
        }
    }];
    
}

+(void)retrieveAllReportsForShredderUser:(ShredderUser *)user withCompletionBlock:(ParseReturnedArray)parseReturnedArray{
    
    PFQuery *query = [PFQuery queryWithClassName:@"MessagePermission"];
    [query whereKey:@"sender" equalTo:user];
    [query whereKey:@"messageShredded" equalTo:[NSNumber numberWithBool:YES]];
    [query includeKey:@"recipient"];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Reports Found: %@", [objects count]);
            parseReturnedArray(YES, error, objects);
        } else {
            // Log details of the failure
            parseReturnedArray(NO, error, objects);
        }
    }];
    
}

+(void)sendMessage:(Message *)message withCompletionBlock:(ParseReturned)parseReturned{
    
    PFObject *pfMessage = message.message;
    
    [pfMessage setObject:[PFUser currentUser] forKey:@"sender"];
    [pfMessage setObject:message.user.pfUser forKey:@"recipient"];
    
    // Create message permission
    message = [ParseManager createMessagePermissionsForMessage:message];
    
    // Set Access
    PFACL *messageACL = [PFACL ACL];
    [messageACL setReadAccess:YES forUser:[PFUser currentUser]];
    [messageACL setWriteAccess:YES forUser:[PFUser currentUser]];
    [messageACL setReadAccess:YES forUser:message.user.pfUser];
    [messageACL setWriteAccess:YES forUser:message.user.pfUser];
    
    pfMessage.ACL = messageACL;
    
    // Request a background execution task to allow us to finish uploading
    // the message even if the app is sent to the background
    UIBackgroundTaskIdentifier *backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskID];
    }];

    
    [pfMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        if(succeeded){
            
            // Create our installation query
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"owner" equalTo:message.user.pfUser];
            
            
            
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
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your message did not send. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskID];
    }];
    
    
}

+(Message *)createMessagePermissionsForMessage:(Message *)message{
    
    // Create Message Permissions for given message
    // These cannot rely on the message still being present so must incorporate all the info
    PFObject *messagePermission = [PFObject objectWithClassName:@"MessagePermission"];
    [messagePermission setObject:[PFUser currentUser] forKey:@"sender"];
    [messagePermission setObject:message.user.pfUser forKey:@"recipient"];
    [messagePermission setObject:[NSNumber numberWithBool:NO] forKey:@"permissionShredded"];
    [message.message setObject:messagePermission forKey:@"permissions"];
    
    // Set Access
    // Set Access
    PFACL *messagePermissionACL = [PFACL ACL];
    [messagePermissionACL setReadAccess:YES forUser:[PFUser currentUser]];
    [messagePermissionACL setWriteAccess:YES forUser:[PFUser currentUser]];
    [messagePermissionACL setReadAccess:YES forUser:message.user.pfUser];
    [messagePermissionACL setWriteAccess:YES forUser:message.user.pfUser];
    return message;
}

+(void)shredMessage:(Message *)message withCompletionBlock:(ParseReturned)parseReturned{
    
    // Delete Message
    [message.message deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        parseReturned(succeeded, error);
    }];
    
}


#pragma mark - Contact Functions

-(void)checkIfNewContactsAreOnShredder:(NSArray *)newlyUpdatedContacts{
    
    self.contactsForUserCheck = newlyUpdatedContacts;
    
    //[self promptUserForPermissionToUploadContacts];
    [self uploadAndCheckContacts];
}

-(void)promptUserForPermissionToUploadContacts
{
    // Check if user has granted permission to Shredder to upload contacts
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"PermissionToUploadContactsToShredder"] isEqualToNumber:[NSNumber numberWithBool:NO]])
    {
        // Prompt user to allow cross-check with server
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Shredder would like to upload your contacts to check which of your contacts are on Shredder. \n Your contacts will not be saved on our server." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert show];
    } else {
        
        [self uploadAndCheckContacts];
        //[self.delegate finishedMatchingContacts];
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
        [self uploadAndCheckContacts];
        //[self.delegate finishedMatchingContacts];
    }
}

-(void)uploadAndCheckContacts{
    
    /* Retrieve all contacts
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSArray *allContacts = [self.contactsDatabase.managedObjectContext executeFetchRequest:request error:nil];*/
    
    // Array of email addresses
    NSMutableArray *phoneNumberArray = [[NSMutableArray alloc] init];
    
    for(Contact *contact in self.contactsForUserCheck)
    {
        if(contact.normalisedPhoneNumber)
        {
            [phoneNumberArray addObject:contact.normalisedPhoneNumber];
        }
        
    }
    
    // Find Parse contacts which have these email addresses
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" containedIn:phoneNumberArray];
    
    // CALL TO PARSE
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            for(PFUser *user in objects)
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
                
                
            }
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
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

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

+(void)retrieveAllMessagesForShredderUser:(ShredderUser *)user withCompletionBlock:(ParseReturnedArray)parseReturnedArray{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"recipient" equalTo:user];
    [query includeKey:@"sender"];    
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            parseReturnedArray(YES, error, objects);
        } else {
            // Log details of the failure
            parseReturnedArray(NO, error, objects);
        }
    }];
    
}

+(void)retrieveAllMessagePermissionsForShredderUser:(ShredderUser *)user withCompletionBlock:(ParseReturnedArray)parseReturnedArray{
    
    PFQuery *query = [PFQuery queryWithClassName:@"MessagePermissions"];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            parseReturnedArray(YES, error, objects);
        } else {
            // Log details of the failure
            parseReturnedArray(NO, error, objects);
        }
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
    NSMutableArray *emailArray = [[NSMutableArray alloc] init];
    
    for(Contact *contact in self.contactsForUserCheck)
    {
        if(contact.email)
        {
            [emailArray addObject:contact.email];
        }
        
    }
    
    // Find Parse contacts which have these email addresses
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" containedIn:emailArray];
    
    // CALL TO PARSE
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            for(PFUser *user in objects)
            {
                // Iterate through matched Parse Users
                NSString *emailString = user.username;
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email = %@", emailString];
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



@end

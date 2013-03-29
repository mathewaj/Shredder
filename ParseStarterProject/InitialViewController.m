//
//  InitialViewController.m
//  Shredder
//
//  Created by Shredder on 12/02/2013.
//
//

#import "InitialViewController.h"
#import "SignUpPhoneNumberViewController.h"
#import "InboxViewController.h"
#import <Parse/Parse.h>
#import "BackgroundImageHelper.h"
#import "Blocks.h"
#import "MBProgressHUD.h"


@interface InitialViewController ()

@end

@implementation InitialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set background
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:iPhone568Image(@"BackgroundBubbles.png")];
    
	[self checkForSignedInUser];
}

#pragma mark - Check if a signed in user is present

-(void)checkForSignedInUser{
    
    // If no current user direct to log in page
    if(![[PFUser currentUser] username])
    {
        [self startUserSignUpProcess];
        
    } else {
        
        [self startUserSignedInProcess];
    }
}

-(void)startUserSignUpProcess{
    
    [self performSegueWithIdentifier:@"SignUp" sender:self];

}

-(void)startUserSignedInProcess{
    
    if(self.contactsDatabaseManager){
        
        [self contactsDatabaseReadySoProceed];
        
    } else {
        
        [self prepareContactsDatabase];
        
    }
}

#pragma mark - Obtain access to contacts database

-(void)prepareContactsDatabase{
    
    self.contactsDatabaseManager = [[ContactsDatabaseManager alloc] init];
    
    [self.contactsDatabaseManager accessContactsDatabaseWithCompletionHandler:^(BOOL success, ContactsDatabaseManager *manager) {
        
        self.contactsDatabaseManager = (ContactsDatabaseManager *)manager;
        
        // If database already exists
        if(success){
            
            [self contactsDatabaseReadySoProceed];
            
        } else {
            
            // If it doesn't pop up progress display and load
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Importing Contacts...";
            
            [self.contactsDatabaseManager populateDatabaseWithCompletionHandler:^(BOOL success, id contactsDatabaseManager) {
                
                // Remove progress display and proceed
                [hud hide:YES];
                [self contactsDatabaseReadySoProceed];
            }];
            
        }
    }];
    
}

#pragma mark - Launch Inbox View

-(void)contactsDatabaseReadySoProceed{
    [self performSegueWithIdentifier:@"LoggedIn" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SignUp"]){
        UINavigationController *navController = segue.destinationViewController;
        SignUpPhoneNumberViewController *signUpPhoneNumberViewController = [[navController viewControllers] lastObject];
        signUpPhoneNumberViewController.delegate = self;
    }
    
    if([segue.identifier isEqualToString:@"LoggedIn"]){
        UINavigationController *navController = segue.destinationViewController;
        InboxViewController *inboxViewController = [[navController viewControllers] lastObject];
        inboxViewController.contactsDatabaseManager = self.contactsDatabaseManager;
    }
}

@end

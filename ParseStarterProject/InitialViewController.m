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


@interface InitialViewController ()

@end

@implementation InitialViewController

-(void)directLoggedInOrNotLoggedInUserRespectively{
    
    if(![[PFUser currentUser] username])
    {
        [self performSegueWithIdentifier:@"SignUp" sender:self];
        
    } else {
        if(!self.contactsDatabaseManager){
            
            self.contactsDatabaseManager = [[ContactsDatabaseManager alloc] init];
            
            [self.contactsDatabaseManager accessContactsDatabaseWithCompletionHandler:^(BOOL success, ContactsDatabaseManager *manager) {
 
                self.contactsDatabaseManager = (ContactsDatabaseManager *)manager;
                [self contactsDatabaseReadySoProceed];
            }];
            
        } else {
            [self contactsDatabaseReadySoProceed];
        }
    }
}

-(void)signedIn{
    
    [self directLoggedInOrNotLoggedInUserRespectively];
}

-(void)contactsDatabaseReadySoProceed{
    [self performSegueWithIdentifier:@"LoggedIn" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set background
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:iPhone568Image(@"BackgroundBubbles.png")];
    
	[self directLoggedInOrNotLoggedInUserRespectively];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

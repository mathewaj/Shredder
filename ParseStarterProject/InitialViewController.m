//
//  InitialViewController.m
//  Shredder
//
//  Created by Shredder on 12/02/2013.
//
//

#import "InitialViewController.h"
#import <Parse/Parse.h>
#import "BackgroundImageHelper.h"
#import "SignUpPhoneNumberViewController.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)directLoggedInOrNotLoggedInUserRespectively{
    
    if(![[PFUser currentUser] username])
    {
        [self performSegueWithIdentifier:@"SignUp" sender:self];
        
    } else {
        
        [self performSegueWithIdentifier:@"LoggedIn" sender:self];
        
    }
    
}

-(void)signedIn{
    
    [self directLoggedInOrNotLoggedInUserRespectively];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set background
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:iPhone568ImageNamed(@"background.png")]];
    
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
}

@end

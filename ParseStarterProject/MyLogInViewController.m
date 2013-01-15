//
//  MyLogInViewController.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 30/10/2012.
//
//

#import "MyLogInViewController.h"
#import "MySignUpViewController.h"
#import "MBProgressHUD.h"

@interface MyLogInViewController ()

@end

@implementation MyLogInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //[self.fieldsBackground setFrame:CGRectMake(35, 190, 250, 100)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set background
    //[self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    
    //[self.logInView setBackgroundColor:[UIColor clearColor]];
    
    // Add login field background
    //self.fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoginFieldBG.png"]];
    //[self.logInView insertSubview:self.fieldsBackground atIndex:1];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"mostRecentUsername"])
    {
        self.logInView.usernameField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"mostRecentUsername"];
        [self.logInView.passwordField becomeFirstResponder];
        
    } else {
       self.logInView.usernameField.placeholder = @"Email Address"; 
    }
	
    [self.logInView.usernameField setKeyboardType:UIKeyboardTypeEmailAddress];
    self.logInView.passwordField.placeholder = @"PIN";
    [self.logInView.passwordField setKeyboardType:UIKeyboardTypeNumberPad];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginLogo.png"]];
    
    self.logInView.logo = logo;

    
}

-(void)viewDidAppear:(BOOL)animated
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

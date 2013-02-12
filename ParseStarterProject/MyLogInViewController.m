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
#import <QuartzCore/QuartzCore.h>
#import "BackgroundImageHelper.h"

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
    CGFloat xOffset = 50;
    self.logInView.usernameField.frame = CGRectMake(self.logInView.usernameField.frame.origin.x + xOffset, self.logInView.usernameField.frame.origin.y, self.logInView.usernameField.frame.size.width - xOffset, self.logInView.usernameField.frame.size.height);
    self.logInView.passwordField.frame = CGRectMake(self.logInView.passwordField.frame.origin.x + xOffset, self.logInView.passwordField.frame.origin.y, self.logInView.passwordField.frame.size.width - xOffset, self.logInView.passwordField.frame.size.height);
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set background
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:iPhone568ImageNamed(@"LoginBackground.png")]];
    
    // Set sign up label colour
    self.logInView.signUpLabel.textColor = [UIColor whiteColor];
    
    // Set username textfield properties
    self.logInView.usernameField.textColor = [UIColor grayColor];
    [self.logInView.usernameField setKeyboardType:UIKeyboardTypeEmailAddress];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"mostRecentUsername"])
    {
        self.logInView.usernameField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"mostRecentUsername"];
        [self.logInView.passwordField becomeFirstResponder];
        
    } else {
        self.logInView.usernameField.placeholder = @"Email Address";
    }
    
    // Set password textfield properties
    self.logInView.passwordField.textColor = [UIColor grayColor];
    [self.logInView.passwordField setKeyboardType:UIKeyboardTypeNumberPad];
    self.logInView.passwordField.placeholder = @"PIN";
    
    // Get rid of automatic logo
    self.logInView.logo = nil;
    
    // Remove text shadows
    CALayer *layer = self.logInView.usernameField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.logInView.passwordField.layer;
    layer.shadowOpacity = 0.0f;
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

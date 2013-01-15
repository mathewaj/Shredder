//
//  MySignUpViewController.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 30/10/2012.
//
//

#import "MySignUpViewController.h"

@interface MySignUpViewController ()

@end

@implementation MySignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set background
    //[self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    
	self.signUpView.usernameField.placeholder = @"Email Address";
    [self.signUpView.usernameField setKeyboardType:UIKeyboardTypeEmailAddress];
    self.signUpView.passwordField.placeholder = @"PIN";
    [self.signUpView.passwordField setKeyboardType:UIKeyboardTypeNumberPad];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginLogo.png"]];
    
    self.signUpView.logo = logo;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

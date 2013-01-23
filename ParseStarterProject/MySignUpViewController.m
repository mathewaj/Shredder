//
//  MySignUpViewController.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 30/10/2012.
//
//

#import "MySignUpViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MySignUpViewController ()

@end

@implementation MySignUpViewController

#define isPhone568 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)
#define iPhone568ImageNamed(image) (isPhone568 ? [NSString stringWithFormat:@"%@-568h.%@", [image stringByDeletingPathExtension], [image pathExtension]] : image)
#define iPhone568Image(image) ([UIImage imageNamed:iPhone568ImageNamed(image)])

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
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:iPhone568ImageNamed(@"SignUpBackground.png")]];
    
    // Set username field properties
    self.signUpView.usernameField.textColor = [UIColor grayColor];
	self.signUpView.usernameField.placeholder = @"Email Address";
    [self.signUpView.usernameField setKeyboardType:UIKeyboardTypeEmailAddress];
    
    // Set password field properties
    self.signUpView.passwordField.textColor = [UIColor grayColor];
    self.signUpView.passwordField.placeholder = @"PIN";
    [self.signUpView.passwordField setKeyboardType:UIKeyboardTypeNumberPad];
    
    // Get rid of automatic logo
    self.signUpView.logo = nil;
    
    // Remove text shadows
    CALayer *layer = self.signUpView.usernameField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.signUpView.passwordField.layer;
    layer.shadowOpacity = 0.0f;
    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat xOffset = 50;
    self.signUpView.usernameField.frame = CGRectMake(self.signUpView.usernameField.frame.origin.x + xOffset, self.signUpView.usernameField.frame.origin.y, self.signUpView.usernameField.frame.size.width - xOffset, self.signUpView.usernameField.frame.size.height);
    self.signUpView.passwordField.frame = CGRectMake(self.signUpView.passwordField.frame.origin.x + xOffset, self.signUpView.passwordField.frame.origin.y, self.signUpView.passwordField.frame.size.width - xOffset, self.signUpView.passwordField.frame.size.height);
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

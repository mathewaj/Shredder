//
//  LoginViewController.m
//  Shredder
//
//  Created by Shredder on 25/02/2013.
//
//

#import "LoginViewController.h"
#import "Blocks.h"
#import "MGBox.h"
#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:iPhone568ImageNamed(@"background.png")]];
    
    self.scrollView = [MGScrollView scrollerWithSize:self.view.bounds.size];
    [self.view addSubview:self.scrollView];
    
    [self promptForPassword];
    
}

-(void)promptForPassword {
    
    MGTableBoxStyled *section = MGTableBoxStyled.box;
    section.topMargin = 30;
    section.bottomMargin = 20;
    [self.scrollView.boxes addObject:section];
    
    // a default row size
    CGSize rowSize = (CGSize){304, 70};
    
    // Header
    MGLineStyled *header = [MGLineStyled line];
    header.middleItems = [NSArray arrayWithObjects:@"Shredder", [UIImage imageNamed:@"Padlock.png"], nil];
    header.font = HEADER_FONT;
    header.minHeight = 60;
    [section.topLines addObject:header];
    
    
    MGTableBoxStyled *section2 = MGTableBoxStyled.box;
    [self.scrollView.boxes addObject:section2];
    
    // Prompt user for password
    MGLineStyled *detailRow = MGLineStyled.line;
    detailRow.multilineMiddle =  @"Please enter your password";
    detailRow.minHeight = 70;
    [section2.topLines addObject:detailRow];
    
    // A password field
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 200, 30)];
    self.passwordTextField.placeholder = @"password";
    self.passwordTextField.textAlignment = UITextAlignmentCenter;
    self.passwordTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.passwordTextField.secureTextEntry = YES;
    [self addSecondAccessoryViewToKeyboardOfTextView:self.passwordTextField];
    
    MGLineStyled *passwordEntryRow = MGLineStyled.line;
    passwordEntryRow.middleItems = [NSArray arrayWithObject:self.passwordTextField];
    passwordEntryRow.minHeight = 70;
    [section2.topLines addObject:passwordEntryRow];
    
    [self.passwordTextField becomeFirstResponder];
    [self.scrollView layoutWithSpeed:1 completion:nil];
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addSecondAccessoryViewToKeyboardOfTextView:(UITextField *)textField{
    
    UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:textField action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishedEnteringPassword:)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolbar setItems:[NSArray arrayWithObjects:extraSpace, doneButton, nil]];
    textField.inputAccessoryView = toolbar;
    
}

-(void)finishedEnteringPassword:(UIBarButtonItem *)sender{
    
    if([self.passwordTextField.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"]]){
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect Password" message:@"Please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
    
}



@end
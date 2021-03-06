//
//  SignUpPhoneNumberViewController.m
//  Shredder
//
//  Created by Shredder on 14/02/2013.
//
//

#import "SignUpPhoneNumberViewController.h"
#import "PhoneNumberManager.h"
#import "ParseManager.h"


@interface SignUpPhoneNumberViewController ()

@end

@implementation SignUpPhoneNumberViewController



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SelectCountry"]){
        SignUpDetailsViewController *vc = (SignUpDetailsViewController *)segue.destinationViewController;
        vc.delegate = self;
        [self.scrollView.boxes removeAllObjects];
        self.phoneNumberTextField = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Set background
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:iPhone568ImageNamed(@"BackgroundBubbles.png")]];
    
    self.scrollView = [MGScrollView scrollerWithSize:self.view.bounds.size];
    [self.view addSubview:self.scrollView];
    
    self.countryCodeInfo = [PhoneNumberManager getCurrentCountryCodeInfo];
    
    [self promptForPhoneNumber];
    
}

-(void)promptForPhoneNumber{
    
    // a default row size
    CGSize rowSize = (CGSize){304, 60};

    MGTableBoxStyled *section2 = MGTableBoxStyled.box;
    section2.topMargin = 25;
    [self.scrollView.boxes addObject:section2];
    
    // Prompt user for country and phone number
    MGLineStyled *detailRow = MGLineStyled.line;
    detailRow.multilineMiddle = @"Please confirm your country code and enter your phone number";
    detailRow.minHeight = 60;
    [section2.topLines addObject:detailRow];
    
    // a string on the left and disclosure button on the right
    MGLineStyled *countrySelectionRow = [MGLineStyled lineWithLeft:self.countryCodeInfo.countryName
                                              right:[UIImage imageNamed:@"disclosure.png"] size:rowSize];
    countrySelectionRow.onTap = ^{
        [self performSegueWithIdentifier:@"SelectCountry" sender:self];
    };
    [section2.topLines addObject:countrySelectionRow];
    
    // A row with two textfields
    self.countryCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 10, 50, 30)];
    self.countryCodeTextField.text = self.countryCodeInfo.countryCallingCode;
    self.countryCodeTextField.textAlignment = UITextAlignmentCenter;
    self.countryCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.countryCodeTextField.font = IMPACT_FONT;
    [self addAccessoryViewToKeyboardOfTextView:self.countryCodeTextField];
    
    self.phoneNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 200, 30)];
    self.phoneNumberTextField.placeholder = @"Your Phone Number";
    self.phoneNumberTextField.textAlignment = UITextAlignmentLeft;
    self.phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneNumberTextField.font = IMPACT_FONT;
    [self addAccessoryViewToKeyboardOfTextView:self.phoneNumberTextField];
    
    MGLineStyled *phoneNumberEntryRow = [MGLineStyled line];
    phoneNumberEntryRow.minHeight = 50;
    phoneNumberEntryRow.middleItems = [NSArray arrayWithObjects:@"+", self.countryCodeTextField, self.phoneNumberTextField, nil];
    [section2.topLines addObject:phoneNumberEntryRow];
    
    [self.phoneNumberTextField becomeFirstResponder];
    [self.scrollView layoutWithSpeed:1 completion:nil];
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
}

-(void)promptForPassword{
    
    // Get 
    [self.scrollView.boxes removeAllObjects];
    
    MGTableBoxStyled *section2 = MGTableBoxStyled.box;
    section2.topMargin = 25;
    [self.scrollView.boxes addObject:section2];
    
    // Prompt user for password
    MGLineStyled *detailRow = MGLineStyled.line;
    detailRow.multilineMiddle = @"Please enter a 4 digit password";
    detailRow.minHeight = 70;
    [section2.topLines addObject:detailRow];
    
    // A password field
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 200, 30)];
    self.passwordTextField.placeholder = @"password";
    self.passwordTextField.textAlignment = UITextAlignmentCenter;
    self.passwordTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.delegate = self;
    [self addSecondAccessoryViewToKeyboardOfTextView:self.passwordTextField];
    
    MGLineStyled *passwordEntryRow = MGLineStyled.line;
    passwordEntryRow.middleItems = [NSArray arrayWithObject:self.passwordTextField];
    passwordEntryRow.minHeight = 70;
    [section2.topLines addObject:passwordEntryRow];
    
    [self.passwordTextField becomeFirstResponder];
    [self.scrollView layoutWithSpeed:1 completion:nil];
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

-(void)promptForUploadPermission{
    
    [self.scrollView.boxes removeAllObjects];
    
    MGTableBoxStyled *section2 = MGTableBoxStyled.box;
    section2.topMargin = 25;
    [self.scrollView.boxes addObject:section2];
    
    // Prompt user for permission
    MGLineStyled *detailRow = MGLineStyled.line;
    detailRow.multilineMiddle = @"Shredder needs to access your address book, and sync your contacts list.";
    detailRow.minHeight = 70;
    [section2.topLines addObject:detailRow];
    

    MGLineStyled *permissionEntryRow = MGLineStyled.line;
    // Create an OK button
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(280.0, 10.0, 156.0, 53.0);
    [button setBackgroundImage:[UIImage imageNamed:@"OKButton.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"OKButtonPressed.png"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(finishedEnteringUploadPermission) forControlEvents:UIControlEventTouchUpInside];
    
    
    // Set row
    permissionEntryRow.minHeight = 100;
    permissionEntryRow.middleItems = [NSArray arrayWithObject:button];
    [section2.topLines addObject:permissionEntryRow];
    
    [self.scrollView layoutWithSpeed:1 completion:nil];
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
}


#pragma mark - Control

-(void)finishedEnteringPhoneNumber:(UIBarButtonItem *)button{
    
    [self.countryCodeTextField resignFirstResponder];
    [self.phoneNumberTextField resignFirstResponder];
    self.phoneNumber = [NSString stringWithFormat:@"+%@%@", self.countryCodeTextField.text, self.phoneNumberTextField.text];
    
    if(![PhoneNumberManager isViablePhoneNumber:self.phoneNumberTextField.text forCountryCode:self.countryCodeTextField.text]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This does not seem to be a valid phone number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Please confirm that %@ is your phone number", self.phoneNumber] delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles:@"Cancel", nil];
        [alert show];
        
    }
    
}

-(void)finishedEnteringPassword:(UIBarButtonItem *)button{
    
    // Ensure at least four digits in code
    if(![self fourDigitPassword:self.passwordTextField.text])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"4 digit password required" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    } else {
        
        [self promptForUploadPermission];
        
    }
}

-(void)finishedEnteringUploadPermission{
    
    
    // Save Country Code to user defaults for later use
    [[NSUserDefaults standardUserDefaults] setObject:self.countryCodeInfo.countryCallingCode forKey:@"CurrentCountryCallingCode"];
    
    [ParseManager signUpWithPhoneNumber:self.phoneNumber andPassword:self.passwordTextField.text withCompletionBlock:^(BOOL success, NSError *error) {
        
        if(!success){
            
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
            // User may be already signed up
            [ParseManager loginWithPhoneNumber:self.phoneNumber andPassword:self.passwordTextField.text withCompletionBlock:^(BOOL success, NSError *error) {
                if(!success){
                    
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                    
                } else {
                    
                    [self loggedIn];
                    
                }
            }];
            
        } else {
            
            [[NSUserDefaults standardUserDefaults] setObject:self.countryCodeInfo.countryCallingCode forKey:@"phoneNumber"];
            
            [self loggedIn];
        
        }
        
        
        
    }];

    
    
    
}

-(void)loggedIn{
    
    // Save password
    [[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField.text forKey:@"password"];
    
    // Send Welcome Message
    [ParseManager grantAccessToWelcomeMessageForUser:[PFUser currentUser]];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate startUserSignedInProcess];
    }];
    
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        NSLog(@"OK");
        self.phoneNumber = [NSString stringWithFormat:@"+%@%@",self.countryCodeTextField.text, self.phoneNumberTextField.text];
        [self.countryCodeTextField resignFirstResponder];
        [self.phoneNumberTextField resignFirstResponder];
        
        // Accept phone number and move on to passwords
        [self promptForPassword];
        
    } else {
        
        NSLog(@"Cancel");
    }
}

#pragma mark - Delegate method

-(void)countrySelected:(CountryCodeInformation *)countryCodeInfo{
    
    self.countryCodeInfo = countryCodeInfo;
    [self promptForPhoneNumber];
    
}

#pragma mark - View Adjustments

-(void)addAccessoryViewToKeyboardOfTextView:(UITextField *)textField{
    
    UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:textField action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishedEnteringPhoneNumber:)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolbar setItems:[NSArray arrayWithObjects:extraSpace, doneButton, nil]];
    textField.inputAccessoryView = toolbar;

}

-(void)addSecondAccessoryViewToKeyboardOfTextView:(UITextField *)textField{
    
    UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:textField action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishedEnteringPassword:)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolbar setItems:[NSArray arrayWithObjects:extraSpace, doneButton, nil]];
    textField.inputAccessoryView = toolbar;
    
}



#pragma mark - Password Textfield Validation

// Do not allow passwords longer than 4 digits
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(newLength > 4){

        return NO;
        
    } else {
        return YES;
    }

}

// Check to ensure password is at least four digits
-(BOOL)fourDigitPassword:(NSString *)password{
    
    NSUInteger newLength = [password length];
    if(newLength != 4){
        
        return NO;
        
    } else {
        return YES;
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

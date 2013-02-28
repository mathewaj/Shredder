//
//  SignUpPhoneNumberViewController.h
//  Shredder
//
//  Created by Shredder on 14/02/2013.
//
//

#import <UIKit/UIKit.h>
#import "SignUpDetailsViewController.h"
#import "MGScrollView.h"
#import "MGBase.h"
#import "MGBox.h"
#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"
#import "Blocks.h"
#import "CountryCodeInformation.h"

@protocol SignUpPhoneNumberViewControllerProtocol <NSObject>

-(void)signedIn;

@end

@interface SignUpPhoneNumberViewController : UIViewController <UIAlertViewDelegate>

// 1. Verify phone number
// 2. Accept Password

// View: Scroll View
@property (nonatomic, strong) MGScrollView *scrollView;

// View: TextFields
@property (nonatomic, strong) UITextField *countryCodeTextField;
@property (nonatomic, strong) UITextField *phoneNumberTextField;
@property (nonatomic, strong) UITextField *passwordTextField;

// Model: Country Code
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) CountryCodeInformation *countryCodeInfo;


@property (nonatomic, weak) id <SignUpPhoneNumberViewControllerProtocol> delegate;

@end

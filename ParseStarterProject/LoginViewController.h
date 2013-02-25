//
//  LoginViewController.h
//  Shredder
//
//  Created by Shredder on 25/02/2013.
//
//

#import <UIKit/UIKit.h>
#import "MGScrollView.h"

@interface LoginViewController : UIViewController

// View: MGScrollView
@property(nonatomic, strong) MGScrollView *scrollView;

@property (nonatomic, strong) UITextField *passwordTextField;

@end

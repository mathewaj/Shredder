//
//  LoginViewController.h
//  Shredder
//
//  Created by Shredder on 25/02/2013.
//
//

#import <UIKit/UIKit.h>
#import "MGScrollView.h"

@protocol LoginViewControllerDelegate <NSObject>

-(void)correctPasswordEntered;

@end

@interface LoginViewController : UIViewController

// View: MGScrollView
@property(nonatomic, strong) MGScrollView *scrollView;

@property (nonatomic, strong) UITextField *passwordTextField;

@property (weak, nonatomic) id <LoginViewControllerDelegate> delegate;

@end

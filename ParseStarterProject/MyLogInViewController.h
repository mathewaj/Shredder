//
//  MyLogInViewController.h
//  ParseStarterProject
//
//  Created by Alan Mathews on 30/10/2012.
//
//

#import <Parse/Parse.h>

@interface MyLogInViewController : PFLogInViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (nonatomic, strong) UIImageView *fieldsBackground;


@end

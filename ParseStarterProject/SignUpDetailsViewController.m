//
//  SignUpDetailsViewController.m
//  Shredder
//
//  Created by Shredder on 14/02/2013.
//
//

#import "SignUpDetailsViewController.h"
#import "ParseManager.h"
#import "InitialViewController.h"

@interface SignUpDetailsViewController ()

@end

@implementation SignUpDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)doneButtonPressed:(id)sender {
    
    NSString *phoneNumber = @"+3537207754";
    NSString *password = @"my pass";
    
    
    [ParseManager signUpWithPhoneNumber:phoneNumber andPassword:password withCompletionBlock:^(BOOL succeeded, NSError *error){
        
        if(succeeded){
            [self loggedIn];
        } else {
            
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            NSLog(@"%@", errorString);
            
            // Probably due to user already existing, try to log in
            [ParseManager loginWithPhoneNumber:phoneNumber andPassword:password withCompletionBlock:^(BOOL succeeded, NSError *error){
                
                if(succeeded){
                    [self loggedIn];
                } else {
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    NSLog(@"%@", errorString);
                }
            }];
            
        }
        
    }];

}

-(void)loggedIn{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self.delegate signedIn];
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

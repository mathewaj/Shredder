//
//  InitialViewController.m
//  Shredder
//
//  Created by Shredder on 12/02/2013.
//
//

#import "InitialViewController.h"
#import <Parse/Parse.h>
#import "BackgroundImageHelper.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

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
    
    if([[PFUser currentUser] username])
    {
        [self performSegueWithIdentifier:@"SignUp" sender:self];
    } else {
        [self performSegueWithIdentifier:@"LoggedIn" sender:self];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

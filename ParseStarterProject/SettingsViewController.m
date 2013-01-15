//
//  SettingsViewController.m
//  Shredder
//
//  Created by Alan Mathews on 23/11/2012.
//
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
	// Do any additional setup after loading the view.
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"passwordLockSetting"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"passwordLockSetting"];
    }
    
    self.passwordLockSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"passwordLockSetting"] boolValue];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"shreddingGraphicSetting"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"shreddingGraphicSetting"];
    }
    
    self.shreddingGraphicSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"shreddingGraphicSetting"] boolValue];

    
}
- (IBAction)passwordSwitchChanged:(UISwitch *)sender {
    
    // Set user default to switch value
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:sender.on] forKey:@"passwordLockSetting"];
    
}

- (IBAction)shreddingSwitchChanged:(UISwitch *)sender {
    
    // Set user default to switch value
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:sender.on] forKey:@"shreddingGraphicSetting"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPasswordLockSwitch:nil];
    [self setShreddingGraphicSwitch:nil];
    [super viewDidUnload];
}
@end

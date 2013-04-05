//
//  SettingsViewController.m
//  Shredder
//
//  Created by Alan Mathews on 23/11/2012.
//
//

#import "SettingsViewController.h"
#import "MGBase.h"
#import "MGBox.h"
#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"
#import "Blocks.h"

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
    
    // Settings Box
    MGTableBoxStyled *settingsSection = [MGTableBoxStyled box];
    settingsSection.topMargin = 30;
    [self.scrollView.boxes addObject:settingsSection];
    
    // Settings 1: Password Lock
    self.passwordLockSwitch = [self getPasswordLockSwitch];
    MGLineStyled *setting1 = [MGLineStyled lineWithLeft:@"Password Lock" right:self.passwordLockSwitch size:CGSizeMake(304, 64)];
    setting1.leftPadding = setting1.rightPadding = 16;
    [settingsSection.topLines addObject:setting1];
    
    [self.scrollView layoutWithSpeed:0.3 completion:nil];
    
    
        
}
- (IBAction)doneButtonPressed:(id)sender {

        [self dismissViewControllerAnimated:YES completion:nil];
}

-(UISwitch *)getPasswordLockSwitch{
    
    [TestFlight passCheckpoint:@"Password Lock Changed"];
    
    UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    switchControl.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"passwordLockSetting"] boolValue];
    [switchControl addTarget: self action: @selector(passwordSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    return switchControl;
}

- (void)passwordSwitchChanged:(UISwitch *)sender {
    
    // Set user default to switch value
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:sender.on] forKey:@"passwordLockSetting"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPasswordLockSwitch:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}
@end

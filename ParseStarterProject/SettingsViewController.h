//
//  SettingsViewController.h
//  Shredder
//
//  Created by Alan Mathews on 23/11/2012.
//
//

#import <UIKit/UIKit.h>
#import "MGScrollView.h"

@interface SettingsViewController : UIViewController

// Model: Default Settings

// View: Scroll View
@property (weak, nonatomic) IBOutlet MGScrollView *scrollView;

// View: Switch for Password Lock
@property (strong, nonatomic) UISwitch *passwordLockSwitch;



@end

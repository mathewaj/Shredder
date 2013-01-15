//
//  SettingsViewController.h
//  Shredder
//
//  Created by Alan Mathews on 23/11/2012.
//
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *passwordLockSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *shreddingGraphicSwitch;
@end

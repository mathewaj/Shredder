//
//  InitialViewController.h
//  Shredder
//
//  Created by Shredder on 12/02/2013.
//
//

#import <UIKit/UIKit.h>
#import "SignUpDetailsViewController.h"


// View Controller which presents SignUp View route on first run of app

@interface InitialViewController : UIViewController <SignUpDetailsViewControllerProtocol>

-(void)directLoggedInOrNotLoggedInUserRespectively;

@end

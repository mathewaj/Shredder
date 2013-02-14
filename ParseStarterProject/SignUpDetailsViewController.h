//
//  SignUpDetailsViewController.h
//  Shredder
//
//  Created by Shredder on 14/02/2013.
//
//

#import <UIKit/UIKit.h>

@protocol SignUpDetailsViewControllerProtocol <NSObject>

-(void)signedIn;

@end

@interface SignUpDetailsViewController : UITableViewController

@property (nonatomic, weak) id <SignUpDetailsViewControllerProtocol> delegate;

@end

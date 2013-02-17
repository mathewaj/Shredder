//
//  SignUpDetailsViewController.h
//  Shredder
//
//  Created by Shredder on 14/02/2013.
//
//

#import <UIKit/UIKit.h>
#import "MGScrollView.h"
#import "MGBase.h"
#import "MGBox.h"
#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"
#import "Blocks.h"

@protocol SignUpDetailsViewControllerProtocol <NSObject>

-(void)countrySelected:(NSString *)countryCode;

@end

@interface SignUpDetailsViewController : UIViewController

// View: Scroll View
@property (nonatomic, strong) MGScrollView *scrollView;

@property (nonatomic, weak) id <SignUpDetailsViewControllerProtocol> delegate;

@end

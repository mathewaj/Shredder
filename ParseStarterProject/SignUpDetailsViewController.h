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
#import "CountryCodeInformation.h"

@protocol SignUpDetailsViewControllerProtocol <NSObject>

-(void)countrySelected:(CountryCodeInformation *)countryCodeInfo;

@end

@interface SignUpDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

// View: Scroll View
@property (nonatomic, strong) NSArray *countryCodeInformationList;

@property (nonatomic, weak) id <SignUpDetailsViewControllerProtocol> delegate;

@end

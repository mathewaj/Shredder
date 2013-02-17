//
//  SignUpDetailsViewController.m
//  Shredder
//
//  Created by Shredder on 14/02/2013.
//
//

#import "SignUpDetailsViewController.h"
#import "PhoneNumberManager.h"

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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView = [MGScrollView scrollerWithSize:self.view.bounds.size];
    [self.view addSubview:self.scrollView];
    
    // Get list of countries
    NSArray *countries = [PhoneNumberManager getListOfAllCountryCodes];
    
    // Set up table
    MGTableBoxStyled *section = MGTableBoxStyled.box;
    [self.scrollView.boxes addObject:section];
    
    // a default row size
    CGSize rowSize = (CGSize){304, 44};
    
    // Header
    MGLineStyled *header = [MGLineStyled line];
    header.middleItems = [NSArray arrayWithObject:@"Select Country"];
    [section.topLines addObject:header];
    header.font = HEADER_FONT;
    
    for(NSString *countryCode in countries){
        
        MGLineStyled *countryRow = [MGLineStyled lineWithLeft:[PhoneNumberManager getCountryForCountryCode:countryCode] right:[PhoneNumberManager getCallingCodeForCountryCode:countryCode] size:rowSize];
        
        countryRow.onTap = ^{
            [self.delegate countrySelected:countryCode];
            [self dismissModalViewControllerAnimated:YES];
        };
        
        [section.topLines addObject:countryRow];
        
    }
    
    [self.scrollView layoutWithSpeed:1 completion:nil];
    [self.scrollView scrollToView:section withMargin:8];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

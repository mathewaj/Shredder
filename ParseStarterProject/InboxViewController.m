//
//  InboxViewController.m
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import "InboxViewController.h"
#import "ParseManager.h"
#import "MGBase.h"
#import "MGBox.h"
#import "MGScrollView.h"
#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"

@interface InboxViewController ()

@property (nonatomic, strong) ParseManager *parseManager;

@end

@implementation InboxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
                
        
    }
    return self;
}

-(void)loadInbox{
    
    MGScrollView *scroller = [MGScrollView scrollerWithSize:self.view.bounds.size];
    [self.view addSubview:scroller];
    
    MGTableBoxStyled *section = MGTableBoxStyled.box;
    [scroller.boxes addObject:section];
    
    // a default row size
    CGSize rowSize = (CGSize){304, 40};
    
    // a header row
    MGLineStyled *header = [MGLineStyled lineWithLeft:@"My First Table" right:nil size:rowSize];
    header.leftPadding = header.rightPadding = 16;
    [section.topLines addObject:header];
    
    // a string on the left and a horse on the right
    MGLineStyled *row1 = [MGLineStyled lineWithLeft:@"Left text"
                                              right:[UIImage imageNamed:@"horse.png"] size:rowSize];
    [section.topLines addObject:row1];
    
    [scroller layoutWithSpeed:1 completion:nil];
    [scroller scrollToView:section withMargin:8];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Track return of blocks
    __block int count = 0;
    
    // Retrieve Messages Array from Parse
    [ParseManager retrieveAllMessagesForShredderUser:(ShredderUser *)[PFUser currentUser] withCompletionBlock:^(BOOL success, NSError *error, NSArray *objects){
        count ++;
        self.messagesArray = objects;
        if (count == 2) {
            [self loadInbox];
        }
    }];
    
    // Retrieve MessagesPermissions Array from Parse
    [ParseManager retrieveAllMessagePermissionsForShredderUser:(ShredderUser *)[PFUser currentUser] withCompletionBlock:^(BOOL success, NSError *error, NSArray *objects){
        count ++;
        self.messagePermissionsArray = objects;
        if (count == 2) {
            [self loadInbox];
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  InboxViewController.m
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import "InboxViewController.h"
#import "MessageViewController.h"
#import "ParseManager.h"
#import "Message.h"
#import "MessagePermission.h"
#import "ShredderUser.h"
#import "MGBase.h"
#import "MGBox.h"
#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"

@interface InboxViewController ()

@property (nonatomic, strong) ParseManager *parseManager;

@end

@implementation InboxViewController

//@synthesize messagesArray = _messagesArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
                
        
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    // Set background
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:iPhone568ImageNamed(@"background.png")]];
    
    // Set Scroll View
    self.scrollView = [MGScrollView scrollerWithSize:self.view.bounds.size];
    [self.view addSubview:self.scrollView];
    
    // Set up the tables
    [self loadTables];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadTables];
	
}


-(void)loadTables{
    
    // Track return of blocks
    __block int count = 0;
    
    // Retrieve Messages Array from Parse
    [ParseManager retrieveReceivedMessagePermissionsForCurrentUser:[PFUser currentUser] withCompletionBlock:^(BOOL success, NSError *error, NSArray *objects) {
        count ++;
        self.messagesArray = objects;
        
        if (count == 2) {
            [self loadInboxTable];
        }
    }];
    
    // Retrieve Reports Array from Parse
    [ParseManager retrieveAllReportsForCurrentUser:(ShredderUser *)[PFUser currentUser] withCompletionBlock:^(BOOL success, NSError *error, NSArray *objects){
        count ++;
        self.reportsArray = objects;
        if (count == 2) {
            [self loadInboxTable];
        }
    }];
    
}

-(void)loadInboxTable{
    
    [self.scrollView.boxes removeAllObjects];
    
    // Create Messages Container
    MGTableBoxStyled *messagesSection = [MGTableBoxStyled box];
    messagesSection.topMargin = 50;
    [self.scrollView.boxes addObject:messagesSection];
    
    // If there are no messages, insert a place holder box
    if([self.messagesArray count] == 0){
        
        [messagesSection.topLines addObject:[self getPlaceholderBox]];
        
    } else {
        
        // Populate Message Rows
        for(int i=0;i<[self.messagesArray count];i++){
            
            MessagePermission *myReceivedMessagePermissions = [self.messagesArray objectAtIndex:i];
            [self addMessageBoxForMessagePermission:myReceivedMessagePermissions inSection:messagesSection]; 
            
        }
        
    }
    
    // Set Reports Section
    MGTableBoxStyled *reportsSection = [MGTableBoxStyled box];
    reportsSection.topMargin = 50;
    [self.scrollView.boxes addObject:reportsSection];
    
    // Set Report Rows
    for(int i=0;i<[self.reportsArray count];i++){
        
        MessagePermission *myReceivedReportPermissions = [self.reportsArray objectAtIndex:i];
        [self addReportsBoxForMessagePermission:myReceivedReportPermissions inSection:reportsSection];
        
    }
    
    [self.scrollView layoutWithSpeed:0.3 completion:nil];

    // Add Ribbons to container boxes
    [messagesSection addSubview:[self getMessagesRibbon]];
    [reportsSection addSubview:[self getReportsRibbon]];
    
    
}

#pragma mark - Views

-(MGLineStyled *)getPlaceholderBox{
    
    CGSize rowSize = (CGSize){304, 60};
    
    MGLineStyled *placeholder = [MGLineStyled lineWithSize:rowSize];
    placeholder.minHeight = rowSize.height;
    placeholder.middleItems = [NSArray arrayWithObjects:[UIImage imageNamed:@"sad.gif" ],@"      Your inbox is empty!", nil];
    return placeholder;
}

-(UIImageView *)getMessagesRibbon{
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MessagesRibbon.png"]];
    imageView.origin = CGPointMake(-8, -18);
    return imageView;
    
}

-(UIImageView *)getReportsRibbon{
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ReportsRibbon.png"]];
    imageView.origin = CGPointMake(144, -18);
    return imageView;
    
}

-(MGLineStyled *)addMessageBoxForMessagePermission:(MessagePermission *)messagePermission inSection:(MGTableBoxStyled *)section
{
    CGSize rowSize = (CGSize){250, 60};
    
    // Create attachment icon - TBC
    
    
    //MGLineStyled *messageRow = [MGLineStyled lineWithLeft:[self.contactsDatabaseManager getName:[messagePermission.messagePermission objectForKey:@"sender"]] right:nil size:rowSize];
    NSString *messageHeader = [NSString stringWithFormat:@"**%@**\n//%@//|mush", [self.contactsDatabaseManager getName:[messagePermission.messagePermission objectForKey:@"sender"]], [messagePermission sentTimeAndDateString]];
    MGLineStyled *messageRow = [MGLineStyled lineWithMultilineLeft:messageHeader right:nil width:rowSize.width minHeight:rowSize.height];
    messageRow.leftPadding = messageRow.rightPadding = 16;
    
    __weak id wmessageRow = messageRow;
    
    [section.topLines addObject:messageRow];
    
    messageRow.onTap = ^{
        
        // Remove message
        [section.topLines removeObject:wmessageRow];
        
        // Set flag and perform segue
        [self setComposeRequest:NO];
        [section layoutWithSpeed:0.5 completion:^{
            [self performSegueWithIdentifier:@"Message" sender:messagePermission];
        }];
        //[self.scrollView layoutWithSpeed:0.5 completion:nil];
        
    };
    
    return messageRow;
}

-(MGLineStyled *)addReportsBoxForMessagePermission:(MessagePermission *)messagePermission inSection:(MGTableBoxStyled *)section
{
    CGSize rowSize = (CGSize){250, 60};
    
    MGLineStyled *reportRow = [MGLineStyled lineWithLeft:[self.contactsDatabaseManager getName:[messagePermission.messagePermission objectForKey:@"recipient"]] right:nil size:rowSize];
    reportRow.leftPadding = reportRow.rightPadding = 16;
    
    __weak id wreportRow = reportRow;
    
    [section.topLines addObject:reportRow];
    
    reportRow.onTap = ^{
        
        // Remove message
        [section.topLines removeObject:wreportRow];
        [self.scrollView layoutWithSpeed:0.3 completion:nil];
        // Also remove header if last report, TBC
        
        [ParseManager deleteReport:messagePermission withCompletionBlock:^(BOOL success, NSError *error) {
            // Handle return - TBC
        }];
        
    };
    
    return reportRow;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"SelectContact"]){
        
        ContactsViewController *vc = (ContactsViewController *)segue.destinationViewController;
        vc.contactsDatabaseManager = self.contactsDatabaseManager;
        vc.delegate = self;
        
    }
    
    if([segue.identifier isEqualToString:@"Message"]){
        
        MessageViewController *vc = (MessageViewController *)segue.destinationViewController;
        // Check whether compose or shred request
        vc.composeMode = self.isComposeRequest;
        
        // Pass on access to contacts database
        vc.contactsDatabaseManager = self.contactsDatabaseManager;
        
        if(self.isComposeRequest){
            vc.contact = (ShredderUser *)sender;
        } else {
            
            vc.messagePermission = (MessagePermission *)sender;
            
        }
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didSelectShredderUser:(ShredderUser *)user{
    
    // Set flag for compose mode
    [self setComposeRequest:YES];
    [self performSegueWithIdentifier:@"Message" sender:user];
}

@end

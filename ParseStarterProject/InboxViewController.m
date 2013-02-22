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
#import "MGBase.h"
#import "MGBox.h"
#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"
#import "Converter.h"

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
    
    // Create Messages Container
    self.messagesContainer = [MGTableBoxStyled box];
    self.messagesContainer.topMargin = 50;
    [self.scrollView.boxes addObject:self.messagesContainer];
    
    // Set Reports Section
    self.reportsContainer = [MGTableBoxStyled box];
    self.reportsContainer.topMargin = 50;
    [self.scrollView.boxes addObject:self.reportsContainer];
    
    // Listen for new messages
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appReceivedMessage) name:@"ReloadMessagesTable" object:nil];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self checkForMessages];
    
}

-(void)appReceivedMessage
{
    // Check messages when push received
    [self checkForMessages];
    NSLog(@"Got Push!");
}


-(void)checkForMessages{
    
    // Track return of blocks
    __block int count = 0;
    
    // Retrieve Messages Array from Parse
    [ParseManager retrieveReceivedMessagePermissionsForCurrentUser:[PFUser currentUser] withCompletionBlock:^(BOOL success, NSError *error, NSArray *objects) {
        count ++;
        self.messagesArray = objects;
        
        if (count == 2) {
            [self checkForNewMessages];
        }
    }];
    
    // Retrieve Reports Array from Parse
    [ParseManager retrieveAllReportsForCurrentUser:[PFUser currentUser] withCompletionBlock:^(BOOL success, NSError *error, NSArray *objects){
        count ++;
        self.reportsArray = objects;
        if (count == 2) {
            [self checkForNewMessages];
        }
    }];
    
}

-(void)checkForNewMessages{
    
    if(self.existingMessagesArray != self.messagesArray || self.existingReportsArray != self.reportsArray){
        
        self.existingMessagesArray = self.messagesArray;
        self.existingReportsArray = self.reportsArray;
        
        [self.messagesContainer.topLines removeAllObjects];
        [self.reportsContainer.topLines removeAllObjects];
        
        [self loadInboxTable];
        
    } else {
        
        // No change
        
    }
    
}

-(void)loadInboxTable{
    
    
    // If there are no messages, insert a place holder box
    if([self.messagesArray count] == 0){
        
        [self.messagesContainer.topLines addObject:[self getPlaceholderBox]];
        
    } else {
        
        // Populate Message Rows
        for(int i=0;i<[self.messagesArray count];i++){
            
            PFObject *receivedMessagePermission = [self.messagesArray objectAtIndex:i];
            [self addMessageBoxForMessagePermission:receivedMessagePermission inSection:self.messagesContainer]; 
        }
        
    }

    
    // Set Report Rows
    for(int i=0;i<[self.reportsArray count];i++){
        
        PFObject *receivedReportsPermission = [self.reportsArray objectAtIndex:i];
        [self addReportsBoxForMessagePermission:receivedReportsPermission inSection:self.reportsContainer];
        
    }
    
    [self layoutInboxScrollView];
    
    
}

#pragma mark - Views

-(void)layoutInboxScrollView{
    
    [self.scrollView layoutWithSpeed:0.3 completion:nil];
    
    // Add Ribbons to container boxes
    [self.messagesContainer addSubview:[self getMessagesRibbon]];
    
    if([self.reportsArray count] !=0 ){
        self.reportsRibbon = [self getReportsRibbon];
        [self.reportsContainer addSubview:self.reportsRibbon];
    } else {
        
    }
    
    
    
}

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

-(MGLineStyled *)addMessageBoxForMessagePermission:(PFObject *)messagePermission inSection:(MGTableBoxStyled *)section
{
    CGSize rowSize = (CGSize){304, 60};
    
    NSString *name = [self.contactsDatabaseManager getNameForUser:[messagePermission objectForKey:@"sender"]];
    NSString *timeAndDate = [Converter timeAndDateStringFromDate:messagePermission.createdAt];

    NSString *messageHeader = [NSString stringWithFormat:@"**%@**\n//%@//|mush", name, timeAndDate];
    MGLineStyled *messageRow = [MGLineStyled line];
    messageRow.multilineLeft = messageHeader;
    messageRow.size = rowSize;
    messageRow.leftPadding = messageRow.rightPadding = 16;
    
    // Check for attachment
    PFObject *message = [messagePermission objectForKey:@"message"];
    if([message objectForKey:@"attachment"])
    {
        messageRow.rightItems = [NSArray arrayWithObject:[UIImage imageNamed:@"PaperClip.png"]];
    }
    
    __weak id wmessageRow = messageRow;
    
    [section.topLines addObject:messageRow];
    
    messageRow.onTap = ^{
        
        // Remove message
        [section.topLines removeObject:wmessageRow];
        
        // Set flag and perform segue
        [self setComposeRequest:NO];
        [self layoutInboxScrollView];
        [self performSegueWithIdentifier:@"Message" sender:messagePermission];
        
    };
    
    return messageRow;
}

-(MGLineStyled *)addReportsBoxForMessagePermission:(PFObject *)messagePermission inSection:(MGTableBoxStyled *)section
{
    CGSize rowSize = (CGSize){304, 60};
    
    NSString *name = [self.contactsDatabaseManager getNameForUser:[messagePermission objectForKey:@"recipient"]];
    NSString *timeAndDate = [Converter timeAndDateStringFromDate:messagePermission.createdAt];
    NSString *reportHeader = [NSString stringWithFormat:@"**%@**\n//%@//|mush", name, timeAndDate];
    
    MGLineStyled *reportRow = [MGLineStyled line];
    reportRow.multilineRight = reportHeader;
    reportRow.size = rowSize;
    reportRow.leftPadding = reportRow.rightPadding = 16;
    
    if([[messagePermission objectForKey:@"screenshotDetected"] isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        
        reportRow.leftItems = [NSArray arrayWithObject:[UIImage imageNamed:@"Flash.png"]];
    }
    
    __weak id wreportRow = reportRow;
    
    [section.topLines addObject:reportRow];
    
    reportRow.onTap = ^{
        
        // Remove message
        [section.topLines removeObject:wreportRow];
        [self layoutInboxScrollView];
        
        [ParseManager deleteReport:messagePermission withCompletionBlock:^(BOOL success, NSError *error) {
            // Handle return - TBC
        }];
        
    };
    
    return reportRow;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
        
    if([segue.identifier isEqualToString:@"Message"]){
        
        MessageViewController *vc = (MessageViewController *)segue.destinationViewController;
        // Check whether compose or shred request
        vc.composeMode = self.isComposeRequest;
        
        // Pass on access to contacts database
        vc.contactsDatabaseManager = self.contactsDatabaseManager;
        
        if(self.isComposeRequest){
            
        } else {
            
            vc.messagePermission = (PFObject *)sender;
            
        }
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark Control

- (IBAction)didPressComposeMessage:(id)sender {
    
    // Set flag for compose mode
    [self setComposeRequest:YES];
    [self performSegueWithIdentifier:@"Message" sender:self];
    
}

#pragma mark - Setters for Arrays
/*
- (void)setMessagesArray:(NSArray *)messagesArray
{
    if (_messagesArray != nil && _messagesArray != _messagesArray)
    {
        return;
    } else {
        _messagesArray = messagesArray;
        [self loadInboxTable];
    }
    
}

- (void)setReportsArray:(NSArray *)reportsArray
{
    if (_reportsArray != nil && _reportsArray != reportsArray)
    {
        return;
    } else {
        _reportsArray = reportsArray;
        [self loadInboxTable];
    }
    
}*/




@end

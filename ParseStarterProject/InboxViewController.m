//
//  InboxViewController.m
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import "InboxViewController.h"
#import "MessageViewController.h"
#import "LoginViewController.h"
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



-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    // Set background
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"BackgroundBubbles.png"]];
    
    /* Set Scroll View
    self.scrollView = [MGScrollView scrollerWithSize:self.view.frame.size];
    [self.view addSubview:self.scrollView];
    */
    
    // Set up the tables
    
    // Create Messages Container
    self.messagesContainer = [MGTableBoxStyled box];
    self.messagesContainer.topMargin = 50;
    [self.scrollView.boxes addObject:self.messagesContainer];
    
    // Set Reports Section
    self.reportsContainer = [MGTableBoxStyled box];
    self.reportsContainer.topMargin = 50;
    self.reportsContainer.bottomMargin = 50;
    [self.scrollView.boxes addObject:self.reportsContainer];
    
    // Check for new messages on these notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMessages) name:@"ReloadMessagesTable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMessages) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // Listen for app backgrounding
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    // Refresh contacts and set app to refresh contacts every time app activated
    [self.contactsDatabaseManager syncAddressBookContacts];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContacts) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

-(void)refreshContacts{
    
    // Refresh contacts database
    [self.contactsDatabaseManager syncAddressBookContacts];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self checkForMessages];
    
}

-(void)loadMessages
{
    // Check messages when push received
    [self checkForMessages];
}


-(void)checkForMessages{
    
    // Track return of blocks
    __block int count = 0;
    
    // Retrieve Messages Array from Parse
    [ParseManager retrieveReceivedMessagePermissionsForCurrentUser:[PFUser currentUser] withCompletionBlock:^(BOOL success, NSError *error, NSArray *objects) {
        count ++;
        self.messagesArray = [objects mutableCopy];
        
        if (count == 2) {
            [self loadInboxTable];
        }
    }];
    
    // Retrieve Reports Array from Parse
    [ParseManager retrieveAllReportsForCurrentUser:[PFUser currentUser] withCompletionBlock:^(BOOL success, NSError *error, NSArray *objects){
        count ++;
        self.reportsArray = [objects mutableCopy];
        if (count == 2) {
            [self loadInboxTable];
        }
    }];
    
}

-(void)loadInboxTable{
    
    // Reset
    [self.messagesContainer.topLines removeAllObjects];
    [self.reportsContainer.topLines removeAllObjects];
    
    
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
        [[self.reportsContainer subviews]
         makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    
    
}

-(MGLineStyled *)getPlaceholderBox{
    
    CGSize rowSize = (CGSize){304, 60};
    
    MGLineStyled *placeholder = [MGLineStyled lineWithSize:rowSize];
    placeholder.minHeight = rowSize.height;
    placeholder.middleItems = [NSArray arrayWithObjects:[UIImage imageNamed:@"SadFace.png"],@"      Your inbox is empty!", nil];
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
    if(!name){
        name = [[messagePermission objectForKey:@"sender"] username];
    }
    NSString *timeAndDate = [Converter nicerTimeAndDateStringFromDate:messagePermission.createdAt];

    NSString *messageHeader = [NSString stringWithFormat:@"**%@**\n%@|mush", name, timeAndDate];
    MGLineStyled *messageRow = [MGLineStyled line];
    messageRow.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    messageRow.leftItems = [NSArray arrayWithObject:messageHeader];
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
        [self.messagesArray removeObject:messagePermission];
        self.existingMessagesArray = self.messagesArray;
        
        // Set flag and perform segue
        [self setComposeRequest:NO];
        [self layoutInboxScrollView];
        [self performSegueWithIdentifier:@"Message" sender:messagePermission];
        
    };
    
    return messageRow;
}

-(MGTableBoxStyled *)addReportsBoxForMessagePermission:(PFObject *)messagePermission inSection:(MGTableBoxStyled *)section
{
    MGTableBoxStyled *reportRow = [MGTableBoxStyled box];
    
    //CGSize rowSize = (CGSize){304, 50};
    
    // Add name box:
    MGLineStyled *nameRow = [MGLineStyled line];
    nameRow.minHeight = 50;
    nameRow.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    NSString *name = [self.contactsDatabaseManager getNameForUser:[messagePermission objectForKey:@"recipient"]];
    NSString *formattedName = [NSString stringWithFormat:@"**%@**|mush", name];
    nameRow.rightItems = [NSArray arrayWithObject:formattedName];
    nameRow.leftPadding = nameRow.rightPadding = 16;
    if([[messagePermission objectForKey:@"screenshotDetected"] isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        nameRow.leftItems = [NSArray arrayWithObject:[UIImage imageNamed:@"ScreenshotDetectedLand.png"]];
    }
    
    
    // Add name of
    MGLineStyled *detailsRow = [MGLineStyled line];
    detailsRow.borderStyle = MGBorderNone;
    detailsRow.underlineType = MGUnderlineBottom;
    detailsRow.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
    detailsRow.minHeight = 20;
    detailsRow.borderStyle = MGBorderEtchedTop;
    NSString *timeAndDateSent = [Converter nicerTimeAndDateStringFromDate:messagePermission.createdAt];
    timeAndDateSent = [NSString stringWithFormat:@"Sent: %@", timeAndDateSent];
    timeAndDateSent = [NSString stringWithFormat:@"%@", timeAndDateSent];
    
    NSString *timeAndDateShredded = [Converter nicerTimeAndDateStringFromDate:[messagePermission objectForKey:@"permissionShreddedAt"]];
    timeAndDateShredded = [NSString stringWithFormat:@"Shredded: %@", timeAndDateShredded];
    timeAndDateShredded = [NSString stringWithFormat:@"%@", timeAndDateShredded];
    
    detailsRow.leftItems = [NSArray arrayWithObject:timeAndDateSent];
    detailsRow.rightItems = [NSArray arrayWithObject:timeAndDateShredded];
    detailsRow.leftPadding = detailsRow.rightPadding = 16;
    //NSString *reportHeader = [NSString stringWithFormat:@"**%@**\n//%@//\n//%@//|mush", name, timeAndDateSent, timeAndDateShredded];
    
    __weak id wnameRow = nameRow;
    __weak id wdetailsRow = detailsRow;
    
    [section.topLines addObject:nameRow];
    [section.topLines addObject:detailsRow];
    
    nameRow.onTap = ^{
        
        // Remove message
        [section.topLines removeObject:wnameRow];
        [section.topLines removeObject:wdetailsRow];
        [self layoutInboxScrollView];
        
        [ParseManager deleteReport:messagePermission withCompletionBlock:^(BOOL success, NSError *error) {
            // Handle return - TBC
        }];
        
        [self.reportsArray removeObject:messagePermission];
        self.existingReportsArray = self.reportsArray;
        
        // Reload to remove ribbon if no reports
        if([self.reportsArray count] == 0){
            [self layoutInboxScrollView];
        }
        
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



#pragma mark - App Backgrounding, Present Login Screen

-(void)appDidEnterBackground
{
    // Set Badge Count
    [self setBadgeCount];
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"passwordLockSetting"] isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        
        // Check if modal view presented and dismiss if so
        // Call Login Screen
        BOOL modalPresent = (BOOL)(self.presentedViewController);
        
        if (modalPresent){
            [self dismissViewControllerAnimated:NO completion:^{
                NSLog(@"In higher view");
                [self presentLoginScreen];
            }];
        } else {
            NSLog(@"In inbox view");
            [self presentLoginScreen];
        }
    }
}

-(void)setBadgeCount{
    
    // Set correct badge count for app
    [ParseManager setBadgeWithNumberOfMessages:[NSNumber numberWithInt:[self.messagesArray count]]];
    
}

-(void)presentLoginScreen
{
    LoginViewController *vc = [[LoginViewController alloc] init];
    [self presentModalViewController:vc animated:NO];
}




- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}
@end

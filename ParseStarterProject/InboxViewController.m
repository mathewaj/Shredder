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
            [self loadInbox];
        }
    }];
    
    // Retrieve Reports Array from Parse
    /*[ParseManager retrieveAllReportsForShredderUser:(ShredderUser *)[PFUser currentUser] withCompletionBlock:^(BOOL success, NSError *error, NSArray *objects){
        count ++;
        self.messagePermissionsArray = objects;
        if (count == 2) {
            [self loadInbox];
        }
    }];*/
    
}

-(void)loadInbox{
    
    [self.scrollView.boxes removeAllObjects];
    
    // Set Messages Section
    MGTableBoxStyled *section = [MGTableBoxStyled box];
    [self.scrollView.boxes addObject:section];
    
    // Set Message Rows
    CGSize rowSize = (CGSize){304, 40};
    for(int i=0;i<[self.messagesArray count];i++){
        
        // For each message create a table row
        MessagePermission *messagePermission = [self.messagesArray objectAtIndex:i];
        
        MGLineStyled *header = [MGLineStyled lineWithLeft:[self.contactsDatabaseManager getName:messagePermission.sender] right:nil size:rowSize];
        header.leftPadding = header.rightPadding = 16;
        
        __weak id wheader = header;
        
        [section.topLines addObject:header];
        header.onTap = ^{
            
            // Remove message
            [section.topLines removeObject:wheader];

            // Set flag and perform segue
            [self setComposeRequest:NO];
            [section layoutWithSpeed:0.5 completion:^{
                [self performSegueWithIdentifier:@"Message" sender:messagePermission];
            }];
            [self.scrollView layoutWithSpeed:0.5 completion:nil];
           
            
            
        };
    }
    
    [self.scrollView layoutWithSpeed:0.3 completion:nil];
    
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
        
        if(self.isComposeRequest){
            vc.contact = (ShredderUser *)sender;
        } else {
            vc.message = (Message *)sender;
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

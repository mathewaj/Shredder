//
//  AllMessagesViewController.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 17/11/2012.
//
//

#import "AllMessagesViewController.h"
#import "ShredderContactsViewController.h"
#import "ComposeMessageViewController.h"
#import "ShredMessageViewController.h"
#import "MBProgressHUD.h"
#import "ContactsDatabaseManager.h"

@interface AllMessagesViewController ()

@end

@implementation AllMessagesViewController

#pragma mark - Table View Setup

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.title = @"My Messages";
        
        // This table displays items in the Message class
        self.className = @"Message";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 25;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appReceivedMessage) name:@"ReloadMessagesTable" object:nil];
        
    }
    
    return self;
}

-(void)appReceivedMessage
{
    [self loadObjects];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set background picture
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [backgroundView setFrame:self.tableView.frame];
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = backgroundView;
    
}

// Run a query which requests all messages sent to current user
- (PFQuery *)queryForTable {
    
    // Set up query which retrieves all messages sent to the current user
    // Does not include reports
    PFQuery *query = [PFQuery queryWithClassName:self.className];
    [query whereKey:@"recipient" equalTo:[PFUser currentUser]];
    [query whereKey:@"report" equalTo:[NSNumber numberWithBool:NO]];
    [query includeKey:@"sender"];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    [query orderByDescending:@"createdAt"];
    
    return query;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    static NSString *cellIdentifier = @"Message Cell";
    
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Retrieve sender user from message
    PFUser *sender = [object objectForKey:@"sender"];
    
    cell.contentView.backgroundColor = [UIColor whiteColor];

    // Retrieve database contact for this person
    ContactsDatabaseManager *contactsDatabaseManager = [[ContactsDatabaseManager alloc] init];
    
    Contact *contact = [contactsDatabaseManager retrieveContactwithParseID:sender.objectId inManagedObjectContext:self.contactsDatabase];
    
    // If contact is available, use contact name, else email
    if(contact)
    {
        cell.textLabel.text = contact.name;
        
    } else if (sender.username)
    {
        cell.textLabel.text = sender.username;
    }
    
    // Configure the cell to show the date created in the subtitle
    NSDate *dateCreated = object.createdAt;
    
    // Calculate dates for today, this week and previous
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[[NSDate alloc] init]];
    
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0]; //This variable should now be pointing at a date object that is the start of today (midnight);
    
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterday = [cal dateByAddingComponents:components toDate:today options:0];
    
    components = [cal components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[[NSDate alloc] init]];
    
    [components setDay:([components day] - ([components weekday] - 1))];
    //NSDate *thisWeek  = [cal dateFromComponents:components];
    
    if([dateCreated compare:today] == NSOrderedDescending) {
        // Just set date to time
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
        timeFormatter.dateFormat = @"HH:mm";
        NSString *time = [timeFormatter stringFromDate:dateCreated];
        cell.detailTextLabel.text = time;
        
    } else if ([dateCreated compare:yesterday] == NSOrderedDescending)
    {
        // Set date to yesterday
        cell.detailTextLabel.text = @"Yesterday";
        
    } else {
        
        // Set date to date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSString *string = [dateFormatter stringFromDate:dateCreated];
        cell.detailTextLabel.text = string;
    }
    
    return cell;
}

#pragma mark - Refresh Table Methods

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkIfUserLoggedInAndRefresh];
}

-(void)checkIfUserLoggedInAndRefresh
{
    PFUser *currentUser = [PFUser currentUser];
    
    // If user logged in refresh table
    if([currentUser username])
    {
        [self loadObjects];
    }
    
}

// Update icon badge when messages are updated
-(void)objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:nil];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = [self.objects count];
}

#pragma mark - User Selections

// If compose button selected
-(void)composeMessage
{    
    [self performSegueWithIdentifier:@"Shredder Contacts" sender:self];
}

// If table row selected
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *message = [self objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"Shred Message" sender:message];
    
}

#pragma mark - User Selection Triggered

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // If segue is to compose message draw up list of contacts
    if([segue.identifier isEqualToString:@"Shredder Contacts"])
    {
        [segue.destinationViewController setContactsDatabase:self.contactsDatabase];
        [segue.destinationViewController setDelegate:self];
    }
    
    // Once contact has been selected, delegate will have fired this segue
    if([segue.identifier isEqualToString:@"Compose Message"])
    {
        [segue.destinationViewController setRecipient:sender];
        
    }
    
    if([segue.identifier isEqualToString:@"Shred Message"])
    {
        // Set message
        [(ShredMessageViewController *)segue.destinationViewController setMessage:sender];
        
        PFUser *senderUser = (PFUser *)[sender objectForKey:@"sender"];
        
        // If not shred report set sender details
        if(senderUser)
        {
            NSString *userID = senderUser.objectId;
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
            request.predicate = [NSPredicate predicateWithFormat:@"parseID = %@",  userID];
            NSArray *contacts = [self.contactsDatabase.managedObjectContext executeFetchRequest:request error:nil];
            Contact *contact = [contacts lastObject];
            
            [(ShredMessageViewController *)segue.destinationViewController setSender:contact];
        }
    }
}

#pragma mark - ShredderContactsViewControllerDelegate Methods

-(void)didSelectContact:(Contact *)contact{
    
    [self performSegueWithIdentifier:@"Compose Message" sender:contact];

}

@end

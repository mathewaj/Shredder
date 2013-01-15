//
//  AllReportsViewController.m
//  Shredder
//
//  Created by Alan Mathews on 27/11/2012.
//
//

#import "AllReportsViewController.h"
#import "Contact.h"

@interface AllReportsViewController ()

@end

@implementation AllReportsViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.title = @"Reports";
        
        // This table displays items in the Message class
        self.className = @"Message";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 25;
    }
    return self;
}

// Run a query which requests all messages sent to current user
- (PFQuery *)queryForTable {
    
    // Set up query
    PFQuery *query = [PFQuery queryWithClassName:self.className];
    [query whereKey:@"sender" equalTo:[PFUser currentUser]];
    [query whereKey:@"report" equalTo:[NSNumber numberWithBool:YES]];
    [query includeKey:@"recipient"];
    
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
    static NSString *cellIdentifier = @"Report Cell";
    
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Set background colour
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    // Retrieve recipient user from message
    PFUser *recipient = [object objectForKey:@"recipient"];
    
    // Retrieve recipient details
    if(recipient){
        
        // Retrieve database contact for this person
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
        request.predicate = [NSPredicate predicateWithFormat:@"parseID = %@", recipient.objectId];
        NSArray *contacts = [self.contactsDatabase.managedObjectContext executeFetchRequest:request error:nil];
        Contact *contact = [contacts lastObject];
        
        // If contact is available, use your contact name
        // Else use their provided email
        if(contact)
        {
            // Configure the cell to show the Sender Name
            cell.textLabel.text = contact.name;
            
        } else if (recipient.username)
        {
            cell.textLabel.text = recipient.username;
        }
        
        
    }
    
    // Configure the cell to show the date created in the subtitle
    cell.detailTextLabel.text = @"Sent: ";
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
    NSDate *yesterday = [cal dateByAddingComponents:components toDate: today options:0];
    
    components = [cal components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[[NSDate alloc] init]];
    
    [components setDay:([components day] - ([components weekday] - 1))];
    //NSDate *thisWeek  = [cal dateFromComponents:components];
    
    if([dateCreated compare:today] == NSOrderedDescending) {
        // Just set date to time
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
        timeFormatter.dateFormat = @"HH:mm";
        NSString *time = [timeFormatter stringFromDate:dateCreated];
        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:time];
        
    } else if ([dateCreated compare:yesterday] == NSOrderedDescending)
    {
        // Set date to yesterday
        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:@"Yesterday"];
        
    } /*else if ([dateCreated compare:thisWeek] == NSOrderedDescending)
    {
        // Set date to day
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
        NSInteger day = [components day];
        NSArray *days = [NSArray arrayWithObjects:@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
        cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:[days objectAtIndex:day]];
        
    } */else {
        
        // Set date to date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSString *string = [dateFormatter stringFromDate:dateCreated];
        cell.detailTextLabel.text =  [cell.detailTextLabel.text stringByAppendingString:string];
    }
    
    if([[object objectForKey:@"report"] isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        
        UILabel *shredded = [[UILabel alloc] initWithFrame:CGRectMake(220, 10, 100, 20)];
        shredded.text = @"Shredded";
        shredded.textColor = [UIColor greenColor];
        [cell addSubview:shredded];
        
    } else {
        
        UILabel *notRead = [[UILabel alloc] initWithFrame:CGRectMake(220, 10, 100, 20)];
        notRead.text = @"Not Read";
        notRead.textColor = [UIColor redColor];
        [cell addSubview:notRead];
    }
    
    return cell;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set background picture
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [backgroundView setFrame:self.tableView.frame];
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.tableView.backgroundView = backgroundView;
    
    // Add notification to request login when app enters foreground
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIfUserLoggedInAndRefresh) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
}

- (IBAction)deleteAllButtonPushed:(id)sender {
    for(PFObject *object in self.objects)
    {
        if(object != [self.objects lastObject])
        {
           [object deleteInBackground]; 
        } else {
            
            [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                
                [self loadObjects];
                
            }];
        }
    }
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // Do nothing
}

@end

//
//  ShredderContactsViewController.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 13/11/2012.
//
//

#import "ShredderContactsViewController.h"
#import "ParseStarterProjectAppDelegate.h"
#import "Contact.h"


@interface ShredderContactsViewController ()

@end

@implementation ShredderContactsViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"Shredder Contacts";
    }
    return self;
    
}

-(void)setupFetchedResultsController{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"signedUp = YES"];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.contactsDatabase.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    // Add notification listener to dismiss if app active
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
	// Do any additional setup after loading the view.
    [self setupFetchedResultsController];
    // Into your modal view controller register it for the given notification
    
    
    
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Shredder Contact";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Shredder Contact"];
    }
    
    // Configure the cell...
    Contact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if([contact.signedUp isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        //UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(250,1,40,42)];
        //imv.image=[UIImage imageNamed:@"greenShredderStripped.png"];
        //[cell.contentView addSubview:imv];
        cell.imageView.image = [UIImage imageNamed:@"greenShredderStripped.png"];
    }
    
    cell.textLabel.text = contact.name;
    cell.detailTextLabel.text = contact.email;
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate didSelectContact:contact];
    }];
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
}

@end

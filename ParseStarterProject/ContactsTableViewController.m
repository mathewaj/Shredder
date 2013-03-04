//
//  ContactsTableViewController.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 12/11/2012.
//
//

#import "ContactsTableViewController.h"
#import "Contact.h"
#import "ContactDetailViewController.h"
#import "NewContactViewController.h"
#import "MBProgressHUD.h"


@interface ContactsTableViewController ()

@end

@implementation ContactsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    self.title = @"Contacts";
    [self setupFetchedResultsController];

    
}


-(void)viewDidAppear:(BOOL)animated{
    // Scan Parse everytime contacts is opened
    //[self scanParseForNewContacts];
    
}


-(void)setupFetchedResultsController{
    
    [self.contactsDatabase.managedObjectContext setStalenessInterval:0];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    NSSortDescriptor *descriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    request.sortDescriptors = [NSArray arrayWithObjects: descriptor2, nil];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.contactsDatabase.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Contact Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Contact Cell"];
    }
            
    Contact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if([contact.signedUp isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(220,1,40,42)];
        imv.image=[UIImage imageNamed:@"greenShredderStripped.png"];
        [cell.contentView addSubview:imv];
        
    } else {
        
        [[cell.contentView subviews]
                          makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    cell.textLabel.text = contact.name;
    //cell.detailTextLabel.text = contact.email;

    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Contact Detail"])
    {
        [segue.destinationViewController setContact:[self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow]];
    }
    
    if([segue.identifier isEqualToString:@"New Contact"])
    {
        [segue.destinationViewController setContactsDatabase:self.contactsDatabase];
    }
}

-(void)scanParseForNewContacts{
    AddressBookHelper *addressBookHelper = [[AddressBookHelper alloc] init];
    addressBookHelper.contactsDatabase = self.contactsDatabase;
    addressBookHelper.delegate = self;
    //[addressBookHelper checkWhichContactsSignedUp];
}

-(void)finishedMatchingContacts
{
    [self.tableView reloadData];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    
}






@end

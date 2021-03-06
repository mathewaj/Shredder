//
//  ContactsViewControllerII.m
//  Shredder
//
//  Created by Shredder on 21/02/2013.
//
//

#import "ContactsViewControllerII.h"


@interface ContactsViewControllerII ()

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *shredderFetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *shredderSearchFetchedResultsController;

@property (strong, nonatomic) IBOutlet UISearchDisplayController *mySearchDisplayController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation ContactsViewControllerII

#pragma mark -
#pragma mark View


- (void)loadView
{
    [super loadView];
    //UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44.0)];
    //searchBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    //searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    //self.tableView.tableHeaderView = searchBar;
    
    //self.mySearchDisplayController
    self.mySearchDisplayController.delegate = self;
    self.mySearchDisplayController.searchResultsDataSource = self;
    self.mySearchDisplayController.searchResultsDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set table
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
    {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:self.savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
    // Refresh contacts database
    //[self.contactsDatabaseManager syncAddressBookContacts];

}


#pragma mark - Controller Access to Model

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    if(self.segmentedControl.selectedSegmentIndex == 0)
    {
       return tableView == self.tableView ? self.shredderFetchedResultsController : self.shredderSearchFetchedResultsController;
    } else {
        return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
    }
    
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
{
    Contact *contact = [fetchedResultsController objectAtIndexPath:theIndexPath];
    
    if([contact.signedUp isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        theCell.imageView.image = [UIImage imageNamed:@"greenShredderStripped.png"];
        
    } else {

        theCell.imageView.image = nil;
    }
    
    theCell.textLabel.text = contact.name;
    theCell.detailTextLabel.text = contact.phoneNumber;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)theIndexPath
{
    UITableViewCell *cell = (UITableViewCell *)[theTableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];
    }
    
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:theTableView] configureCell:cell atIndexPath:theIndexPath];
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[self fetchedResultsControllerForTableView:tableView] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[self fetchedResultsControllerForTableView:tableView] sectionForSectionIndexTitle:title atIndex:index];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    NSInteger count = [[[self fetchedResultsControllerForTableView:tableView] sections] count];
    
    NSLog(@"Sections: %i", [[[self fetchedResultsControllerForTableView:tableView] sections] count]);
    
    return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    NSArray *sections = fetchController.sections;
    if(sections.count > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
    
}

#pragma mark -
#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
    // update the filter, in this case just blow away the FRC and let lazy evaluation create another with the relevant search info
    if(self.segmentedControl.selectedSegmentIndex == 0){
        
        self.shredderSearchFetchedResultsController.delegate = nil;
        self.shredderSearchFetchedResultsController = nil;
        
    } else {
        self.searchFetchedResultsController.delegate = nil;
        self.searchFetchedResultsController = nil;
    }


    // if you care about the scope save off the index to be used by the serchFetchedResultsController
    //self.savedScopeButtonIndex = scope;
}


#pragma mark -
#pragma mark Search Bar
- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    // search is done so get rid of the search FRC and reclaim memory
    if(self.segmentedControl.selectedSegmentIndex == 0){
        
        self.shredderSearchFetchedResultsController.delegate = nil;
        self.shredderSearchFetchedResultsController = nil;
        
    } else {
        self.searchFetchedResultsController.delegate = nil;
        self.searchFetchedResultsController = nil;
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark -
#pragma mark FRC Delegate Methods


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)theIndexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self fetchedResultsController:controller configureCell:[tableView cellForRowAtIndexPath:theIndexPath] atIndexPath:theIndexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView endUpdates];
}


#pragma mark -
#pragma mark FRC Creation Code


- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString withShredderUsersOnly:(BOOL)shredderUsersOnly
{
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects: descriptor, nil];
    NSPredicate *filterPredicate = [[NSPredicate alloc] init];
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    
    NSMutableArray *predicateArray = [NSMutableArray array];
    
    // If this is for the search table
    if(searchString.length)
    {
        if(shredderUsersOnly){
            [predicateArray addObject:[NSPredicate predicateWithFormat:@"(signedUp = YES) AND (name CONTAINS[cd] %@)", searchString]];
        } else {
            [predicateArray addObject:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchString]];
        }
        
        filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
        
    // If this is for the full table
    } else {
        
        if (shredderUsersOnly){
            filterPredicate = [NSPredicate predicateWithFormat:@"signedUp = YES"];
        } else {
            
            filterPredicate = nil;
            
        }
        
    }
    
    
    
    [fetchRequest setPredicate:filterPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController;
    if(fetchRequest != nil && self.contactsDatabaseManager.contactsDatabase.managedObjectContext != nil){
        
        aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                    managedObjectContext:self.contactsDatabaseManager.contactsDatabase.managedObjectContext
                                                                                                      sectionNameKeyPath:@"nameInitial"
                                                                                                               cacheName:nil];
        aFetchedResultsController.delegate = self;
        
    }
    

    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    
    return aFetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    _fetchedResultsController = [self newFetchedResultsControllerWithSearch:nil withShredderUsersOnly:NO];
    return _fetchedResultsController;
}

- (NSFetchedResultsController *)searchFetchedResultsController
{
    if (_searchFetchedResultsController != nil)
    {
        return _searchFetchedResultsController;
    }
    _searchFetchedResultsController = [self newFetchedResultsControllerWithSearch:self.searchDisplayController.searchBar.text withShredderUsersOnly:NO];
    return _searchFetchedResultsController;
}

- (NSFetchedResultsController *)shredderFetchedResultsController
{
    if (_shredderFetchedResultsController != nil)
    {
        return _shredderFetchedResultsController;
    }
    _shredderFetchedResultsController = [self newFetchedResultsControllerWithSearch:nil withShredderUsersOnly:YES];
    return _shredderFetchedResultsController;
}

- (NSFetchedResultsController *)shredderSearchFetchedResultsController
{
    if (_shredderSearchFetchedResultsController != nil)
    {
        return _shredderSearchFetchedResultsController;
    }
    _shredderSearchFetchedResultsController = [self newFetchedResultsControllerWithSearch:self.searchDisplayController.searchBar.text withShredderUsersOnly:YES];
    return _shredderSearchFetchedResultsController;
}

- (void)viewDidUnload {
    [self setMySearchDisplayController:nil];
    [self setTableView:nil];
    [self setSegmentedControl:nil];
    [super viewDidUnload];
}

#pragma mark-
#pragma mark User Control

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    
    Contact *contact = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    
    if(contact.parseID){
        
        // If Shredder Contact, confirm user and return to delegate
        [ParseManager shredderUserForContact:contact withCompletionBlock:^(BOOL success, NSError *error, NSArray *objects) {
            if(success){
                PFUser *shredderUser = [objects lastObject]; // handle if more than one - TBC
                [self.delegate didSelectShredderContact:shredderUser];
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                // Handle - TBC
            }
        }];
        
    } else {
        
        // If Non Shredder Contact, present text view
        [self sendInviteToNonShredderUser:contact];
        
    }
    
}
- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate didCancelSelectingContact];
    }];
    
    
}

#pragma mark - Message Composer Methods

-(void)sendInviteToNonShredderUser:(Contact *)contact{
    
    MFMessageComposeViewController *messanger = [[MFMessageComposeViewController alloc] init];
    messanger.messageComposeDelegate = self;
    NSArray *toRecipients = [NSArray arrayWithObject:contact.phoneNumber];
    [messanger setRecipients:toRecipients];
    NSString *messageBody = [NSString stringWithFormat:@"I'd like to send you a confidential message on the new private messaging app Shredder. Please download it from the App Store now!\nhttp://appstore.com/shredderweblimited/shredder"];
    [messanger setBody:messageBody];
    [self presentModalViewController:messanger animated:YES];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    switch (result)
    {
        case MessageComposeResultCancelled: {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Cancelled"
                                                                message:@"You have cancelled the message"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
        }
            
            
            break;
        case MessageComposeResultSent:
        {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Message Sent"
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
        }
            
            break;
        default:
            NSLog(@"Message not sent.");
            break;
    }
    // Remove the mail view
    
    [self dismissModalViewControllerAnimated:YES];
    
}
- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    
    [self.tableView reloadData];
}





@end

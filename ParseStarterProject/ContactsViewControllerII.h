//
//  ContactsViewControllerII.h
//  Shredder
//
//  Created by Shredder on 21/02/2013.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ContactsDatabaseManager.h"

@interface ContactsViewControllerII : UITableViewController <UISearchBarDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate>
{
    // other class ivars
    
    // required ivars for this example
    //NSFetchedResultsController *fetchedResultsController_;
    //NSFetchedResultsController *searchFetchedResultsController_;
    //NSManagedObjectContext *managedObjectContext_;
    
    // The saved state of the search UI if a memory warning removed the view.
    //NSString        *savedSearchTerm_;
    //NSInteger       savedScopeButtonIndex_;
    //BOOL            searchWasActive_;
}



@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

// Model is the contacts database
@property (nonatomic, strong) ContactsDatabaseManager *contactsDatabaseManager;

@end

//
//  FetchedResultsTableControllerViewController.h
//  Shredder
//
//  Created by Shredder on 23/01/2013.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface FetchedResultsTableControllerViewController : UITableViewController <NSFetchedResultsControllerDelegate>

// The controller (this class fetches nothing if this is not set).
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

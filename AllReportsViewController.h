//
//  AllReportsViewController.h
//  Shredder
//
//  Created by Alan Mathews on 27/11/2012.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AllReportsViewController : PFQueryTableViewController

// Model is the contacts database
@property (nonatomic, strong) UIManagedDocument *contactsDatabase;

@end

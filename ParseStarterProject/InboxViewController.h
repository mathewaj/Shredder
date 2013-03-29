//
//  InboxViewController.h
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import <UIKit/UIKit.h>
#import "ContactsDatabaseManager.h"
#import "MGScrollView.h"
#import "MGTableBoxStyled.h"
#import "InboxDataSource.h"

@interface InboxViewController : UIViewController

// Model: Datasource
@property (strong, nonatomic) InboxDataSource *datasource;

// Model: Messages Array from Parse DB
@property(nonatomic, strong) NSMutableArray *messagesArray;
@property(nonatomic, strong) NSMutableArray *existingMessagesArray;

// Model: MessagePermissions Array from Parse DB
@property(nonatomic, strong) NSMutableArray *reportsArray;
@property(nonatomic, strong) NSMutableArray *existingReportsArray;

// Model: Contacts Database
@property (nonatomic, strong) ContactsDatabaseManager *contactsDatabaseManager;

// Control: Open Settings Page

// Control Model: Compose or Shred
@property (nonatomic, assign, getter=isComposeRequest) BOOL composeRequest;

// Control: Compose Message
- (IBAction)didPressComposeMessage:(id)sender;

// View: Scroll View
@property (weak, nonatomic) IBOutlet MGScrollView *scrollView;
//@property (nonatomic, strong) MGScrollView *scrollView;

// View: Messages Container
@property (nonatomic, strong) MGTableBoxStyled *messagesContainer;

// View: Reports Container
@property (nonatomic, strong) MGTableBoxStyled *reportsContainer;

// View: Reports Ribbon
@property (nonatomic, strong) UIImageView *reportsRibbon;

@end

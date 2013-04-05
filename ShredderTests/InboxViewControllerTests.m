//
//  InboxViewControllerTests.m
//  Shredder
//
//  Created by Shredder on 30/03/2013.
//
//

#import "InboxViewControllerTests.h"
#import "InboxViewController.h"

@implementation InboxViewControllerTests {
    
    InboxViewController *controller;
    
}

// This test suite is included to verify that the inbox view controller is meeting its requirements

// When view appears ensure current user is available
// If no user available prompt for login
// If user available request info from datasource
// Should contain a scroll view to display message table and report table
// Should have message view table with messages in chronological order
// Should have report view table with reports in chronological order
// On new messages notification from datasource, layout scroll view
// If no messages, it should display a placeholder cell
// If user selects a message, it should be removed that from the view
// If user selects a message, it should open a MessageViewController
// User selecting a report should remove that report from view
// User selecting a report should send delete message to datasource
// If user selects settings button, it should open a SettingsViewController
// If user selects compose message button, it should open a MessageViewController

- (void)setUp
{
    [super setUp];
    
    controller = [[InboxViewController alloc] init];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark When view appears ensure current user is available

-(void)testThatControllerChecksForCurrentUserOnViewDidAppear{
    
    [controller viewDidAppear:NO];
    STAssertNotNil(controller, @"Controller must check for logged in user on view did appear");
    
}

#pragma mark If no user available prompt for login

-(void)testThatControllerPresentsLoginScreenIfUserNotLoggedIn{
    
    
}

#pragma mark If user available request info from datasource

-(void)testThatControllerRequestsDataIfUserLoggedIn{
    
}

#pragma mark Should contain a scroll view to display message table and report table

-(void)testThatControllerHasAScrollView{
    
}

#pragma mark Should have message view table with messages in chronological order

-(void)testThatControllerHasMessagesView{
    
}

#pragma mark Should have report view table with reports in chronological order

-(void)testThatControllerHasReportsView{
    
}

#pragma mark On new messages notification from datasource, layout scroll view

-(void)testThatControllerRefreshesViewOnNotification{
    
}

#pragma mark If no messages, it should display a placeholder cell
#pragma mark If user selects a message, it should be removed that from the view
#pragma mark If user selects a message, it should open a MessageViewController
#pragma mark User selecting a report should remove that report from view
#pragma mark User selecting a report should send delete message to datasource
#pragma mark If user selects settings button, it should open a SettingsViewController
#pragma mark If user selects compose message button, it should open a MessageViewController


@end

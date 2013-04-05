//
//  MessageViewControllerTests.m
//  Shredder
//
//  Created by Shredder on 01/04/2013.
//
//

#import "MessageViewControllerTests.h"
#import "MessageViewController.h"

@implementation MessageViewControllerTests {
    
    MessageViewController *controller;
    
}

// The message view controller has two modes, compose or shred

- (void)setUp
{
    [super setUp];
    
    controller = [[MessageViewController alloc] init];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

// COMPOSE MODE

// The controller must be able to detect if it is in compose mode
-(void)testIfTheControllerAwareOfWhichModeItIsIn{
    
}

// The controller must be able to hold a message
-(void)testIfTheControllerCanHoldABlankMessage
{
    // Create fake message object
    
    // Assign it to controller and check if not nil
    
}

// The controller must be able to create a blank message if loading in compose mode
-(void)testIfTheControllerCanCreateABlankMessage{
    
    
    
}

// The controller must show the contacts view controller on first viewing if no addressee in the message
-(void)testThatTheControllerKnowsWhenItIsItsFirstAppearance{
    
    
}

-(void)testThatTheControllerShowsContactsViewOnFirstAppearance{
    
}

// The controller must receive a shredder user from the contact view
-(void)testThatTheControllerImplementsContactsViewControllerDelegateMethods{
    
    
}

-(void)testThatTheControllerSetsTheMessageContactOnceSelected{
    
    
    
}

-(void)testThatTheControllerDismissesItselfIfNoUserReturned{
    
    
    
}

// The controller must create a message view for the message once ready
-(void)testThatTheControllerCreatesAMessageView{
    
}

// The controller must be able to show the message view on screen, with or without animation
// The controller must handle attach image instruction from the message view
// The controller must handle cancel button press and dismiss view
// The controller must handle send button press
// The controller must send the message and the selected user to PermissionCreation on send
// The controller must animate the message view off screen on send
// The controller must dismiss view on send

// SHRED MODE
// The controller must be able to hold a populated permission
// The controller must be able to create a message view for the populated permission
// The controller must allo viewing full screen of attachments
// The controller must detect screenshot captures
// The controller must handle shred button press
// The controller must animate the message off screen
// The controller must update the message permission to indicate is shredded
// The controller dismiss the view controller
// The controller must handle reply button press
// The controller must animate the message off screen
// The controller must update the message permission to indicate is shredded
// The controller must launch compose mode with contactee



@end

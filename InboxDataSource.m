//
//  InboxDataSource.m
//  Shredder
//
//  Created by Shredder on 29/03/2013.
//
//

#import "InboxDataSource.h"
#import "ParseManager.h"

@interface InboxDataSource ()

@end

@implementation InboxDataSource



#pragma mark - Inbox View Controller Datasource

-(void)checkForMessages{
    
    // Track return of blocks
    __block int count = 0;
    
    // Retrieve Messages Array from Parse
    [ParseManager retrieveReceivedMessagePermissionsForCurrentUser:[PFUser currentUser] withCompletionBlock:^(BOOL success, NSError *error, NSArray *objects) {
        count ++;
        self.messagesArray = [objects mutableCopy];
        
        if (count == 2) {
            [self didReceiveNewDataNotification];
        }
    }];
    
    // Retrieve Reports Array from Parse
    [ParseManager retrieveAllReportsForCurrentUser:[PFUser currentUser] withCompletionBlock:^(BOOL success, NSError *error, NSArray *objects){
        count ++;
        self.reportsArray = [objects mutableCopy];
        
        if (count == 2) {
            [self didReceiveNewDataNotification];
        }
    }];
    
}

-(void)didReceiveNewDataNotification{
    
    // Broadcast when push notification recieved so that messaging view may reload
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MessagesReceived" object:nil];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInMessagesSection:(NSInteger)section
{

    return [self.messagesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView messageForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return [self.messagesArray objectAtIndex:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInReportsSection:(NSInteger)section
{
    
    return [self.reportsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView reportForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.reportsArray objectAtIndex:indexPath.row];
}

#pragma mark - Inbox View Controller Datasource

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

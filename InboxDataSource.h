//
//  InboxDataSource.h
//  Shredder
//
//  Created by Shredder on 29/03/2013.
//
//

#import <UIKit/UIKit.h>

@interface InboxDataSource : NSObject

-(void)checkForMessages;

// Model: Messages Array from Parse DB
@property(nonatomic, strong) NSMutableArray *messagesArray;

// Model: MessagePermissions Array from Parse DB
@property(nonatomic, strong) NSMutableArray *reportsArray;

@end

//
//  MessagePermission.m
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import "MessagePermission.h"

@implementation MessagePermission

// Converting PFMessages from Parse to Message Objects
+(NSArray *)convertPFObjectArraytoMessagePermissionsArray:(NSArray *)objects{
    
    NSMutableArray *messagesArray = [[NSMutableArray alloc] init];
    
    for (PFObject *object in objects){
        
        MessagePermission *permission = [[MessagePermission alloc] init];
        Message *message = [[Message alloc] initPopulatedMessageWithPFObject:[object objectForKey:@"message"]];
        permission.message = message;
        
        permission.sender = [[ShredderUser alloc] initWithPFUser:[object objectForKey:@"sender"]];
        permission.recipient = [[ShredderUser alloc] initWithPFUser:[object objectForKey:@"recipient"]];
    }
    
    return messagesArray;
    
}
@end

//
//  MessagePermission.m
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import "MessagePermission.h"

@implementation MessagePermission

-(id)initNewMessagePermissionWithShredderUserReceiver:(ShredderUser *)recipient{
    
    self = [super init];
    if (self) {
        
        self.recipient = recipient;
        
        // Create Message Permissions 
        // These cannot rely on the message still being present so must incorporate all the info
        PFObject *messagePermission = [PFObject objectWithClassName:@"MessagePermission"];
        [messagePermission setObject:[PFUser currentUser] forKey:@"sender"];
        [messagePermission setObject:recipient.pfUser forKey:@"recipient"];
        [messagePermission setObject:[NSNumber numberWithBool:NO] forKey:@"permissionShredded"];
        
        // Set Access
        // Set Access
        PFACL *messagePermissionACL = [PFACL ACL];
        [messagePermissionACL setReadAccess:YES forUser:[PFUser currentUser]];
        [messagePermissionACL setWriteAccess:YES forUser:[PFUser currentUser]];
        [messagePermissionACL setReadAccess:YES forUser:recipient.pfUser];
        [messagePermissionACL setWriteAccess:YES forUser:recipient.pfUser];
        
        self.messagePermission = messagePermission;
        
    }
    return self;
    
}

-(id)initPopulatedMessagePermissionWithPFObject:(PFObject *)onlineMessagePermission{
    self = [super init];
    if (self) {
        
        self.messagePermission = onlineMessagePermission;
        self.message = [[Message alloc] initPopulatedMessageWithPFObject:[onlineMessagePermission objectForKey:@"Message"]];
        self.sender = [[ShredderUser alloc] initWithPFUser:[onlineMessagePermission objectForKey:@"sender"]];
        
    }
    return self;
   
}

// Converting PFMessages from Parse to Message Objects
+(NSArray *)convertPFObjectArraytoMessagePermissionsArray:(NSArray *)objects{
    
    NSMutableArray *messagePermissionsArray = [[NSMutableArray alloc] init];
    
    for (PFObject *object in objects){
        
        MessagePermission *permission = [[MessagePermission alloc] initPopulatedMessagePermissionWithPFObject:object];
        permission.messagePermission = object;
        permission.sender = [[ShredderUser alloc] initWithPFUser:[object objectForKey:@"sender"]];
        permission.recipient = [[ShredderUser alloc] initWithPFUser:[object objectForKey:@"recipient"]];
        
        [messagePermissionsArray addObject:permission];
    }
    
    return messagePermissionsArray;
    
}
@end

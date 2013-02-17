//
//  Message.m
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import "Message.h"
#import "ShredderUser.h"

@implementation Message

-(id)initNewMessageWithShredderUserReceiver:(ShredderUser *)recipient{
    
    self = [super init];
    if (self) {
        
        PFObject *pfMessage = [PFObject objectWithClassName:@"Message"];
        [pfMessage setObject:[PFUser currentUser] forKey:@"sender"];
        [pfMessage setObject:recipient.pfUser forKey:@"recipient"];
        
        // Set Access
        PFACL *messageACL = [PFACL ACL];
        [messageACL setReadAccess:YES forUser:[PFUser currentUser]];
        [messageACL setWriteAccess:YES forUser:[PFUser currentUser]];
        [messageACL setReadAccess:YES forUser:recipient.pfUser];
        [messageACL setWriteAccess:YES forUser:recipient.pfUser];
        
        pfMessage.ACL = messageACL;
        
        self.message = pfMessage;
        
        /* Create message permission
        self.messagePermission = [[MessagePermission alloc] initNewMessagePermissionWithShredderUserReceiver:recipient];
        [pfMessage setObject:self.messagePermission.messagePermission forKey:@"permission"];*/
        
    }
    
    return self;
    
}

-(id)initPopulatedMessageWithPFObject:(PFObject *)onlineMessage{
    
    self = [super init];
    if (self) {
        self.message = onlineMessage;
    }
    return self;
    
}

+(NSArray *)convertPFObjectArraytoMessagesArray:(NSArray *)objects{
    NSMutableArray *messagesArray = [[NSMutableArray alloc] init];
    
    for (PFObject *object in objects){
        
        Message *message = [[Message alloc] initPopulatedMessageWithPFObject:object];
        [messagesArray addObject:message];
    }
    
    return messagesArray;
}

-(NSString *)sentTimeAndDateString{
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:self.message.createdAt
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    
    return dateString;
    
}

-(void)attachImages:(NSArray *)images{
    
    PFFile *photoFile = [images objectAtIndex:0];
    PFFile *thumbnailFile = [images objectAtIndex:1];
    
    [self.message setObject:thumbnailFile forKey:@"attachmentThumbnail"];
    [self.message setObject:photoFile forKey:@"attachment"];
    
}

@end

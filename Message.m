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

-(id)initNewMessageWithShredderUserReceiver:(ShredderUser *)user{
    
    self = [super init];
    if (self) {
        self.user = user;
        self.message = [PFObject objectWithClassName:@"Message"];
    }
    return self;
    
}

-(id)initPopulatedMessageWithPFObject:(PFObject *)pfmessage;{
    
    self = [super init];
    if (self) {
        self.user = [[ShredderUser alloc] initWithPFUser:[pfmessage objectForKey:@"sender"]];
        self.message = pfmessage;
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

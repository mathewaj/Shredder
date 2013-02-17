//
//  Message.h
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import <Parse/Parse.h>
#import "ShredderUser.h"

@interface Message : NSObject

-(id)initNewMessageWithShredderUserReceiver:(ShredderUser *)user;
-(id)initPopulatedMessageWithPFObject:(PFObject *)message;
+(NSArray *)convertPFObjectArraytoMessagesArray:(NSArray *)objects;
-(void)attachImages:(NSArray *)images;

// Model: Shredder User
@property (nonatomic, strong) ShredderUser *user;

// Model: Message
@property (nonatomic, strong) PFObject *message;

// Handy retrieval of nicely formatted time and date string
-(NSString *)sentTimeAndDateString;

@end

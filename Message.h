//
//  Message.h
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import "ParseManager.h"
#import "ShredderUser.h"
#import "Contact.h"

@interface Message : NSObject

// Creating Message Objects
-(id)initNewMessageWithShredderUserReceiver:(PFUser *)user;
-(id)initPopulatedMessageWithPFObject:(PFObject *)onlineMessage;

// Converting PFMessages from Parse to Message Objects
+(NSArray *)convertPFObjectArraytoMessagesArray:(NSArray *)objects;

// Attaching images to Message
-(void)attachImages:(NSArray *)images;

// Model: Shredder User
//@property (nonatomic, retain) MessagePermission *messagePermission;

// Model: Message
@property (nonatomic, strong) PFObject *message;

// Reports

// Handy retrieval of nicely formatted time and date string
-(NSString *)sentTimeAndDateString;

@end

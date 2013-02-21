//
//  MessagePermission.h
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import <Parse/Parse.h>
#import "ShredderUser.h"
#import "Message.h"

@interface MessagePermission : NSObject

-(id)initNewMessagePermissionWithShredderUserReceiver:(ShredderUser *)recipient;
-(id)initPopulatedMessagePermissionWithPFObject:(PFObject *)onlineMessagePermission;

@property (nonatomic, strong) PFObject *messagePermission;

@property (nonatomic, strong) ShredderUser *recipient;
@property (nonatomic, strong) ShredderUser *sender;

// Converting PFMessages from Parse to Message Objects
+(NSArray *)convertPFObjectArraytoMessagePermissionsArray:(NSArray *)objects;

@property (nonatomic, strong) Message *message;

//+(void)createMessagePermissionsForMessage:(Message *)message;

+(void)shredMessagePermission:(MessagePermission *)message;

-(NSString *)sentTimeAndDateString;

@end

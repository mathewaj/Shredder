//
//  MessagePermission.h
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import <Parse/Parse.h>
#import "Message.h"

@interface MessagePermission : NSObject

@property (nonatomic, strong) PFObject *messagePermission;

@property (nonatomic, strong) Message *message;

@property (nonatomic, strong) ShredderUser *recipient;
@property (nonatomic, strong) ShredderUser *sender;

// Converting PFMessages from Parse to Message Objects
+(NSArray *)convertPFObjectArraytoMessagePermissionsArray:(NSArray *)objects;

//+(void)createMessagePermissionsForMessage:(Message *)message;

+(void)shredMessagePermission:(MessagePermission *)message;

@end

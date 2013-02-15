//
//  MessagePermission.h
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import <Parse/Parse.h>
#import "Message.h"

@interface MessagePermission : PFObject

+(void)createMessagePermissionsForMessage:(Message *)message;

+(void)shredMessagePermission:(MessagePermission *)message;

@end

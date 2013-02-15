//
//  Message.h
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import <Parse/Parse.h>


@interface Message : PFObject

+(void)sendMessage:(Message *)message;

+(void)shredMessage:(Message *)message;

@end

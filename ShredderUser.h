//
//  ShredderUser.h
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import <Parse/Parse.h>
#import "Contact.h"

@interface ShredderUser : PFUser

+(NSArray *)getShredderUsersForContacts:(NSArray *)contacts;

@end

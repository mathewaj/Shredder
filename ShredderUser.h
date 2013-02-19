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

-(id)initWithPFUser:(PFUser *)pfUser;

// Model: Contact
@property (nonatomic, strong) Contact *contact;

// Model: PFUser
@property (nonatomic, strong) PFUser *pfUser;

@property (nonatomic, strong) UIImage *profilePic;

@end

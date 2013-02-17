//
//  ShredderUser.m
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import "ShredderUser.h"

@implementation ShredderUser

-(id)initWithPFUser:(PFUser *)pfUser{
    
    self = [super init];
    if (self) {
        self.pfUser = pfUser;
        
        // Check for contact
        
    }
    return self;
    
}

-(NSString *)getName{
    
    NSString *name;
    
    // If contact details are available
    if(self.contact){
        name = self.contact.name;
    } else {
        
        // For now, just use phone number
        name = [self.pfUser objectForKey:@"username"];
    }
    
    return name;
    
}

@end

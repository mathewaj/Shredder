//
//  Contact.m
//  Shredder
//
//  Created by Shredder on 24/01/2013.
//
//

#import "Contact.h"
#import "Email.h"


@implementation Contact

@dynamic email;
@dynamic name;
@dynamic parseID;
@dynamic phoneNumber;
@dynamic signedUp;
@dynamic uppercaseFirstLetterOfName;
@dynamic nameInitial;
@dynamic emails;



- (NSString *) nameInitial {
    [self willAccessValueForKey:@"nameInitial"];
    NSString * initial = [[self name] substringToIndex:1];
    [self didAccessValueForKey:@"nameInitial"];
    return initial;
}

@end

//
//  NSString+InitialHelper.m
//  Shredder
//
//  Created by Alan on 17/12/2012.
//
//

#import "NSString+InitialHelper.h"

@implementation NSString (InitialHelper)

- (NSString *)stringGroupByFirstInitial {
    if (!self.length || self.length == 1)
        return self;
    return [self substringToIndex:1];
}

@end

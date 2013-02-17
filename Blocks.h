//
//  Blocks.h
//  Shredder
//
//  Created by Shredder on 25/01/2013.
//
//

#import <Foundation/Foundation.h>

// Typedef a block called ParseReturned which receives a contact and returns a BOOL
typedef void (^ParseReturned) (BOOL success, NSError *error);

typedef void (^ContactsDatabaseReturned) (BOOL success, id contactsDatabaseManager);

typedef void (^ParseReturnedArray) (BOOL success, NSError *error, NSArray *objects);

#define HEADER_FONT            [UIFont fontWithName:@"HelveticaNeue" size:18]

#define IMPACT_FONT            [UIFont fontWithName:@"HelveticaNeue" size:20]

@interface Blocks : NSObject

@end

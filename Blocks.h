//
//  Blocks.h
//  Shredder
//
//  Created by Shredder on 25/01/2013.
//
//

#import <Foundation/Foundation.h>

// Typedef a block called ParseReturned which receives a contact and returns a BOOL
typedef void (^ParseReturned) (BOOL signedUp);

@interface Blocks : NSObject

@end

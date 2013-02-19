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

#define isPhone568 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)
#define iPhone568ImageNamed(image) (isPhone568 ? [NSString stringWithFormat:@"%@-568h.%@", [image stringByDeletingPathExtension], [image pathExtension]] : image)
#define iPhone568Image(image) ([UIImage imageNamed:iPhone568ImageNamed(image)])

@interface Blocks : NSObject

@end

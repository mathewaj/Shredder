//
//  BackgroundImageHelper.h
//  Shredder
//
//  Created by Shredder on 12/02/2013.
//
//

#import <Foundation/Foundation.h>

@interface BackgroundImageHelper : NSObject

#define isPhone568 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)
#define iPhone568ImageNamed(image) (isPhone568 ? [NSString stringWithFormat:@"%@-568h.%@", [image stringByDeletingPathExtension], [image pathExtension]] : image)
#define iPhone568Image(image) ([UIImage imageNamed:iPhone568ImageNamed(image)])

@end

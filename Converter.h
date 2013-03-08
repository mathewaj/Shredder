//
//  Converter.h
//  Shredder
//
//  Created by Shredder on 21/02/2013.
//
//

#import <Foundation/Foundation.h>

@interface Converter : NSObject

+(NSString *)timeAndDateStringFromDate:(NSDate *)date;
+(NSString *)nicerTimeAndDateStringFromDate:(NSDate *)date;
+(NSString *)timeStringFromDate:(NSDate *)date;
+(NSString *)dateStringFromDate:(NSDate *)date;

@end

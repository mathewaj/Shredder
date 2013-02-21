//
//  Converter.m
//  Shredder
//
//  Created by Shredder on 21/02/2013.
//
//

#import "Converter.h"

@implementation Converter

+(NSString *)timeAndDateStringFromDate:(NSDate *)date{
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    
    return dateString;
    
}

@end

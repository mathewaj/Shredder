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

+(NSString *)dateStringFromDate:(NSDate *)date{

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM d"];
    NSString *dateString = [dateFormat stringFromDate:date];
    
    return dateString;
    
}

+(NSString *)timeStringFromDate:(NSDate *)date{
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    
    NSString *dateString = [timeFormatter stringFromDate:date];
    
    return dateString;
    
}



+(NSString *)nicerTimeAndDateStringFromDate:(NSDate *)date{
    
    // Nicely formatted string
    NSString *result;
    
    // Calculate dates for today, this week and previous
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[[NSDate alloc] init]];
    
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0]; //This variable should now be pointing at a date object that is the start of today (midnight);
    
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterday = [cal dateByAddingComponents:components toDate:today options:0];
    
    components = [cal components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[[NSDate alloc] init]];
    
    [components setDay:([components day] - ([components weekday] - 1))];
    //NSDate *thisWeek  = [cal dateFromComponents:components];
    
    if([date compare:today] == NSOrderedDescending) {
        // Just set date to time
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
        timeFormatter.dateFormat = @"HH:mm";
        NSString *time = [timeFormatter stringFromDate:date];
        result = time;
        
    } else if ([date compare:yesterday] == NSOrderedDescending)
    {
        // Set date to yesterday
        result = @"Yesterday ";
        
    } else {
        
        // Set date to date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSString *string = [dateFormatter stringFromDate:date];
        result = string;
    }
    
    return result;
    
}

@end

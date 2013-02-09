//
//  PhoneNumberManager.m
//  Shredder
//
//  Created by Shredder on 09/02/2013.
//
//

#import "PhoneNumberManager.h"

@implementation PhoneNumberManager

+(NSString *)normalisedPhoneNumberWithContactNumber:(NSString *)phoneNumber countryCode:(NSString *)countryCode{
    
    NSString *normalisedPhoneNumber;
    
    // Check if existing international number
    // If so replace any '00' with '+'
    if([phoneNumber hasPrefix:@"+"]){
       
        normalisedPhoneNumber = phoneNumber;
        
    } else if ([phoneNumber hasPrefix:@"00"]){
        // International number, change to +
        normalisedPhoneNumber = @"+";
        phoneNumber = [phoneNumber substringFromIndex:2];
        normalisedPhoneNumber = [normalisedPhoneNumber stringByAppendingString:phoneNumber];
        
    } else if([phoneNumber hasPrefix:@"0"]){
        // Local number
        normalisedPhoneNumber = @"+";
        phoneNumber = [phoneNumber substringFromIndex:1];
        normalisedPhoneNumber = [normalisedPhoneNumber stringByAppendingString:phoneNumber];
    } 
    
    return 
    
}

@end

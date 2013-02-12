//
//  PhoneNumberManager.m
//  Shredder
//
//  Created by Shredder on 09/02/2013.
//
//

#import "PhoneNumberManager.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"


@implementation PhoneNumberManager

+(NSString *)normalisedPhoneNumberWithContactNumber:(NSString *)phoneNumber countryCode:(NSString *)countryCode{
    
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    NSError *error;
    
    NBPhoneNumber *parsedNumber = [phoneUtil parseAndKeepRawInput:phoneNumber defaultRegion:@"IE" error:&error];
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
    
    NSString *parsedNumberString = [phoneUtil format:parsedNumber numberFormat:NBEPhoneNumberFormatE164 error:nil];
    
    return parsedNumberString;
    
}

@end

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

+(NSString *)getCurrentCountryCode{
    
    NSString *currentCountryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    
    return currentCountryCode;
    
}

+(NSString *)getCurrentCountry{
    
    NSString *currentCountryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    
    NSString *country = [PhoneNumberManager getCountryForCountryCode:currentCountryCode];
    
    return country;
    
}

+(NSString *)getCountryForCountryCode:(NSString *)countryCode{
        
    NSString *identifier = [NSLocale localeIdentifierFromComponents:[NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
    NSString *country = [[NSLocale currentLocale] displayNameForKey: NSLocaleIdentifier value: identifier];
    
    return country;
    
}

+(NSString *)getCallingCodeForCountryCode:(NSString *)countryCode{
    
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    
    NSString *callingCode = [phoneUtil countryCodeFromRregionCode:countryCode];
    
    return callingCode;
    
}

+(NSArray *)getListOfAllCountryCodes{
    return [NSLocale ISOCountryCodes];
}

+(NSArray *)getListOfAllCountries{
    
    NSMutableArray *countries = [NSMutableArray arrayWithCapacity: [[NSLocale ISOCountryCodes] count]];
    
    for (NSString *countryCode in [NSLocale ISOCountryCodes])
    {
        NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
        NSString *country = [[NSLocale currentLocale] displayNameForKey: NSLocaleIdentifier value: identifier];
        [countries addObject: country];
    }
    
    NSArray *sortedCountries = [countries sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    return countries;
    
}

+(BOOL)isViablePhoneNumber:(NSString *)number forCountryCode:(NSString *)countryCode{
    
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    
    NSString *completeNumber = [countryCode stringByAppendingString:number];
    
    return [phoneUtil isViablePhoneNumber:completeNumber];
    
}

@end

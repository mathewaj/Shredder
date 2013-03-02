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

+(NSArray *)getListOfAllCountryCodeInformationObjects{
    
    // Create array the size of the locale count
    NSMutableArray *countryCodeInformation = [NSMutableArray arrayWithCapacity: [[NSLocale ISOCountryCodes] count]];
    
    // Retrieve every country code
    for (NSString *countryCode in [NSLocale ISOCountryCodes])
    {
        NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
        NSString *country = [[NSLocale currentLocale] displayNameForKey: NSLocaleIdentifier value: identifier];
        
        
        // Add CountryCodeInfo object to array
        CountryCodeInformation *countryInfo = [[CountryCodeInformation alloc] init];
        countryInfo.countryCode = countryCode;
        countryInfo.countryName = country;
        countryInfo.countryCallingCode = [PhoneNumberManager getCallingCodeForCountryCode:countryCode];
        
        if(countryInfo.countryName && countryInfo.countryCallingCode)
        {
           [countryCodeInformation addObject:countryInfo]; 
        }
        
    }
    
    NSArray *sortedArray;
    sortedArray = [countryCodeInformation sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"countryName" ascending:YES selector:@selector(caseInsensitiveCompare:)]]];
    
    //NSArray *sortedCountries = [countryCodeInformation sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    return sortedArray;
    
    
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
    
    // Create array the size of the locale count
    NSMutableArray *countries = [NSMutableArray arrayWithCapacity: [[NSLocale ISOCountryCodes] count]];
    
    // Retrieve every country code
    for (NSString *countryCode in [NSLocale ISOCountryCodes])
    {
        NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
        NSLog(@"countryCode %@", countryCode);
        NSLog(@"Identifier %@", identifier);
        NSString *country = [[NSLocale currentLocale] displayNameForKey: NSLocaleIdentifier value: identifier];
        NSLog(@"country %@", country);
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

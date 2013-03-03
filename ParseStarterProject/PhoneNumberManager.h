//
//  PhoneNumberManager.h
//  Shredder
//
//  Created by Shredder on 09/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "CountryCodeInformation.h"

@interface PhoneNumberManager : NSObject

+(NSString *)normalisedPhoneNumberWithContactNumber:(NSString *)phoneNumber countryCode:(NSString *)countryCode;

+(CountryCodeInformation *)getCurrentCountryCodeInfo;

+(NSString *)getCurrentCountry;

+(NSArray *)getListOfAllCountryCodeInformationObjects;

+(NSString *)getCountryForCountryCode:(NSString *)countryCodeInitials;

+(NSString *)getCallingCodeForCountryCode:(NSString *)countryCode;

+(NSArray *)getListOfAllCountryCodes;

+(NSArray *)getListOfAllCountries;

+(BOOL)isViablePhoneNumber:(NSString *)number forCountryCode:(NSString *)countryCode;

@end

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

+(NSArray *)getListOfAllCountryCodeInformationObjects;

+(CountryCodeInformation *)getCurrentCountryCodeInfo;

+(NSString *)normalisedPhoneNumberWithContactNumber:(NSString *)phoneNumber countryCode:(NSString *)countryCode;

+(BOOL)isViablePhoneNumber:(NSString *)number forCountryCode:(NSString *)countryCode;

@end

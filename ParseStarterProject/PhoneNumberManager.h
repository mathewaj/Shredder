//
//  PhoneNumberManager.h
//  Shredder
//
//  Created by Shredder on 09/02/2013.
//
//

#import <Foundation/Foundation.h>

@interface PhoneNumberManager : NSObject

+(NSString *)normalisedPhoneNumberWithContactNumber:(NSString *)phoneNumber countryCode:(NSString *)countryCode;

@end

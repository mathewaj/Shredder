//
//  Contact.h
//  Shredder
//
//  Created by Shredder on 26/01/2013.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nameInitial;
@property (nonatomic, retain) NSString * parseID;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSNumber * signedUp;
@property (nonatomic, retain) NSNumber * addressBookID;

@end

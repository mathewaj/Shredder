//
//  Contact.h
//  Shredder
//
//  Created by Shredder on 23/01/2013.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Email;

// Typedef a block called ParseReturned which receives a contact and returns a BOOL
typedef void (^ParseReturned) (BOOL signedUp);

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nameInitial;
@property (nonatomic, retain) NSString * parseID;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSNumber * signedUp;
@property (nonatomic, retain) NSString * nameFirstLetter;
@property (nonatomic, retain) NSSet *emails;
@end

@interface Contact (CoreDataGeneratedAccessors)

- (void)addEmailsObject:(Email *)value;
- (void)removeEmailsObject:(Email *)value;
- (void)addEmails:(NSSet *)values;
- (void)removeEmails:(NSSet *)values;

@end

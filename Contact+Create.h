//
//  Contact+Create.h
//  ParseStarterProject
//
//  Created by Alan Mathews on 12/11/2012.
//
//

#import "Contact.h"
#import "Email.h"

// Category to help create Contact objects

@interface Contact (Create)

+(Contact *)contactWithEmail:(NSString *)email inContext:(NSManagedObjectContext *)context;

+(Contact *)contactWithName:(NSString *)name inContext:(NSManagedObjectContext *)context;

+(BOOL)checkIfContactExists:(NSString *)email inContext:(NSManagedObjectContext *)context;

-(Email *)addEmailAddress:(NSString *)address inContext:(NSManagedObjectContext *)context;

@end

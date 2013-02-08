//
//  ContactsDatabaseManager.h
//  Shredder
//
//  Created by Shredder on 08/02/2013.
//
//

#import <Foundation/Foundation.h>

@class Contact;

@interface ContactsDatabaseManager : NSObject

-(Contact *)retrieveContactwithParseID:(NSString *)parseID inManagedObjectContext:(UIManagedDocument *)document;

@end

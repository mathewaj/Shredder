//
//  ContactsDatabaseManager.m
//  Shredder
//
//  Created by Shredder on 08/02/2013.
//
//

#import "ContactsDatabaseManager.h"
#import "Contact.h"


@implementation ContactsDatabaseManager

-(Contact *)retrieveContactwithParseID:(NSString *)parseID inManagedObjectContext:(UIManagedDocument *)document{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    request.predicate = [NSPredicate predicateWithFormat:@"parseID = %@", parseID];
    NSArray *contacts = [document.managedObjectContext executeFetchRequest:request error:nil];
    Contact *contact = [contacts lastObject];
    return contact;
}



@end

//
//  Contact+Create.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 12/11/2012.
//
//

#import "Contact+Create.h"


@implementation Contact (Create)

+(Contact *)contactWithName:(NSString *)name inContext:(NSManagedObjectContext *)context
{
    Contact *contact = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    NSArray *matches = [context executeFetchRequest:request error:nil];
    
    if(!matches || [matches count]>1)
    {
        
    } else if([matches count]==0)
    {
        
        contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
        contact.name = name;
                
        
    } else {
        contact = [matches lastObject];
    }
    
    //[context save:nil];
    
    return contact;
    
}


// Method to create a contact with certain data
+(Contact *)contactWithEmail:(NSString *)email inContext:(NSManagedObjectContext *)context
{
    Contact *contact = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
    request.predicate = [NSPredicate predicateWithFormat:@"email = %@", email];
    
    NSArray *matches = [context executeFetchRequest:request error:nil];
    
    if(!matches || [matches count]>1)
    {
        
    } else if([matches count]==0)
    {

        contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
        contact.email = email;
        
    } else {
        contact = [matches lastObject];
    }
    
    [context save:nil];

    return contact;

}

+(BOOL)checkIfContactExists:(NSString *)email inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Contact"];
    request.predicate = [NSPredicate predicateWithFormat:@"email = [c]%@", email];
    
    NSArray *matches = [context executeFetchRequest:request error:nil];
    
    if(!matches || [matches count]>1)
    {
        return YES;
    } else if([matches count]==0)
    {
        
        return NO;
        
    } else {
        return YES;
    }
}

-(Email *)addEmailAddress:(NSString *)address inContext:(NSManagedObjectContext *)context
{
    Email *email = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Email"];
    request.predicate = [NSPredicate predicateWithFormat:@"address = %@", email];
    
    NSArray *matches = [context executeFetchRequest:request error:nil];
    
    if(!matches || [matches count]>1)
    {
        
    } else if([matches count]==0)
    {
        
        email = [NSEntityDescription insertNewObjectForEntityForName:@"Email" inManagedObjectContext:context];
        email.address = address;
        
    } else {
        email = [matches lastObject];
    }
    
    [context save:nil];
    
    return email;
}



@end

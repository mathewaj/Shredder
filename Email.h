//
//  Email.h
//  ParseStarterProject
//
//  Created by Alan Mathews on 16/11/2012.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface Email : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) Contact *contact;

@end

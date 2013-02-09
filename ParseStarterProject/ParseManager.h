//
//  ParseManager.h
//  Shredder
//
//  Created by Shredder on 08/02/2013.
//
//

#import <Foundation/Foundation.h>

@interface ParseManager : NSObject

@property (nonatomic, strong) UIManagedDocument *contactsDatabase;

-(void)checkIfNewContactsAreOnShredder:(NSArray *)newlyUpdatedContacts;

@end

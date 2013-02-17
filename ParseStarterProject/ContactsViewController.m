//
//  ContactsViewController.m
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import "ContactsViewController.h"
#import "Contact.h"
#import "ParseManager.h"
#import "MGBase.h"
#import "MGBox.h"
#import "MGScrollView.h"
#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"

@interface ContactsViewController ()

@end

@implementation ContactsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.contacts = [self.contactsDatabaseManager fetchContacts];
    [self presentContactsList];
}

-(void)presentContactsList{
    
    MGScrollView *scroller = [MGScrollView scrollerWithSize:self.view.bounds.size];
    [self.view addSubview:scroller];
    
    // Set Messages Section
    MGTableBoxStyled *section = MGTableBoxStyled.box;
    [scroller.boxes addObject:section];
    
    // Set Message Rows
    CGSize rowSize = (CGSize){304, 40};
    for(int i=0;i<[self.contacts count];i++){
        
        // For each contact create a table row
        Contact *contact = [self.contacts objectAtIndex:i];
        
        // Create row
        MGLineStyled *header = [MGLineStyled line];
        header.leftItems = [NSArray arrayWithObject:contact.name];
        header.leftPadding = header.rightPadding = 16;
        
        if(contact.parseID){
            
            header.rightItems = [NSArray arrayWithObject:[UIImage imageNamed:@"greenShredderStripped.png"]];
            
            header.onTap = ^{
                
                // Return with Shredder User
                [ParseManager shredderUserForContact:contact withCompletionBlock:^(BOOL success, NSError *error, NSArray *objects) {
                    
                    if(error){
                        // Handle Error
                    } else {
                        
                        // Handle Multiple Contacts
                        if([objects count] > 1){
                            // This is a problem, handle
                        } else {
                            // Shredder User has been retrieved
                            // Save contact to Shredder User
                            // Dismiss controller and fire delegate method
                            [self dismissViewControllerAnimated:YES completion:^{
                                
                                ShredderUser *user = [[ShredderUser alloc] initWithPFUser:[objects lastObject]];
                                user.contact = contact;
                                [self.delegate didSelectShredderUser:user];
                                
                            }];
                            
                        }
                    }
                    
                }];
                
                
            };
            
        } else {
            
            header.onTap = ^{
              
                [self sendInviteToNonShredderUser:contact];
                
            };
            
        }
        
       
        
        // If first object
        if(i==0){
            [section.topLines addObject:header];
            // If last object
        } else if (i==[self.contacts count]-1) {
            [section.bottomLines addObject:header];
            // If middle
        } else {
            [section.middleLines addObject:header];
        }
        
    }
    
    [scroller layoutWithSpeed:0.3 completion:nil];

}

-(void)sendInviteToNonShredderUser:(Contact *)contact{
    
    MFMessageComposeViewController *messanger = [[MFMessageComposeViewController alloc] init];
    messanger.messageComposeDelegate = self;
    NSArray *toRecipients = [NSArray arrayWithObject:contact.phoneNumber];
    [messanger setRecipients:toRecipients];
    NSString *messageBody = [NSString stringWithFormat:@"I'd like to send you a confidential message on the new private messaging app Shredder. Please download it from the App Store now!\nitms://itunes.com/apps/Shredder"];
    [messanger setBody:messageBody];
    [self presentModalViewController:messanger animated:YES];
}

#pragma mark - Message Composer Delegate Method

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    switch (result)
    {
        case MessageComposeResultCancelled: {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Cancelled"
                                                                message:@"You have cancelled the message"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
        }
            
            
            break;
        case MessageComposeResultSent:
        {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Message Sent"
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
        }
            
            break;
        default:
            NSLog(@"Message not sent.");
            break;
    }
    // Remove the mail view
    
    [self dismissModalViewControllerAnimated:YES];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

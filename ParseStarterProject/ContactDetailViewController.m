//
//  ContactDetailViewController.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 16/11/2012.
//
//

#import "ContactDetailViewController.h"
#import <Parse/Parse.h>

@interface ContactDetailViewController ()

@end

@implementation ContactDetailViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set name cell
    self.contactNameLabel.text = self.contact.name;
    
    // Set email cell
    if(self.contact.email)
    {
        self.contactEmailTextField.text = self.contact.email;
    }
    
    self.contactEmailTextField.enabled = NO;
    
    // Set invite cell
    [self setupInviteLabel];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupInviteLabel{
    
    if([self validateEmail:self.contactEmailTextField.text]) {
        
        if([self.contact.signedUp isEqualToNumber:[NSNumber numberWithBool:YES]])
        {
            [self.contactInviteLabel setText:@"Contact is on Shredder!"];
            self.contactInviteLabel.textColor = [UIColor grayColor];
            self.contactInviteCell.userInteractionEnabled = NO;
            
        } else
        {
            [self.contactInviteLabel setText:@"Invite Contact to Shredder"];
            self.contactInviteLabel.textColor = [UIColor blueColor];
            self.contactInviteCell.userInteractionEnabled = YES;
        }
        
    } else {
        
        [self.contactInviteLabel setText:@"Invite Contact to Shredder"];
        self.contactInviteLabel.textColor = [UIColor grayColor];
        self.contactInviteCell.userInteractionEnabled = YES;
    }
    
    
    
}



- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    //  return 0;
    return [emailTest evaluateWithObject:candidate];
}

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    
    
    if([sender.title isEqualToString:@"Edit"])
    {
        // Change button to Save
        [sender setTitle:@"Save"];
        
        // Enable text field
        self.contactEmailTextField.enabled = YES;
        [self.contactEmailTextField becomeFirstResponder];

        
    } else if ([sender.title isEqualToString:@"Save"])
    {
        // Check if email is valid
        if(![self validateEmail:self.contactEmailTextField.text]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"This does not appear to be a valid email address"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
            
        } else {
            
            // Save contact details
            self.contact.email = self.contactEmailTextField.text;
            [self.contactsDatabase.managedObjectContext save:nil];
            
            // Resign first responder
            [self.contactEmailTextField resignFirstResponder];
            self.contactEmailTextField.enabled = NO;
            
            // Set title to edit
            [sender setTitle:@"Edit"];
            
            // Check if contact on Shredder and update invite label accordingly
            [self checkIfContactOnShredder:self.contact onCompletion:^(BOOL signedUp){
                
                self.contact.signedUp = [NSNumber numberWithBool:signedUp];
                
                [self setupInviteLabel];
                
             }];
            
            
        }
        

    }
}

-(void)checkIfContactOnShredder:(Contact *)contact onCompletion:(ParseReturned)parseReturned
{
    // Check Parse contact for this email address
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:contact.email];
    
    // CALL TO PARSE
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            if([objects count] == 1)
            {
                PFUser *user = [objects lastObject];
                self.contact.parseID = user.objectId;
                parseReturned(YES);
                
            } else {
                parseReturned(NO);
            }
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
         

#pragma mark - Table view data source





/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
    {
        
        
    }
    
    if(indexPath.section == 2){
        
        if(![self validateEmail:self.contact.email])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"Please enter a valid email address"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        } else {
            
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
                mailer.mailComposeDelegate = self;
                [mailer setSubject:@"Join Shredder"];
                NSArray *toRecipients = [NSArray arrayWithObject:self.contact.email];
                [mailer setToRecipients:toRecipients];
                //UIImage *myImage = [UIImage imageNamed:@"mobiletuts-logo.png"];
                //NSData *imageData = UIImagePNGRepresentation(myImage);
                //[mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"mobiletutsImage"];
                NSString *emailBody = @"I'd like to send you a confidential message on Shredder.\n\nPlease download from the App Store now!";
                [mailer setMessageBody:emailBody isHTML:NO];
                [self presentModalViewController:mailer animated:YES];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                                message:@"Your device doesn't support the composer sheet"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                [alert show];
                
            }

            
        }
        
                
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setContactNameLabel:nil];
    [self setContactInviteLabel:nil];
    [self setContactInviteCell:nil];
    [self setContactEmailCell:nil];
    [self setEditButton:nil];
    [super viewDidUnload];
}
@end

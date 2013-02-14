//
//  ContactDetailViewController.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 16/11/2012.
//
//

#import "ContactDetailViewController.h"
#import <Parse/Parse.h>
#import "Blocks.h"

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
    
    /* Set phone number cell
    if(self.contact.phoneNumber){
        self.contactPhoneNumberLabel.text = self.contact.phoneNumber;
    } else {
        self.contactPhoneNumberLabel.text = @"";
    }
        
    // Set email cell
    if(self.contact.email)
    {
        self.contactEmailLabel.text = self.contact.email;
    } else {
        self.contactEmailLabel.text = @"";
    }*/
    
    // Add textfields
    [self addTextfieldToPhoneCell];
    [self addTextfieldToEmailCell];
    
    // Set invite cell
    [self setupInviteLabel];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)addTextfieldToPhoneCell{
    
    UITextField *txtField=[[UITextField alloc]initWithFrame:CGRectMake(83, 12, 200, 19)];
    txtField.autoresizingMask=UIViewAutoresizingFlexibleHeight;
    txtField.autoresizesSubviews=YES;
    txtField.font = [UIFont systemFontOfSize:15];
    txtField.enabled = NO;
    txtField.keyboardType = UIKeyboardTypeNumberPad;
    [txtField setBorderStyle:UITextBorderStyleNone];
    
    
    if(self.contact.normalisedPhoneNumber)
    {
        txtField.text = self.contact.normalisedPhoneNumber;
    } else {
        txtField.text = @"";
    }
    
    [self.contactPhoneCell.contentView addSubview:txtField];
    
    self.contactPhoneTextField = txtField;
    
}

-(void)addTextfieldToEmailCell{
    
    UITextField *txtField=[[UITextField alloc]initWithFrame:CGRectMake(83, 12, 200, 19)];
    txtField.autoresizingMask=UIViewAutoresizingFlexibleHeight;
    txtField.autoresizesSubviews=YES;
    txtField.font = [UIFont systemFontOfSize:15];
    txtField.enabled = NO;
    txtField.keyboardType = UIKeyboardTypeEmailAddress;
    [txtField setBorderStyle:UITextBorderStyleNone];
    
    
    if(self.contact.email)
    {
        txtField.text = self.contact.email;
    } else {
        txtField.text = @"";
    }
    
    [self.contactEmailCell.contentView addSubview:txtField];
    
    self.contactEmailTextField = txtField;
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupInviteLabel{
    
    if([self.contact.signedUp isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        [self.contactInviteLabel setText:@"Contact is on Shredder!"];
        self.contactInviteLabel.textColor = [UIColor grayColor];
        self.contactInviteCell.userInteractionEnabled = NO;
        
    } else if(self.contact.phoneNumber || self.contact.email){
        [self.contactInviteLabel setText:@"Invite Contact to Shredder"];
        self.contactInviteLabel.textColor = [UIColor blueColor];
        self.contactInviteCell.userInteractionEnabled = YES;
    } else {
        
        [self.contactInviteLabel setText:@"Invite Contact to Shredder"];
        self.contactInviteLabel.textColor = [UIColor grayColor];
        self.contactInviteCell.userInteractionEnabled = NO;
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
        
        // Enable text fields
        self.contactPhoneTextField.enabled = YES;
        self.contactEmailTextField.enabled = YES;
        [self.contactPhoneTextField becomeFirstResponder];
        
        
    } else if ([sender.title isEqualToString:@"Save"])
    {
        
        // Check if an email has been entered
        if(![self.contactEmailTextField.text isEqualToString:@""])
        {
            // Check email
            // Check if any entered email addresses are valid
            if(![self validateEmail:self.contactEmailTextField.text]){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                                message:@"This does not appear to be a valid email address"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                [alert show];
                
            } else {
                
                // Email is valid so save
                self.contact.email = self.contactEmailTextField.text;
                
                // Save phone number if entered
                if(![self.contactPhoneTextField.text isEqualToString:@""])
                {
                    self.contact.normalisedPhoneNumber = self.contactPhoneTextField.text;
                }
                
            }
            
        } else {
            
            // Else an email has not been entered, just attempt to save number
            if(![self.contactPhoneTextField.text isEqualToString:@""])
            {
                self.contact.phoneNumber = self.contactPhoneTextField.text;
            }
            
        }
            
        [self.contactsDatabase.managedObjectContext save:nil];
            
        // Resign first responder
        [self.contactEmailTextField resignFirstResponder];
        self.contactPhoneTextField.enabled = NO;
        self.contactEmailTextField.enabled = NO;
            
        // Set title to edit
        [sender setTitle:@"Edit"];
        
        if(self.contact.email){
            
            // Check if contact on Shredder and update invite label accordingly
            [self checkIfContactOnShredder:self.contact onCompletion:^(BOOL signedUp, NSError *error){
                
                self.contact.signedUp = [NSNumber numberWithBool:signedUp];
                
                [self setupInviteLabel];
                
            }];
        }
    }
}


-(void)checkIfContactOnShredder:(Contact *)contact onCompletion:(ParseReturned)parseReturned
{
    
    // Add UIActivityIndicator to view
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.contactInviteCell.contentView addSubview:spinner];
    [spinner setFrame:CGRectMake(self.contactInviteCell.contentView.frame.size.width/2 - spinner.frame.size.width/2, self.contactInviteCell.frame.size.height/2 - spinner.frame.size.height/2, spinner.frame.size.width, spinner.frame.size.height)];
    [spinner startAnimating];
    
    // Clear text
    self.contactInviteCell.textLabel.text = @"";
    
    // Check Parse contact for this email address
    PFQuery *query = [PFUser query];
    NSString* regexName = [NSString stringWithFormat:@"(?i)%@$", contact.email];
    
    [query whereKey:@"username" matchesRegex:regexName];

    
    // CALL TO PARSE
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            [spinner stopAnimating];
            if([objects count] == 1)
            {
                PFUser *user = [objects lastObject];
                self.contact.parseID = user.objectId;
                parseReturned(YES, error);
                
            } else {
                parseReturned(NO, error);
            }
            
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [spinner stopAnimating];
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
        
        [self sendInvite];
    
    }
}

-(void)sendInvite{
    
    // Try phone number, then email
    if (self.contact.phoneNumber && [MFMessageComposeViewController canSendText]){
        
        MFMessageComposeViewController *messanger = [[MFMessageComposeViewController alloc] init];
        messanger.messageComposeDelegate = self;
        NSArray *toRecipients = [NSArray arrayWithObject:self.contact.phoneNumber];
        [messanger setRecipients:toRecipients];
        NSString *messageBody = [NSString stringWithFormat:@"I'd like to send you a confidential message on the new private messaging app Shredder. Please download it from the App Store now!\nitms://itunes.com/apps/Shredder\n\nMy Username: %@", [PFUser currentUser].username ];
        [messanger setBody:messageBody];
        [self presentModalViewController:messanger animated:YES];
        
        
        
    } else if(self.contact.email && [MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        //[messager setSubject:@"Join Shredder"];
        NSArray *toRecipients = [NSArray arrayWithObject:self.contact.email];
        [mailer setSubject:@"Join Shredder"];
        [mailer setToRecipients:toRecipients];
        //UIImage *myImage = [UIImage imageNamed:@"mobiletuts-logo.png"];
        //NSData *imageData = UIImagePNGRepresentation(myImage);
        //[mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"mobiletutsImage"];
        NSString *messageBody = [NSString stringWithFormat:@"I'd like to send you a confidential message on the new private messaging app Shredder. \n\nPlease download it from the App Store now!\n\nitms://itunes.com/apps/Shredder\n\nMy Username: %@", [PFUser currentUser].username ];
        [mailer setMessageBody:messageBody isHTML:NO];
        [self presentModalViewController:mailer animated:YES];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Cannot send message to this contact"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
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

- (void)viewDidUnload {
    [self setContactNameLabel:nil];
    [self setContactInviteLabel:nil];
    [self setContactInviteCell:nil];
    [self setContactEmailCell:nil];
    [self setEditButton:nil];
    [self setContactPhoneNumberLabel:nil];
    [self setContactEmailLabel:nil];
    [self setContactPhoneCell:nil];
    [super viewDidUnload];
}
@end

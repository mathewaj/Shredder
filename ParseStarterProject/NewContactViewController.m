//
//  NewContactViewController.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 19/11/2012.
//
//

#import "NewContactViewController.h"

@interface NewContactViewController ()

@end

@implementation NewContactViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.inviteCellRowHeight = [NSNumber numberWithInt:0];
        self.contactInviteCell.userInteractionEnabled = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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



- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    //  return 0;
    return [emailTest evaluateWithObject:candidate];
}

- (IBAction)saveButtonPressed:(UIBarButtonItem *)sender {
    self.saveButton.enabled = NO;
    
    // Validate info and save to contact
    if(!self.contactNameTextField || [self.contactNameTextField.text isEqualToString:@""]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Please enter a name"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        self.saveButton.enabled = YES;
        
    // If not a valid email address prompt and re-enable save button
    } else if (![self validateEmail:self.contactEmailTextField.text]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"This does not appear to be a valid email address"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        self.saveButton.enabled = YES;
    
    // If contact already exists prompt and re-enable save button
    } else if ([Contact checkIfContactExists:self.contactEmailTextField.text inContext:self.contactsDatabase.managedObjectContext]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"A contact with this email address already exists"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        self.saveButton.enabled = YES;
        
    // If contact valid and does not exist, create.
    } else {
        
        Contact *contact = [Contact contactWithName:self.contactNameTextField.text inContext:self.contactsDatabase.managedObjectContext];
        contact.email = self.contactEmailTextField.text;
        self.contact = contact;
        self.contactNameCell.userInteractionEnabled = NO;
        self.contactEmailCell.userInteractionEnabled = NO;
        [self.contactsDatabase.managedObjectContext save:nil];
        [self.view endEditing:TRUE];
        [self setupInviteLabel];
        self.inviteCellRowHeight = [NSNumber numberWithInt:44];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
        }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2)
    {
        return [self.inviteCellRowHeight floatValue];
    } else {
        return 44;
    }
}


-(void)setupInviteLabel{
    
    if([self.contact.signedUp isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        [self.contactInviteLabel setText:@"Contact is on Shredder!"];
        self.contactInviteLabel.textColor = [UIColor grayColor];
        
    } else
    {
        [self.contactInviteLabel setText:@"Invite Contact to Shredder!"];
        self.contactInviteLabel.textColor = [UIColor blueColor];
        self.contactInviteCell.userInteractionEnabled = YES;
    }
    
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

    if(indexPath.section == 0)
    {
        if(!self.contactNameTextField)
        {
            self.contactNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(93, 14, 200, 20)];
            self.contactNameTextField.backgroundColor = [UIColor clearColor];
            self.contactNameTextField.font = [UIFont boldSystemFontOfSize:15];
            self.contactNameTextField.keyboardType = UIKeyboardTypeEmailAddress;
            [self.contactNameCell addSubview:self.contactNameTextField];
        }
        
        [self.contactNameTextField becomeFirstResponder];
        
    }
    
    if(indexPath.section == 1)
    {
        if(!self.contactEmailTextField)
        {
            self.contactEmailTextField = [[UITextField alloc] initWithFrame:CGRectMake(93, 14, 200, 20)];
            self.contactEmailTextField.backgroundColor = [UIColor clearColor];
            self.contactEmailTextField.font = [UIFont boldSystemFontOfSize:15];
            self.contactEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
            [self.contactEmailCell addSubview:self.contactEmailTextField];
        }
        
        [self.contactEmailTextField becomeFirstResponder];
        
    }
    
    if(indexPath.section == 2){
        
        if(![self validateEmail:self.contact.email])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"This does not appear to be a valid email address"
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
                NSArray *ccRecipients = [NSArray arrayWithObject:@"alanpearsonmathews@gmail.com"];
                [mailer setCcRecipients:ccRecipients];
                //UIImage *myImage = [UIImage imageNamed:@"mobiletuts-logo.png"];
                //NSData *imageData = UIImagePNGRepresentation(myImage);
                //[mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"mobiletutsImage"];
                NSString *emailBody = @"I'd like to send you a confidential message on the amazing new app Shredder.\n\nPlease hit reply all to this email to receive further instructions on how to download the app!";
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
    [self setContactEmailLabel:nil];
    [self setContactEmailCell:nil];
    [self setContactInviteLabel:nil];
    [self setContactInviteCell:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];
}
@end
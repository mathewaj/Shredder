//
//  NewContactViewController.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 19/11/2012.
//
//

#import "NewContactViewController.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "Blocks.h"

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
    
    self.contactInviteCell.hidden = NO;
    

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
    
    // Disable save button
    self.saveButton.enabled = NO;
    
    // Validate that a name has entered
    if(!self.contactNameTextField || [self.contactNameTextField.text isEqualToString:@""]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Please enter a name"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        self.saveButton.enabled = YES;
        
    // Validate email address
    } else if (![self validateEmail:self.contactEmailTextField.text]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"This does not appear to be a valid email address"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        self.saveButton.enabled = YES;
    
    // Validate that it is not a duplicate contact
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
        
        // Create contact
        Contact *contact = [Contact contactWithName:self.contactNameTextField.text inContext:self.contactsDatabase.managedObjectContext];
        contact.email = self.contactEmailTextField.text;
        self.contact = contact;
        self.contactNameCell.userInteractionEnabled = NO;
        self.contactEmailCell.userInteractionEnabled = NO;
        //[self.contactsDatabase.managedObjectContext save:nil];
        [self.view endEditing:TRUE];
        
        // Check if contact on Shredder and update invite label accordingly
        [self checkIfContactOnShredder:self.contact onCompletion:^(BOOL signedUp, NSError *error){
            
            self.contact.signedUp = [NSNumber numberWithBool:signedUp];
            
            [self setupInviteLabel];
            
        }];
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2)
    {
        return [self.inviteCellRowHeight floatValue];
    } else {
        return 43;
    }
}


-(void)setupInviteLabel{
    
    self.inviteCellRowHeight = [NSNumber numberWithInt:44];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    if([self.contact.signedUp isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        [self.contactInviteLabel setText:@"Contact is on Shredder!"];
        self.contactInviteLabel.textColor = [UIColor grayColor];
        [self.tableView reloadData];
        
    } else
    {
        [self.contactInviteLabel setText:@"Invite Contact to Shredder!"];
        self.contactInviteLabel.textColor = [UIColor blueColor];
        self.contactInviteCell.userInteractionEnabled = YES;
        [self.tableView reloadData];
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
    
    // Name Field First Responder
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
    
    // Email Field First Responder
    if(indexPath.section == 1)
    {
        if(!self.contactEmailTextField)
        {
            self.contactEmailTextField = [[UITextField alloc] initWithFrame:CGRectMake(93, 14, 200, 20)];
            self.contactEmailTextField.backgroundColor = [UIColor clearColor];
            self.contactEmailTextField.font = [UIFont boldSystemFontOfSize:15];
            self.contactEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
            self.contactEmailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            [self.contactEmailCell addSubview:self.contactEmailTextField];
        }
        
        [self.contactEmailTextField becomeFirstResponder];
        
    }
    
    // Validation
    // Set up invite
    if(indexPath.section == 2){
        
        // Is email entered valid?
        if(![self validateEmail:self.contact.email])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"This does not appear to be a valid email address"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        } else {
            [self sendInvite];
        }
    }
}

-(void)checkIfContactOnShredder:(Contact *)contact onCompletion:(ParseReturned)parseReturned
{
    /*Add UIActivityIndicator to view
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.contactInviteCell.contentView addSubview:spinner];
    [spinner setFrame:CGRectMake(self.contactInviteCell.contentView.frame.size.width/2 - spinner.frame.size.width/2, self.contactInviteCell.frame.size.height/2 - spinner.frame.size.height/2, spinner.frame.size.width, spinner.frame.size.height)];
    
    
    
    [spinner startAnimating];*/
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.labelText = @"Loading...";
    
    // Check Parse contact for this email address
    // Make it a lowercase query
    PFQuery *query = [PFUser query];
    NSString* regexName = [NSString stringWithFormat:@"(?i)%@$", contact.email];
    [query whereKey:@"username" matchesRegex:regexName];
    
    // Query Parse
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if([objects count] == 1)
            {
                // Confirmed Shredder user
                PFUser *user = [objects lastObject];
                self.contact.parseID = user.objectId;
                parseReturned(YES, error);
                
            } else {
                // Email not found
                parseReturned(NO, error);
            }
            
            
        } else {
            
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
        }
    }];
}

-(void)sendInvite{
    
    if(self.contact.email && [MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        NSArray *toRecipients = [NSArray arrayWithObject:self.contact.email];
        [mailer setSubject:@"Join Shredder"];
        [mailer setToRecipients:toRecipients];
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
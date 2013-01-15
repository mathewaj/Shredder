//
//  ComposeMessageViewController.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 30/10/2012.
//
//

#import "ComposeMessageViewController.h"
#import <AddressBook/AddressBook.h>
#import "UIImage+ResizeAdditions.h"
#import "MBProgressHUD.h"


@implementation ComposeMessageViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    
    }
    
    
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.recipientLabel.text = self.recipient.name;
    
    // Set BOOL for sending messages to NO
    self.sendingInProcess = [NSNumber numberWithBool:NO];
    
    // Put Done button on keyboard
    UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.messageTextView action:@selector(resignFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    [toolbar setItems:[NSArray arrayWithObjects:extraSpace, doneButton, nil]];
    
    self.messageTextView.inputAccessoryView = toolbar;
    
    [self.messageTextView becomeFirstResponder];
    
}

//Tells the delegate that the user picked a still image or movie.
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Set image to returned image
    self.attachedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CGFloat squareEdge = 30;
    
    // Create a thumbnail and add a corner radius
    self.attachedImageThumbnailView.frame = CGRectMake(self.attachedImageThumbnailView.frame.origin.x-((squareEdge-self.attachedImageThumbnailView.frame.size.width)/2), self.attachedImageThumbnailView.frame.origin.y-((squareEdge-self.attachedImageThumbnailView.frame.size.height)/2), squareEdge, squareEdge);
    
    self.attachedImageThumbnailView.image = [self.attachedImage thumbnailImage:squareEdge
                                    transparentBorder:0.0f
                                         cornerRadius:5.0f
                                 interpolationQuality:kCGInterpolationDefault];
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

//Tells the delegate that the user cancelled the pick operation.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.attachedImageThumbnailView.image = [UIImage imageNamed:@"PaperClip.png"];
    self.attachedImage = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Send button triggers
// 1. A parse query to retrieve the user from the contact email
// 2. When success block returns:
// 2.1 Disable send button
// 2.2 Animate progress HUD
// 2.3 Create a message object with relevant info
// 2.4 Create a PFFile of any attachments
// 2.5 Parse call to save object to messages table
// 2.5.1 When success blcok returns
// 2.5.2 Send push notification to user
// 2.5.3 Dismiss navigation controller

- (IBAction)sendButtonPressed:(UITapGestureRecognizer *)sender {
    
    sender.enabled = NO;
    CGRect newMessageFrame = self.messageView.frame;
    newMessageFrame.origin.y -= 1000;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Identify PFUser
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" equalTo:self.recipient.email];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        // User not found
        if([objects count] != 1)
        {
            
        } else {
            
            
            
        }
        
        self.recipientUser = (PFUser *)[objects lastObject];
        
        // Disable send button
        self.sendButton.enabled = NO;
        
        PFObject *message = [PFObject objectWithClassName:@"Message"];
        [message setObject:self.messageTextView.text forKey:@"body"];
        [message setObject:[PFUser currentUser] forKey:@"sender"];
        [message setObject:self.recipientUser forKey:@"recipient"];
        [message setObject:[NSNumber numberWithBool:NO] forKey:@"report"];
        
        // Handle attached image
        if(self.attachedImage)
        {
            NSData *imageData = UIImageJPEGRepresentation(self.attachedImage, 0.8f);
            PFFile *file = [PFFile fileWithData:imageData];
            [message setObject:file forKey:@"attachedImage"];
        }
        
        PFACL *messageACL = [PFACL ACL];
        [messageACL setReadAccess:YES forUser:[PFUser currentUser]];
        [messageACL setWriteAccess:YES forUser:[PFUser currentUser]];
        [messageACL setReadAccess:YES forUser:self.recipientUser];
        [messageACL setWriteAccess:YES forUser:self.recipientUser];
        
        message.ACL = messageACL;
        
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            
            if(succeeded){
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            
                [UIView animateWithDuration:1.5
                                 animations:^{
                                     
                                     self.messageView.frame =newMessageFrame;
                                     
                                 }
                                 completion:^(BOOL success){
                                     
                                     [self dismissViewControllerAnimated:NO completion:nil];
                                     
                                 }];
                
                // Create our installation query
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"owner" equalTo:self.recipientUser];
                
                // Send push notification to query
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery];
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"You have received a message on Shredder", @"alert",
                                      @"Increment", @"badge",
                                      @"chainsaw-02.wav", @"sound",
                                      nil];
                [push setData:data];
                [push sendPushInBackground];
            }
        }];
    }];
}
- (IBAction)attachmentIconTapped:(id)sender {
    
    //Check Camera available or not
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePickController=[[UIImagePickerController alloc] init];
        
        imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickController.delegate = self;
        //This method inherit from UIView,show imagePicker with animation
        [self presentModalViewController:imagePickController animated:YES];
    }
    
    
}

- (IBAction)cancelButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:nil];
}



- (void)viewDidUnload {

    [self setMessageTextView:nil];
    [self setRecipientLabel:nil];
    [self setAttachedImageThumbnailView:nil];
    [self setSendButton:nil];
    [self setMessageView:nil];
    [super viewDidUnload];
}
@end

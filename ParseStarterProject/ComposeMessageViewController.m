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

@interface ComposeMessageViewController ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier messagePostBackgroundTaskId;

@end


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
    
    // Set message background to transparent
    self.messageView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    
    // Identify the PFUser to receive the message
    [self identifyMessageReceiver];
    
    // Set the recipient name on the label
    self.recipientLabel.text = self.recipient.name;
    
    // Set BOOL for sending messages to NO
    self.sendingInProcess = [NSNumber numberWithBool:NO];
    
    // Set up keyboard
    UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.messageTextView action:@selector(resignFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolbar setItems:[NSArray arrayWithObjects:extraSpace, doneButton, nil]];
    self.messageTextView.inputAccessoryView = toolbar;
    [self.messageTextView becomeFirstResponder];
    
    // Add listener so text field can be adjusted based on keyboard showing or not
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
}

-(void)identifyMessageReceiver{
    
    // Identify the PFUser to receive the message
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" equalTo:self.recipient.email];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        // User not found
        if([objects count] != 1)
        {
            
        } else {
            
            self.recipientUser = (PFUser *)[objects lastObject];
            
        }
    }];
}

//Tells the delegate that the user picked a still image or movie.
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Set image to returned image
    self.attachedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self shouldUploadImage:self.attachedImage];
    
    CGFloat squareEdge = 30;
    
    // Create a thumbnail and add a corner radius
    self.attachedImageThumbnailView.frame = CGRectMake(self.attachedImageThumbnailView.frame.origin.x-((squareEdge-self.attachedImageThumbnailView.frame.size.width)/2), self.attachedImageThumbnailView.frame.origin.y-((squareEdge-self.attachedImageThumbnailView.frame.size.height)/2), squareEdge, squareEdge);
    
    self.attachedImageThumbnailView.image = [self.attachedImage thumbnailImage:squareEdge
                                    transparentBorder:0.0f
                                         cornerRadius:5.0f
                                 interpolationQuality:kCGInterpolationDefault];
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    // Resize the image to be square (what is shown in the preview)
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                          bounds:CGSizeMake(560.0f, 560.0f)
                                            interpolationQuality:kCGInterpolationHigh];
    // Create a thumbnail and add a corner radius for use in table views
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f
                                    transparentBorder:0.0f
                                         cornerRadius:10.0f
                                 interpolationQuality:kCGInterpolationDefault];
    
    // Get an NSData representation of our images. We use JPEG for the larger image
    // for better compression and PNG for the thumbnail to keep the corner radius transparency
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 0.8f);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    // Create the PFFiles and store them in properties since we'll need them later
    self.photoFile = [PFFile fileWithData:imageData];
    //self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    NSLog(@"Requested background expiration task with id %d for Anypic photo upload", self.fileUploadBackgroundTaskId);
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
        } else {
            NSLog(@"Photo failed to upload");
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    return YES;
    
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
        
    // Identify PFUser if not already identified
    if(!self.recipientUser){
        
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"username" equalTo:self.recipient.email];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            // User not found
            if([objects count] != 1)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"This contact is no longer available on Shredder" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
            } else {
                [self sendMessage];
            }
            
        }];
        
    } else {
        [self sendMessage];
    }
    
}



-(void)sendMessage{
    
    CGRect newMessageFrame = self.messageView.frame;
    newMessageFrame.origin.y -= 1000;
    
    [UIView animateWithDuration:1.5
                     animations:^{
                         
                         self.messageView.frame = newMessageFrame;
                         
                     }
                     completion:^(BOOL success){
                         
                         [self dismissViewControllerAnimated:NO completion:nil];
                         
                     }];    
    
    PFObject *message = [PFObject objectWithClassName:@"Message"];
    [message setObject:self.messageTextView.text forKey:@"body"];
    [message setObject:[PFUser currentUser] forKey:@"sender"];
    [message setObject:self.recipientUser forKey:@"recipient"];
    [message setObject:[NSNumber numberWithBool:NO] forKey:@"report"];
    
    // Handle attached image
    if(self.photoFile)
    {
        [message setObject:self.photoFile forKey:@"attachedImage"];
    }
    
    PFACL *messageACL = [PFACL ACL];
    [messageACL setReadAccess:YES forUser:[PFUser currentUser]];
    [messageACL setWriteAccess:YES forUser:[PFUser currentUser]];
    [messageACL setReadAccess:YES forUser:self.recipientUser];
    [messageACL setWriteAccess:YES forUser:self.recipientUser];
    
    message.ACL = messageACL;
    
    // Request a background execution task to allow us to finish uploading
    // the message even if the app is sent to the background
    self.messagePostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.messagePostBackgroundTaskId];
    }];
    
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        if(succeeded){
            
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
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your message did not send. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:self.messagePostBackgroundTaskId];
    }];
    
    
    
}
- (IBAction)attachmentIconTapped:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Choose An Existing Photo", @"Take A Photo", nil];
    sheet.actionSheetStyle = UIActionSheetStyleDefault;
    [sheet showInView:self.view];
    
    /*
    // Check Camera available or not
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePickController=[[UIImagePickerController alloc] init];
        
        imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickController.delegate = self;
        //This method inherit from UIView,show imagePicker with animation
        [self presentModalViewController:imagePickController animated:YES];
    }*/
    
    
}

- (IBAction)cancelButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark UIImagePickerController
- (IBAction)ImagePicker {
    

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController *imagePickController=[[UIImagePickerController alloc] init];
            
            imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickController.delegate = self;
            //This method inherit from UIView,show imagePicker with animation
            [self presentModalViewController:imagePickController animated:YES];
        } else {
            
        }
        /*
        //Okay the UIImagePickerControllerSourceTypeSavedPhotosAlbum displays the
        NSLog(@"Album");
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentModalViewController:picker animated:YES];*/

        
    } else if (buttonIndex == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            NSLog(@"Camera");
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentModalViewController:picker animated:YES];
        }
        

    }
}

- (void)keyboardDidShow:(NSNotification*)notification {
    
    CGFloat ratio = 3.0/2.0;
    
    CGRect newFrame = CGRectMake(self.messageTextView.frame.origin.x, self.messageTextView.frame.origin.y, self.messageTextView.frame.size.width, self.messageTextView.frame.size.height / ratio);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.messageTextView.frame = newFrame;
    }];
    
}

- (void)keyboardDidHide:(NSNotification*)notification {
    
    CGFloat ratio = 3.0/2.0;
    
    CGRect newFrame = CGRectMake(self.messageTextView.frame.origin.x, self.messageTextView.frame.origin.y, self.messageTextView.frame.size.width, self.messageTextView.frame.size.height * ratio);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.messageTextView.frame = newFrame;
    }];
    
    
    
}



- (void)viewDidUnload {

    [self setMessageTextView:nil];
    [self setRecipientLabel:nil];
    [self setAttachedImageThumbnailView:nil];
    [self setMessageView:nil];
    [super viewDidUnload];
}
@end

//
//  MessageViewController.m
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import "MessageViewController.h"
#import "MGLineStyled.h"
#import "UIImage+ResizeAdditions.h"
#import "ContactsViewControllerII.h"
#import "AddressBookHelper.h"

@interface MessageViewController ()

@end

@implementation MessageViewController

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    // Set up scroll view
    self.scrollView = [MGScrollView scrollerWithSize:self.view.bounds.size];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scrollView];
    self.scrollView.keepFirstResponderAboveKeyboard = YES;
    
    // Set up message container view
    self.containerView = [MGBox boxWithSize:self.view.bounds.size];
    self.containerView.backgroundColor = [UIColor blackColor];
    self.containerView.backgroundColor = [UIColor clearColor];
    [self.scrollView.boxes addObject:self.containerView];
    
    // Set flag
    self.firstView = YES;
    
    // Set background
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:iPhone568ImageNamed(@"BackgroundBubbles.png")]];
    
    // Set up message view based on message mode
    if(self.isComposeMode){
        
        // Handled in view did appear
        
    } else {
        
        self.messageView = [self setUpShredMessageView];
        [self showMessageView];
    }
    
    // Add notification to dismiss oneself if app re-activates
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];

    if(self.isComposeMode && !self.message){
        self.message = [ParseManager createNewMessage];
    }
    
    if(self.isComposeMode && !self.contact && self.firstView){
        [self requestContact];
    }
    
    self.firstView = NO;
  
}


-(void)requestContact{
    
    [self performSegueWithIdentifier:@"SelectContact" sender:self];
    
}

-(void)showMessageView{
    
    [self.containerView.boxes removeAllObjects];
    [self.containerView.boxes addObject:self.messageView];
    [self.scrollView layoutWithSpeed:0.3 completion:nil];
    
}

-(MessageView *)setUpComposeMessageView{
        
    MessageView *messageView = [[MessageView alloc] initWithFrame:CGRectMake(0, 0, 300, 400) withEmptyMessage:self.message forRecipient:self.contact andDelegate:self];
    
    return messageView;
}

// DEPRECATE BELOW
-(MessageView *)setUpComposeMessageViewForRecipient:(PFUser *)recipient{
        
    //self.message = [ParseManager createNewMessage];
    
    MessageView *messageView = [[MessageView alloc] initWithFrame:CGRectMake(0, 0, 300, 400) withEmptyMessage:self.message forRecipient:self.contact andDelegate:self];
    
    return messageView;
}

-(MessageView *)setUpShredMessageView{
    
    // In shred mode, a message permission has been set    
    MessageView *messageView = [[MessageView alloc] initWithFrame:CGRectZero withPopulatedMessagePermission:self.messagePermission andDelegate:self];
    messageView.delegate = self;
    return messageView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Controls

-(void)cancelButtonPressed:(MessageView *)sender{
    
    [self dismissModalViewControllerAnimated:YES];
    
}
-(void)sendButtonPressed:(PFObject *)messageToBeSent{
    
    [TestFlight passCheckpoint:@"Send Button Pressed"];
    
    if(!self.isSendButtonPressed){
        
        // Pop view controller
        [self dismissModalViewControllerAnimated:YES];
        
        // Attach any images
        if(self.images){
            
            self.message = [ParseManager attachImages:self.images toMessage:self.message];
        }
        
        // Create message permissions
        PFObject *permission = [ParseManager createMessagePermissionForMessage:messageToBeSent andShredderUserRecipient:self.contact];
        
        // Check message is intact and send
        if(permission && [permission objectForKey:@"message"]){
            
            [ParseManager sendMessage:permission withCompletionBlock:^(BOOL success, NSError *error) {
                if(success){
                    [ParseManager sendNewMessageNotificationTo:[permission objectForKey:@"recipient"]];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Message not sent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Message not sent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

-(void)shredButtonPressed:(MessageView *)sender{
    
    [TestFlight passCheckpoint:@"Shred Button Pressed"];
    
    // Shred Message
    [self shredMessage:sender withCompletionBlock:^{
        
        // Pop View Controller
        
        [self performSelector:@selector(dismissController) withObject:nil afterDelay:2.0];
    }];
    
}

-(void)dismissController{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)replyButtonPressed:(MessageView *)sender{
    
    [TestFlight passCheckpoint:@"Reply Button Pressed"];
    
    // Shred Message
    [self shredMessage:sender withCompletionBlock:^{
        
        // Will now be compose mode
        self.composeMode = YES;
        
        self.message = [ParseManager createNewMessage];
        
        // Reset container view location above window
        CGRect initialFrame = self.containerView.frame;
        CGRect newFrame = initialFrame;
        newFrame.origin.y += 600;
        initialFrame.origin.y += 1200;
        self.containerView.frame = initialFrame;
        
        // Create new blank message and add to view
        self.contact = self.messageView.contactee;
        self.messageView = [self setUpComposeMessageViewForRecipient:self.contact];
        [self.containerView.boxes addObject:self.messageView];
        [self.containerView layoutWithSpeed:1.5 completion:^{
            
            // Animate into view
            [UIView animateWithDuration:0.5
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 
                                 self.containerView.frame = newFrame;
                                 
                                 
                             } completion:^(BOOL finished) {
                                 
                                 //[self.shreddingEffectView.hidden = YES;// removeFromSuperview];
                                 
                             }];
            
            //[self.containerView.boxes addObject:self.messageView];
            //[self.containerView layoutWithSpeed:0.3 completion:nil];
            
            
        }];
     
    }];
        
}

-(void)shredMessage:(MessageView *)messageView withCompletionBlock:(void (^)(void))completionBlock{
    
    
    // Remove current Message View
    CGRect oldFrame = self.containerView.frame;
    CGRect newFrame = oldFrame;
    newFrame.origin.y -= 600;
    
    // Play sound and add graphic
    SystemSoundID chainsawId;
    NSString *chainsaw = [[NSBundle mainBundle]
                          pathForResource:@"chainsaw-02" ofType:@"wav"];
    NSURL *chainsawURL = [NSURL fileURLWithPath:chainsaw];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)chainsawURL, &chainsawId);
    AudioServicesPlaySystemSound(chainsawId);
    

    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.containerView.frame = newFrame;
                         
        
    } completion:^(BOOL finished) {
        
        // Shredding Animation
        [self showShreddingMessageAnimationWithCompletionBlock:completionBlock];
        [self.containerView.boxes removeObject:self.messageView];
        [self.containerView.boxes removeAllObjects];
    }];
    
    // Delete Message
    [ParseManager shredMessage:self.messagePermission withCompletionBlock:^(BOOL success, NSError *error) {
        
        if(!success){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning: Network Error" message:@"Message deletion failed. Please reopen and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
        }        
    }];
    
}

-(void)showShreddingMessageAnimationWithCompletionBlock:(void (^)(void))completionBlock{
    
    //self.shreddingEffectView = [[ShreddingEffectView alloc] initWithFrame:[self retrieveScreenDimensions:nil]];
    [self.view addSubview:self.shreddingEffectView];
    [self.shreddingEffectView decayOverTime:1];
    
    self.shreddingEffectView.confettiEmitter.birthRate = 50;
    self.shreddingEffectView.alpha = 1;
    [self.shreddingEffectView decayOverTime:1];
    
    [UIView animateWithDuration:2 animations:^{
        
        //[self performSelector:@selector(dismissController) withObject:nil afterDelay:3.0];
    } completion:^(BOOL finished) {
        completionBlock();
    }];
    
    /* If attachment -> confetti multi-coloured
    if([self.message objectForKey:@"attachedImage"])
    {
        self.shreddingEffectView.confettiColour.birthRate = 20;
        
    }*/
    
    
    
}

- (void)attachmentIconPressed:(MessageView *)sender {
    
    [TestFlight passCheckpoint:@"Attached Image"];
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Choose An Existing Photo", @"Take A Photo", nil];
    self.actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [self.actionSheet showInView:self.view];
    
}

-(CGRect)retrieveScreenDimensions:(MessageView *)sender
{
    return [[UIScreen mainScreen] bounds];
    //return self.view.bounds;
}

-(NSString *)getNameForUser:(PFUser *)user{
    
    NSString *name = [self.contactsDatabaseManager getNameForUser:user];
    return name;
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController *imagePickController=[[UIImagePickerController alloc] init];
            
            imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickController.delegate = self;
            [self presentModalViewController:imagePickController animated:YES];
        } else {
            
        }
        
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

//Tells the delegate that the user picked a still image or movie.
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Retrieve image
    UIImage *returnedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Update message view
    [self.messageView updateAttachmentThumbnailView:(UIImage *)returnedImage];
    
    [self shouldUploadImage:returnedImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//Tells the delegate that the user cancelled the pick operation.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Update message view
    [self.messageView updateAttachmentThumbnailView:[UIImage imageNamed:@"PaperClip.png"]];
    
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
    self.images = [[NSMutableArray alloc] init];
    [self.images insertObject:[PFFile fileWithData:imageData] atIndex:0];
    [self.images insertObject:[PFFile fileWithData:thumbnailImageData] atIndex:1];
    [ParseManager startUploadingImages:self.images];

    return YES;
    
}

#pragma mark-
#pragma mark Segue Control

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"SelectContact"]){
        
        ContactsViewControllerII *vc = (ContactsViewControllerII *)segue.destinationViewController;
        vc.contactsDatabaseManager = self.contactsDatabaseManager;
        vc.delegate = self;
        
    }
    
}

#pragma mark-
#pragma mark Contact Controller Delegate

-(void)didSelectShredderContact:(PFUser *)shredderUser{
    
    // Create new message and message view for Shredder contact
    self.contact = shredderUser;
    self.messageView = [self setUpComposeMessageViewForRecipient:shredderUser];
    [self showMessageView];
    
}


-(void)didCancelSelectingContact{
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Add New Contact

-(void)unknownContactSelected:(MessageView *)messageView{

    ABUnknownPersonViewController *view = [[ABUnknownPersonViewController alloc] init];
    
    view.unknownPersonViewDelegate = self;

    ABRecordRef displayedPerson = [AddressBookHelper createAddressBookRecordWithPhoneNumber:messageView.contactee.username];
    view.displayedPerson = displayedPerson;
    view.allowsAddingToAddressBook = YES;
    view.allowsActions = YES;
    
    UINavigationController *newNavigationController = [[UINavigationController alloc]
                                                       initWithRootViewController:view];
    [self presentModalViewController:newNavigationController
                            animated:YES];
    
    
}

-(void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownCardViewController didResolveToPerson:(ABRecordRef)person{
    
    [self.contactsDatabaseManager syncAddressBookContacts];
    
    [[unknownCardViewController presentingViewController] dismissViewControllerAnimated:YES completion:^{
        
        self.messageView = [self setUpShredMessageView];
        [self showMessageView];
        
    }];
    
}

#pragma mark-
#pragma mark App Backgrounding

-(void)appWillResignActive{
    
    // Remove action sheet from view
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:NO];
    
    if(!self.isComposeMode){
        // Consider this the same as shredding message
        [self shredMessage:self.messageView withCompletionBlock:^{
            
            // Pop View Controller
            [self dismissModalViewControllerAnimated:YES];
            
        }];
    }
    
    
}


- (void)viewDidUnload {
    [self setShreddingEffectView:nil];
    [super viewDidUnload];
}
@end

//
//  MessageViewController.m
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import "MessageViewController.h"
#import "ParseManager.h"
#import "MGLineStyled.h"
#import "UIImage+ResizeAdditions.h"
#import "ContactsViewControllerII.h"

@interface MessageViewController ()

@end

@implementation MessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    // Set up container view
    self.containerView = [MGBox boxWithSize:self.view.bounds.size];
    self.containerView.backgroundColor = [UIColor blackColor];
    self.containerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.containerView];
    
    // Set background
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:iPhone568ImageNamed(@"background.png")]];
    
    // Set up message view based on message mode
    if(self.isComposeMode){
        self.messageView = [self setUpComposeMessageView];
    } else {
        self.messageView = [self setUpShredMessageView];
    }
    
    self.contact = self.messageView.contactee;
    
    [self.containerView.boxes addObject:self.messageView];
    [self.containerView layoutWithSpeed:0.3 completion:nil];
}

-(MessageView *)setUpComposeMessageView{
    
    
    
    // In compose mode, a blank message must be created to which permissions may be added
    self.message = [[Message alloc] initNewMessageWithShredderUserReceiver:self.contact];
    
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
    
    // Show contacts view
    [self performSegueWithIdentifier:@"SelectContact" sender:self];
    //[self dismissModalViewControllerAnimated:YES];
    
}
-(void)sendButtonPressed:(Message *)messageToBeSent{
    
    if(!self.isSendButtonPressed){
        
        // Animate sending of message - TBC
        
        
        // Pop view controller
        [self dismissModalViewControllerAnimated:YES];
        
        // Attach any images
        if(self.images){
            [messageToBeSent attachImages:self.images];
        }
        
        // Create message permissions
        MessagePermission *permission = [[MessagePermission alloc] initNewMessagePermissionWithShredderUserReceiver:self.contact];
        
        [permission.messagePermission setObject:messageToBeSent.message forKey:@"message"];
        
        // Create Message Permission from message info
        [ParseManager sendMessage:permission withCompletionBlock:^(BOOL success, NSError *error) {
            // Handle Error - TBC
        }];
        
        /*[ParseManager sendMessage:sender.message withCompletionBlock:^(BOOL success, NSError *error) {
         // Message Sent
         }];*/
        
    }
    
    
    
}
-(void)shredButtonPressed:(MessageView *)sender{
    
    // Shred Message
    [self shredMessage:sender withCompletionBlock:^{
        
        // Pop View Controller
        [self dismissModalViewControllerAnimated:YES];
    }];
    
    
    
}

-(void)replyButtonPressed:(MessageView *)sender{
    
    // Shred Message
    [self shredMessage:sender withCompletionBlock:^{
        
        // Reset container view location above window
        CGRect initialFrame = self.containerView.frame;
        CGRect newFrame = initialFrame;
        newFrame.origin.y += 600;
        initialFrame.origin.y += 1200;
        self.containerView.frame = initialFrame;
        
        // Create new blank message and add to view
        self.contact = self.messageView.contactee;
        self.messageView = [self setUpComposeMessageView];
        [self.containerView.boxes addObject:self.messageView];
        [self.containerView layoutWithSpeed:2 completion:^{
            
            // Animate into view
            [UIView animateWithDuration:0.5
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 
                                 self.containerView.frame = newFrame;
                                 
                                 
                             } completion:^(BOOL finished) {
                                 
                                 [self.shreddingEffectView removeFromSuperview];
                                 
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
        
        // Shredding Animation - TBC
        [self showShreddingMessageAnimationWithCompletionBlock:completionBlock];
        [self.containerView.boxes removeObject:self.messageView];
        [self.containerView.boxes removeAllObjects];
        completionBlock();

    }];
    
    
    
    
    
    // Delete Message
    /*[ParseManager shredMessage:messageView.messagePermission withCompletionBlock:^(BOOL success, NSError *error) {
        // Message Shredder
    }];*/
    
}

-(void)showShreddingMessageAnimationWithCompletionBlock:(void (^)(void))completionBlock{
    
    self.shreddingEffectView = [[ShreddingEffectView alloc] initWithFrame:[self retrieveScreenDimensions:nil]];
    [self.view addSubview:self.shreddingEffectView];
    
    self.shreddingEffectView.confettiEmitter.birthRate = 20;
    
    /* If attachment -> confetti multi-coloured
    if([self.message objectForKey:@"attachedImage"])
    {
        self.shreddingEffectView.confettiColour.birthRate = 20;
        
    }*/
    
    [self.shreddingEffectView decayOverTime:1];
    
}

- (void)attachmentIconPressed:(MessageView *)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Choose An Existing Photo", @"Take A Photo", nil];
    sheet.actionSheetStyle = UIActionSheetStyleDefault;
    [sheet showInView:self.view];
    
}

-(CGRect)retrieveScreenDimensions:(MessageView *)sender
{
    return [[UIScreen mainScreen] bounds];
    //return self.view.bounds;
}

-(void)showAttachmentView:(UIImageView *)attachmentView withBackgroundView:(UIImageView *)backgroundView{
    
    // Retrieve screen dimensions from delegate
    CGRect screenDimensions = [[UIScreen mainScreen] bounds];
    CGPoint screenCentre = CGPointMake(screenDimensions.origin.x + (screenDimensions.size.width / 2), screenDimensions.origin.y + (screenDimensions.size.height / 2));    
    
    // Set frame of attachment view
    // Prepare Image View
    attachmentView.alpha = 1;
    attachmentView.frame = CGRectMake(screenCentre.x, screenCentre.y, 0, 0);
    
    // Prepare obfuscation view
    backgroundView = [[UIImageView alloc] initWithFrame:screenDimensions];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0;
    
    
    // Add views to main view
    [self.view addSubview:backgroundView];
    [self.view addSubview:attachmentView];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         
                         attachmentView.frame = screenDimensions;
                         backgroundView.alpha = 1;
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    
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
        
    }
    
}



@end

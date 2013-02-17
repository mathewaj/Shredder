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
    
    // Hide back button
    
    self.scrollView = [MGScrollView scrollerWithSize:self.view.bounds.size];
    self.scrollView.keepFirstResponderAboveKeyboard = NO;
    self.scrollView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scrollView];
    
    if(self.isComposeMode){
        self.messageView = [self setUpComposeMessageView];
    } else {
        self.messageView = [self setUpShredMessageView];
    }
    
    self.contact = self.messageView.contactee;
    
    [self.scrollView.boxes addObject:self.messageView];
    [self.scrollView layoutWithSpeed:0.3 completion:nil];
    [self.scrollView scrollToView:self.messageView withMargin:8];
}

-(MessageView *)setUpComposeMessageView{
    
    // In compose mode, a blank message must be created to which permissions may be added
    self.message = [[Message alloc] initNewMessageWithShredderUserReceiver:self.contact];
    
    
    MessageView *messageView = [[MessageView alloc] initWithFrame:CGRectZero withEmptyMessage:self.message];
    messageView.delegate = self;
    return messageView;
}

-(MessageView *)setUpShredMessageView{
    
    // In shred mode, a message permission has been set    
    MessageView *messageView = [[MessageView alloc] initWithFrame:CGRectZero withPopulatedMessagePermission:self.messagePermission];
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
-(void)sendButtonPressed:(Message *)messageToBeSent{
    
    if(!self.isSendButtonPressed){
        
        // Animate sending of message - TBC
        
        // Pop view controller
        [self dismissModalViewControllerAnimated:YES];
        
        // Attach any images
        if(self.images){
            [messageToBeSent attachImages:self.images];
        }
        
        // Create Message Permission from message info
        [ParseManager sendMessage:messageToBeSent withCompletionBlock:^(BOOL success, NSError *error) {
            // Handle Error - TBC
        }];
        
        /*[ParseManager sendMessage:sender.message withCompletionBlock:^(BOOL success, NSError *error) {
         // Message Sent
         }];*/
        
    }
    
    
    
}
-(void)shredButtonPressed:(MessageView *)sender{
    
    // Animate shredding of message - TBC
    
    // Pop View Controller
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
    
    [ParseManager shredMessage:sender.message withCompletionBlock:^(BOOL success, NSError *error) {
        // Message Shredder
    }];
    
}
-(void)replyButtonPressed:(MessageView *)sender{
    
    // Shred Message
    [ParseManager shredMessage:sender.message withCompletionBlock:^(BOOL success, NSError *error) {
        // Message Shredder
    }];
    
    // Remove current Message View
    [self.scrollView.boxes removeObject:self.messageView];
    [self.scrollView layoutWithSpeed:0.3 completion:nil];
    
    // Create new blank message for user
    self.messageView = [self setUpComposeMessageView];
    
    // Present blank message view
    [self.scrollView.boxes addObject:self.messageView];
    [self.scrollView layoutWithSpeed:0.3 completion:nil];
    [self.scrollView scrollToView:self.messageView withMargin:8];
    
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
    return self.view.bounds;
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



@end

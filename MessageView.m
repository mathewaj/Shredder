//
//  MessageView.m
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import "MessageView.h"
#import "MGBase.h"
#import "MGBox.h"
#import "MGScrollView.h"
#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"
#import "MGLine.h"
#import "UIImage+ResizeAdditions.h"

@implementation MessageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

#pragma mark - Custom Initialisers

- (id)initWithFrame:(CGRect)frame withEmptyMessage:(PFObject *)message forRecipient:(PFUser *) recipient andDelegate:(id <MessageViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.message = message;
        self.contactee = recipient;
        self.delegate = delegate;
        self.topMargin = 50;
        [self setUpForComposeMessage];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withPopulatedMessagePermission:(PFObject *)messagePermission andDelegate:(id <MessageViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.messagePermission = messagePermission;
        self.message = [messagePermission objectForKey:@"message"];
        self.delegate = delegate;
        self.topMargin = 30;
        self.contactee = [messagePermission objectForKey:@"sender"];
        [self setUpForShredMessage];
    }
    return self;
}

#pragma mark - Prepare MessageView

-(void)setUpForComposeMessage{
    
    // a default row size
    CGSize rowSize = (CGSize){304, 40};
    
    // Header Row contains Name, Attachment Button
    self.attachmentThumbnailView = [self getAttachmentIcon];
    NSString *recipientName = [NSString stringWithFormat:@"**%@**|mush",[self.delegate getNameForUser:self.contactee]];
    MGLineStyled *header = [MGLineStyled lineWithMultilineLeft:recipientName right:self.attachmentThumbnailView width:rowSize.width minHeight:70];
    header.leftPadding = header.rightPadding = 16;
    [self.topLines addObject:header];
    
    // Middle Row contains Message body text view    
    MGLineStyled *body = [MGLineStyled line];
    self.messageBodyTextView = [self getMessageBodyTextView];
    body.leftItems = [NSArray arrayWithObject:self.messageBodyTextView];
    body.minHeight = 250;
    body.borderStyle = MGBorderNone;
    [self.middleLines addObject:body];
    
    // Bottom Row contains Cancel and Send Buttons
    MGLineStyled *footer = MGLineStyled.line;
    footer.minHeight = 40;
    footer.middleItems = [self getComposeConfigButtons];
    footer.borderStyle = MGBorderNone;
    [self.bottomLines addObject:footer];
    
}

-(void)setUpForShredMessage{
    
    // a default row size
    CGSize rowSize = (CGSize){304, 60};
    
    // Header: Row contains Name, Date, Attachment
    NSString *senderName = [self.delegate getNameForUser:self.contactee];
    NSString *combinedNameTimeString = [NSString stringWithFormat:@"**%@**\n\n //%@//|mush", senderName, [Converter timeAndDateStringFromDate:self.messagePermission.createdAt]];
    
    // Header: Create clock icon
    UIImage *clock = [UIImage imageNamed:@"Clock.png"];
    
    // Header: Get attachment view if available
    if([self.message objectForKey:@"attachment"]){
        self.attachmentThumbnailView = [self getAttachmentThumbnailImageView];
        self.attachmentView = [self getAttachmentImageView];
        [self loadImages];
    }
    
    // Header: Add attachment view if available
    MGLineStyled *header = [MGLineStyled lineWithMultilineLeft:combinedNameTimeString right:self.attachmentThumbnailView width:rowSize.width minHeight:100];
    
    [header.leftItems insertObject:clock atIndex:0];
    header.leftPadding = header.rightPadding = 16;
    
    [self.topLines addObject:header];
    
    
    // Middle Row contains Message body text view
    MGLineStyled *body = [MGLineStyled line];
    body.multilineLeft = [self.message objectForKey:@"body"];
    body.minHeight = 250;
    body.borderStyle = MGBorderNone;
    [self.middleLines addObject:body];
    
    // Bottom Row contains Shred and Reply Buttons
    MGLineStyled *footer = MGLineStyled.line;
    //footer.backgroundColor = [UIColor grayColor];
    footer.minHeight = 40;
    //footer.middleItems = [NSArray arrayWithObjects:[self getShredButton],[self getReplyButton], nil];
    footer.middleItems = [self getShredConfigButtons];
    footer.borderStyle = MGBorderNone;
    [self.bottomLines addObject:footer];
    
}

#pragma mark - Create subviews

-(UITextView *)getMessageBodyTextView
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 20, 230, 250)];
    textView.backgroundColor = [UIColor clearColor];
    textView.font = HEADER_FONT;
    textView = [self addAccessoryViewToKeyboardOfTextView:textView];
    return textView;
}

-(UITextView *)addAccessoryViewToKeyboardOfTextView:(UITextView *)textView{

    UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:textView action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:textView action:@selector(resignFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolbar setItems:[NSArray arrayWithObjects:extraSpace, doneButton, nil]];
    textView.inputAccessoryView = toolbar;
    return textView;
}

-(UIButton *)getCancelButton
{
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.frame = CGRectMake(20, 20, 100, 30);
    [cancelButton addTarget:self
                     action:@selector(cancelButtonPressed:)
           forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    return cancelButton;
}

-(UIButton *)getSendButton
{
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.frame = CGRectMake(0, 0, 100, 30);
    [sendButton addTarget:self
                     action:@selector(sendButtonPressed:)
           forControlEvents:UIControlEventTouchUpInside];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    return sendButton;
}

-(UIButton *)getShredButton
{
    UIButton *shredButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    shredButton.frame = CGRectMake(20, 20, 100, 30);
    [shredButton addTarget:self
                     action:@selector(shredButtonPressed:)
           forControlEvents:UIControlEventTouchUpInside];
    [shredButton setTitle:@"Shred" forState:UIControlStateNormal];
    return shredButton;
}

-(UIButton *)getReplyButton
{
    UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    replyButton.frame = CGRectMake(0, 0, 100, 30);
    [replyButton addTarget:self
                   action:@selector(replyButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    [replyButton setTitle:@"Reply" forState:UIControlStateNormal];
    return replyButton;
}

-(NSMutableArray *)getComposeConfigButtons{
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 117, 47)];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:[UIImage imageNamed:@"CancelButtonGreen.png"] forState:UIControlStateNormal];
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 117, 47)];
    [sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setImage:[UIImage imageNamed:@"SendButton.png"] forState:UIControlStateNormal];
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:cancelButton, sendButton, nil];
    return array;
    
}

-(NSMutableArray *)getShredConfigButtons{
    
    UIButton *shredButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 117, 47)];
    [shredButton addTarget:self action:@selector(shredButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [shredButton setImage:[UIImage imageNamed:@"ShredButton.png"] forState:UIControlStateNormal];
    UIButton *replyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 117, 47)];
    [replyButton addTarget:self action:@selector(replyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [replyButton setImage:[UIImage imageNamed:@"ReplyButton.png"] forState:UIControlStateNormal];
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:shredButton, replyButton, nil];
    return array;
    
}


-(PFImageView *)getAttachmentIcon{
    
    PFImageView *attachmentIconView = [[PFImageView alloc] initWithImage:[UIImage imageNamed:@"PaperClip.png"]];
    attachmentIconView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(attachmentIconPressed:)];
    [attachmentIconView addGestureRecognizer:tapGesture];
    return attachmentIconView;
}

-(PFImageView *)getAttachmentThumbnailImageView{
    
    PFImageView *attachmentView = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    attachmentView.contentMode = UIViewContentModeScaleAspectFit;
    attachmentView.userInteractionEnabled = YES;
    
    attachmentView.file = (PFFile *)[self.message objectForKey:@"attachmentThumbnail"];
    
    attachmentView.userInteractionEnabled = YES;
    //UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(attachmentImagePressed:)];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(attachmentImageLongPressed:)];
    longPressGesture.cancelsTouchesInView = NO;
    
    [attachmentView addGestureRecognizer:longPressGesture];
    return attachmentView;
}

-(PFImageView *)getAttachmentImageView{
    
    PFImageView *attachmentView = [[PFImageView alloc] initWithFrame:CGRectZero];
    attachmentView.contentMode = UIViewContentModeScaleAspectFit;
    attachmentView.userInteractionEnabled = YES;
    
    attachmentView.file = (PFFile *)[self.message objectForKey:@"attachment"];
    
    attachmentView.userInteractionEnabled = YES;
    //UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(attachmentImagePressed:)];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(attachmentImageLongPressed:)];
    longPressGesture.minimumPressDuration = 0.05;

    [attachmentView addGestureRecognizer:longPressGesture];
    return attachmentView;
}

#pragma mark - Controls

-(void)cancelButtonPressed:(UIButton *)sender{
    
    [self.delegate cancelButtonPressed:self];
    
}

-(void)sendButtonPressed:(UIButton *)sender{
        
    // Disable multiple presses
    sender.enabled = NO;
    
    // Save info to message
    [self.message setObject:self.messageBodyTextView.text forKey:@"body"];
    
    // Fire delegate
    [self.delegate sendButtonPressed:self.message];
    
}

-(void)shredButtonPressed:(UIButton *)sender{
    
    [self.delegate shredButtonPressed:self];
    
}

-(void)replyButtonPressed:(UIButton *)sender{
    
    [self.delegate replyButtonPressed:self];
    
}

-(void)attachmentIconPressed:(UIImageView *)sender{
    
    [self.delegate attachmentIconPressed:self];
    
}

-(void)attachmentImagePressed:(UIImageView *)sender{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Try Again" message:@"You must hold your finger on the image to keep it on screen!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
}

-(void)attachmentImageLongPressed:(UIImageView *)sender{
    
    if(!self.isAttachmentOpen){
        
        CGRect screenDimensions = [self.delegate retrieveScreenDimensions:self];
         
        //[self.delegate showAttachmentView:self.attachmentView withBackgroundView:self.obfuscationView];
        
        // New Dimensions
        CGPoint screenCentre = CGPointMake(screenDimensions.size.width/2, screenDimensions.size.height/2);
         
         // Prepare Image View
         self.attachmentView.alpha = 1;
         self.attachmentView.frame = CGRectMake(screenCentre.x, screenCentre.y, 0, 0);
         
         // Prepare obfuscation view
         self.obfuscationView = [[UIImageView alloc] initWithFrame:screenDimensions];
         self.obfuscationView.backgroundColor = [UIColor blackColor];
         self.obfuscationView.alpha = 0;
        
        // Add views to main view
        [self.superview addSubview:self.obfuscationView];
        [self.superview addSubview:self.attachmentView];
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             
                             self.attachmentView.frame = CGRectMake(0, 0, screenDimensions.size.width, screenDimensions.size.height);
                             self.obfuscationView.alpha = 1;
                             
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
        [self setAttachmentOpen:YES];
        
    }
    
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"Not me...");
    
    [self setAttachmentOpen:NO];
    
    CGRect screenDimensions = [self.delegate retrieveScreenDimensions:self];
    CGPoint screenCentre = CGPointMake(screenDimensions.origin.x + (screenDimensions.size.width / 2), screenDimensions.origin.y + (screenDimensions.size.height / 2));
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         
                         // Prepare Image View
                         self.attachmentView.frame = CGRectMake(screenCentre.x, screenCentre.y, 0, 0);
                         self.obfuscationView.alpha = 0;
                         
                     }
                     completion:^(BOOL finished){
                         
                         [self.obfuscationView removeFromSuperview];
                         
                     }];
    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self screenshotDetected];
    
    self.attachmentView.alpha = 0;
    
    [UIView animateWithDuration:1
                     animations:^{
                         
                         self.obfuscationView.alpha = 0;
                         
                     }
                     completion:^(BOOL finished){
                         
                         [self.obfuscationView removeFromSuperview];
                         
                     }];
}

-(void)screenshotDetected{
    
    if(self.messagePermission){
        [self.messagePermission setObject:[NSNumber numberWithBool:YES] forKey:@"screenshotDetected"];
    }
    
}

-(void)updateAttachmentThumbnailView:(UIImage *)image{
    
    CGFloat squareEdge = 60;
    
    // Create a thumbnail and add a corner radius
    self.attachmentThumbnailView.frame = CGRectMake(self.attachmentThumbnailView.frame.origin.x-((squareEdge-self.attachmentThumbnailView.frame.size.width)/2), self.attachmentThumbnailView.frame.origin.y-((squareEdge-self.attachmentThumbnailView.frame.size.height)/2), squareEdge, squareEdge);
    
    self.attachmentThumbnailView.image = [image thumbnailImage:squareEdge
                                                             transparentBorder:0.0f
                                                                  cornerRadius:10.0f
                                                          interpolationQuality:kCGInterpolationDefault];
    
}

-(void)loadImages
{
    [self.attachmentThumbnailView loadInBackground:^(UIImage *image, NSError *error){
        
        // Create a thumbnail and add a corner radius
        //self.attachmentThumbnailView.image = image;
        
        [self.attachmentView loadInBackground:^(UIImage *image, NSError *error){
            
        }];
    }];
}




#pragma mark - TextView Delegate Methods


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - UIActionSheet Delegate Methods

@end

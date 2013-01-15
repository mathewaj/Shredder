//
//  ShredMessageViewController.m
//  Shredder
//
//  Created by Alan Mathews on 23/11/2012.
//
//

#import "ShredMessageViewController.h"
#import "MBProgressHUD.h"
#import "UIImage+ResizeAdditions.h"
#import "UIImage+RoundedCornerAdditions.h"

@interface ShredMessageViewController ()

@end

@implementation ShredMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.shreddingInProcess = [NSNumber numberWithBool:NO];
    
    // Add notification to dismiss oneself if app re-activates
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToBackground)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    
    // Set sender label
    if(!self.sender)
    {
        self.senderLabel.text = @"Shredder";
    } else {
        self.senderLabel.text = self.sender.name;
    }
    
    // Set attachment image
    if([self.message objectForKey:@"attachedImage"])
    {
        self.attachmentIcon.hidden = NO;
        
    } else {
        self.attachmentIcon.hidden = YES;
    }
    
    // Set date label
    NSDate *date = self.message.createdAt;
    /*NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];*/
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [timeFormatter setDateFormat:@"HH:mm"];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    NSString *formattedTimeString = [timeFormatter stringFromDate:date];
    
    self.sentDateLabel.text = [NSString stringWithFormat:@"%@ %@", formattedDateString, formattedTimeString];
    
    // Set message text view
    self.messageTextView.text = [self.message objectForKey:@"body"];
    
    // Load attached image if present
    if([self.message objectForKey:@"attachedImage"]){
        
        // Set image view
        self.attachmentView = [[PFImageView alloc] initWithFrame:CGRectMake(self.messageView.frame.origin.x + self.attachmentIcon.frame.origin.x + self.attachmentIcon.frame.size.width/2, self.messageView.frame.origin.y + self.attachmentIcon.frame.origin.y + self.attachmentIcon.frame.size.height/2, 0, 0)];
        self.attachmentView.contentMode = UIViewContentModeScaleAspectFit;
        self.attachmentView.userInteractionEnabled = YES;
        UIGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAttachment:)];
        [self.attachmentView addGestureRecognizer:tapGR];
        self.attachmentView.file = (PFFile *)[self.message objectForKey:@"attachedImage"]; // remote image
        
        [self.attachmentView loadInBackground:^(UIImage *image, NSError *error){
            
            // Create a thumbnail and add a corner radius
            self.attachmentIcon.image = [image thumbnailImage:43.0f
                                            transparentBorder:0.0f
                                                 cornerRadius:5.0f
                                         interpolationQuality:kCGInterpolationDefault];
        }];
    }
    
}

- (IBAction)shredButtonPressed:(id)sender {
    
    // Check if already shredding to prevent multiple shred reports
    if([self.shreddingInProcess isEqualToNumber:[NSNumber numberWithBool:NO]])
    {
        self.shreddingInProcess = [NSNumber numberWithBool:YES];
        
        // Create a shred report message
        PFObject *shredReport = [PFObject objectWithClassName:@"Message"];
        [shredReport setObject:[NSNumber numberWithBool:YES] forKey:@"report"];
        
        // Set message date, recipient, sender
        NSDate *sentDate = self.message.createdAt;
        [shredReport setObject:sentDate forKey:@"messageSent"];
        
        PFUser *messageRecipient = [self.message objectForKey:@"recipient"];
        [shredReport setObject:messageRecipient forKey:@"recipient"];
        
        PFUser *messageSender = [self.message objectForKey:@"sender"];
        [shredReport setObject:messageSender forKey:@"sender"];
        
        PFACL *messageACL = [PFACL ACL];
        [messageACL setReadAccess:YES forUser:messageSender];
        [messageACL setWriteAccess:YES forUser:messageSender];
        
        shredReport.ACL = messageACL;
        
        [shredReport saveInBackground];
        
        
        // Animate Shredding
        
        // Play sound and add graphic
        SystemSoundID chainsawId;
        NSString *chainsaw = [[NSBundle mainBundle]
                              pathForResource:@"chainsaw-02" ofType:@"wav"];
        NSURL *chainsawURL = [NSURL fileURLWithPath:chainsaw];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)chainsawURL, &chainsawId);
        AudioServicesPlaySystemSound(chainsawId);
        
        // Move message view up and start shred graphic
        CGRect newMessageFrame = self.messageView.frame;
        newMessageFrame.origin.y -= 568;
        [UIView animateWithDuration:1
                              delay:0
                            options:UIViewAnimationCurveLinear
                         animations:^{
                             
                             // Rotate shredding button
                             self.shredButton.transform = CGAffineTransformRotate(self.shredButton.transform, M_PI / 2);
                             
                             // Message moves upwards
                             self.messageView.frame = newMessageFrame;
                             
                         }
                         completion:^(BOOL finished){
                             
                             self.shreddingEffectView.confettiEmitter.birthRate = 20;
                             
                             // If attachment -> confetti multi-coloured
                             if([self.message objectForKey:@"attachedImage"])
                             {
                                 self.shreddingEffectView.confettiColour.birthRate = 20;

                             }
                             
                             [self.shreddingEffectView decayOverTime:1];
                             [self performSelector:@selector(dismissController) withObject:nil afterDelay:3.0];
                             
                         }];
        
        
        
        // Delete message
        [self.message deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            
        }];
    }
      
}

-(void)dismissController{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)goToBackground{
    
    // Delete message if app goes to background
    self.shreddingInProcess = [NSNumber numberWithBool:YES];
    
    // Create a shred report message
    PFObject *shredReport = [PFObject objectWithClassName:@"Message"];
    [shredReport setObject:[NSNumber numberWithBool:YES] forKey:@"report"];
    
    // Set message date, recipient, sender
    NSDate *sentDate = self.message.createdAt;
    [shredReport setObject:sentDate forKey:@"messageSent"];
    
    PFUser *messageRecipient = [self.message objectForKey:@"recipient"];
    [shredReport setObject:messageRecipient forKey:@"recipient"];
    
    PFUser *messageSender = [self.message objectForKey:@"sender"];
    [shredReport setObject:messageSender forKey:@"sender"];
    
    PFACL *messageACL = [PFACL ACL];
    [messageACL setReadAccess:YES forUser:messageSender];
    [messageACL setWriteAccess:YES forUser:messageSender];
    
    shredReport.ACL = messageACL;
    
    [shredReport saveInBackground];
    
    // Delete message
    [self.message deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    
    
}

- (IBAction)attachmentIconSelected:(id)sender {
    
    self.attachmentIcon.userInteractionEnabled = NO;
    [self.view addSubview:self.attachmentView];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect newFrame = self.view.frame;
                         self.attachmentView.frame = newFrame;
                         
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

-(void)closeAttachment:(UITapGestureRecognizer *)sender
{
    UIImageView *attachmentView = (UIImageView *)sender.view;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect newFrame = CGRectMake(self.messageView.frame.origin.x + self.attachmentIcon.frame.origin.x + self.attachmentIcon.frame.size.width/2, self.messageView.frame.origin.y + self.attachmentIcon.frame.origin.y + self.attachmentIcon.frame.size.height/2, 0, 0);
                         attachmentView.frame = newFrame;
                         
                     }
                     completion:^(BOOL finished){
                         
                         [attachmentView removeFromSuperview];
                         
                     }];
    
    
    self.attachmentIcon.userInteractionEnabled = YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMessageView:nil];
    [self setShreddingEffectView:nil];
    [self setShredButton:nil];
    [super viewDidUnload];
}
@end

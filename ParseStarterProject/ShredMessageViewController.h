//
//  ShredMessageViewController.h
//  Shredder
//
//  Created by Alan Mathews on 23/11/2012.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Contact.h"
#import "ShreddingEffectView.h"

@interface ShredMessageViewController : UIViewController

// Model is a Message and a Contact

@property (nonatomic, strong) PFObject *message;
@property (nonatomic, strong) Contact *sender;

@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *sentDateLabel;

@property (weak, nonatomic) IBOutlet UIImageView *attachmentIcon;
@property (strong, nonatomic) PFImageView *attachmentView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@property (weak, nonatomic) IBOutlet UIImageView *shredButton;
@property (weak, nonatomic) IBOutlet ShreddingEffectView *shreddingEffectView;
@property (strong, nonatomic) NSNumber *shreddingInProcess;
@property (strong, nonatomic) NSNumber *reportSent;

@end

//
//  ComposeMessageViewController.h
//  ParseStarterProject
//
//  Created by Alan Mathews on 30/10/2012.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Contact.h"

@interface ComposeMessageViewController : UIViewController <UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate>

// Model is a Contact / PFUser
@property (nonatomic, strong) Contact *recipient;
@property (nonatomic, strong) PFUser *recipientUser;

@property (nonatomic, strong) UIImage *attachedImage;
@property (weak, nonatomic) IBOutlet UIImageView *attachedImageThumbnailView;

@property (weak, nonatomic) IBOutlet UILabel *recipientLabel;
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;

@property (strong, nonatomic) NSNumber *sendingInProcess;


@end

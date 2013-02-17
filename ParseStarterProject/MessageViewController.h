//
//  MessageViewController.h
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Message.h"
#import "ShredderUser.h"
#import "MGScrollView.h"
#import "MessageView.h"


@interface MessageViewController : UIViewController <MessageViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

// Model: Message
@property (nonatomic, strong) Message *message;

// Model: Shredder User
@property (nonatomic, strong) ShredderUser *contact;

// Model: Compose or Shred
@property (nonatomic, assign, getter=isComposeMode) BOOL composeMode;

// Model: Attachment Picture
@property (nonatomic, strong) NSMutableArray *images;

// Control: Attach Photo
-(void)attachPhoto:(UIImage *)photo;

// Control: Send Message
-(void)sendMessage:(Message *)message;

// View: MGScrollView
@property(nonatomic, strong) MGScrollView *scrollView;

// View: MessageView
@property (nonatomic, strong) MessageView *messageView;


@end

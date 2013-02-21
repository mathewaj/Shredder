//
//  MessageViewController.h
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MessagePermission.h"
#import "Message.h"
#import "ShredderUser.h"
#import "ShreddingEffectView.h"
#import "ContactsDatabaseManager.h"
#import "MGScrollView.h"
#import "MessageView.h"
#import "MGBox.h"



@interface MessageViewController : UIViewController <MessageViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

// Model: Message Permission
@property (nonatomic, strong) MessagePermission *messagePermission;

// Model: Message
@property (nonatomic, strong) Message *message;

// Model: Contacts Database
@property (nonatomic, strong) ContactsDatabaseManager *contactsDatabaseManager;

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

// View: MGBox
@property(nonatomic, strong) MGScrollView *containerView;

// View: MessageView
@property (nonatomic, strong) MessageView *messageView;

// View: Send Button Status
@property (nonatomic, assign, getter=isSendButtonPressed) BOOL isSendButtonPressed;

// View: Shredding Animation
@property (strong, nonatomic) ShreddingEffectView *shreddingEffectView;


@end

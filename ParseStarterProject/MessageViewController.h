//
//  MessageViewController.h
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import <UIKit/UIKit.h>
#import "ParseManager.h"
#import "ContactsViewControllerII.h"
#import "Contact.h"
#import "ShreddingEffectView.h"
#import "ContactsDatabaseManager.h"
#import "MGScrollView.h"
#import "MessageView.h"
#import "MGBox.h"



@interface MessageViewController : UIViewController <MessageViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ContactsViewControllerIIDelegate, ABUnknownPersonViewControllerDelegate>

// Model: Message Permission
@property (nonatomic, strong) PFObject *messagePermission;

// Model: Message
@property (nonatomic, strong) PFObject *message;

// Model: Shredder User
@property (nonatomic, strong) PFUser *contact;

// Model: Contacts Database
@property (nonatomic, strong) ContactsDatabaseManager *contactsDatabaseManager;

// Model: Compose or Shred
@property (nonatomic, assign, getter=isComposeMode) BOOL composeMode;

// Model: Attachment Picture
@property (nonatomic, strong) NSMutableArray *images;

// Control Model: Flag
@property (nonatomic, assign, getter=isFirstView) BOOL firstView;


// View: MGScrollView
@property(nonatomic, strong) MGScrollView *scrollView;

// View: MGBox
@property(nonatomic, strong) MGBox *containerView;

// View: MessageView
@property (nonatomic, strong) MessageView *messageView;

// View: Send Button Status
@property (nonatomic, assign, getter=isSendButtonPressed) BOOL isSendButtonPressed;

// View: Shredding Animation
@property (weak, nonatomic) IBOutlet ShreddingEffectView *shreddingEffectView;

@end

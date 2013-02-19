//
//  MessageView.h
//  Shredder
//
//  Created by Shredder on 15/02/2013.
//
//

#import "MGTableBoxStyled.h"
#import "Message.h"
#import "ShredderUser.h"
#import "MessagePermission.h"

@class MessageView;

@protocol MessageViewDelegate <NSObject>

-(void)cancelButtonPressed:(MessageView *)sender;
-(void)sendButtonPressed:(Message *)messageToBeSent;
-(void)shredButtonPressed:(MessageView *)sender;
-(void)replyButtonPressed:(MessageView *)sender;
-(void)attachmentIconPressed:(MessageView *)sender;
-(CGRect)retrieveScreenDimensions:(MessageView *)sender;
-(void)showAttachmentView:(UIImageView *)attachmentView withBackgroundView:(UIImageView *)backgroundView;

-(NSString *)getNameForUser:(PFObject *)user;

@end

@interface MessageView : MGTableBoxStyled

- (id)initWithFrame:(CGRect)frame withEmptyMessage:(Message *)message forRecipient:(ShredderUser *) recipient andDelegate:(id <MessageViewDelegate>)delegate;
- (id)initWithFrame:(CGRect)frame withPopulatedMessagePermission:(MessagePermission *)messagePermission andDelegate:(id <MessageViewDelegate>)delegate;

-(void)updateAttachmentThumbnailView:(UIImage *)image;

// Model: Message
@property (nonatomic, strong) Message *message;

// Model: Message Permission
@property (nonatomic, strong) MessagePermission *messagePermission;

// Model: Shredder User Contactee
@property (nonatomic, strong) ShredderUser *contactee;

// Subviews:
@property (nonatomic, strong) UITextView *messageBodyTextView;
@property (nonatomic, strong) PFImageView *attachmentThumbnailView;
@property (nonatomic, strong) PFImageView *attachmentView;
@property (nonatomic, strong) UIImageView *obfuscationView;


// Control: Inform delegate that Shred Button Pressed
-(IBAction)shredButtonPressed:(id)sender;

// Control: Inform delegate that Reply Button Pressed
-(IBAction)replyButtonPressed:(id)sender;

// Control: Attachment Thumbnail Pressed
-(IBAction)attachmentThumbnailPressed:(id)sender;

// Control: Attachment Thumbnail Long Pressed
-(IBAction)attachmentThumbnailPressed:(id)sender;

// Control Model: Delegate
@property (nonatomic, weak) id <MessageViewDelegate> delegate;

// Control Model: Attachment Status
@property (nonatomic, assign, getter=isAttachmentOpen) BOOL attachmentOpen;

@end

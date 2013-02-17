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

@class MessageView;

@protocol MessageViewDelegate <NSObject>

-(void)cancelButtonPressed:(MessageView *)sender;
-(void)sendButtonPressed:(MessageView *)sender;
-(void)shredButtonPressed:(MessageView *)sender;
-(void)replyButtonPressed:(MessageView *)sender;
-(void)attachmentIconPressed:(MessageView *)sender;
-(CGRect)retrieveScreenDimensions:(MessageView *)sender;

@end

@interface MessageView : MGTableBoxStyled

- (id)initWithFrame:(CGRect)frame withEmptyMessage:(Message *)message;
- (id)initWithFrame:(CGRect)frame withPopulatedMessage:(Message *)message;

-(void)updateAttachmentThumbnailView:(UIImage *)image;

// Model: Shredder User Contactee
@property (nonatomic, strong) ShredderUser *contactee;

// Model: Message
@property (nonatomic, strong) Message *message;

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

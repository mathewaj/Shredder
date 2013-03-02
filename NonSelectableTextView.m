//
//  NonSelectableTextView.m
//  Shredder
//
//  Created by Shredder on 01/03/2013.
//
//

#import "NonSelectableTextView.h"

@implementation NonSelectableTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)canBecomeFirstResponder {
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

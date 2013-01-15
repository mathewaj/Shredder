//
//  ShreddingEffectView.h
//  ParseStarterProject
//
//  Created by Alan Mathews on 22/11/2012.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ShreddingEffectView : UIView

- (void) decayOverTime:(NSTimeInterval)interval;

@property (nonatomic, strong) CAEmitterLayer *confettiEmitter;
@property (nonatomic, strong) CAEmitterCell *confettiWhite;
@property (nonatomic, strong) CAEmitterCell *confettiColour;

@end

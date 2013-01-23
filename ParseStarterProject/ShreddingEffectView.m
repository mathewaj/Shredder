//
//  ShreddingEffectView.m
//  ParseStarterProject
//
//  Created by Alan Mathews on 22/11/2012.
//
//

#import "ShreddingEffectView.h"


@implementation ShreddingEffectView {
    //__weak CAEmitterLayer *_confettiEmitter;
    CGFloat _decayAmount;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        
        self.userInteractionEnabled = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.confettiEmitter = (CAEmitterLayer*)self.layer;
        self.confettiEmitter.emitterPosition = CGPointMake(self.bounds.size.width /2, 0);
        self.confettiEmitter.emitterSize = CGSizeMake(250, 15);
        self.confettiEmitter.emitterShape = kCAEmitterLayerLine;
        self.confettiEmitter.birthRate = 0;
        
        self.confettiWhite = [CAEmitterCell emitterCell];
        self.confettiWhite.contents = (__bridge id)[[UIImage imageNamed:@"Confetti.png"] CGImage];
        self.confettiWhite.name = @"confetti";
        self.confettiWhite.birthRate = 50;
        self.confettiWhite.lifetime = 5.0;
        self.confettiWhite.velocity = 250;
        self.confettiWhite.velocityRange = 50;
        self.confettiWhite.emissionRange = (CGFloat) M_PI_2;
        self.confettiWhite.emissionLongitude = (CGFloat) M_PI;
        self.confettiWhite.yAcceleration = 150;
        self.confettiWhite.scale = 1.0;
        self.confettiWhite.scaleRange = 0.2;
        self.confettiWhite.spinRange = 10.0;
        self.confettiWhite.color = [[UIColor colorWithRed:1.0 green:1.0 blue:120.0/255.0 alpha:1.0] CGColor];
        
        
        self.confettiColour = [CAEmitterCell emitterCell];
        self.confettiColour.contents = (__bridge id)[[UIImage imageNamed:@"Confetti.png"] CGImage];
        self.confettiColour.name = @"confetti2";
        self.confettiColour.birthRate = 0;
        self.confettiColour.lifetime = 5.0;
        self.confettiColour.velocity = 250;
        self.confettiColour.velocityRange = 50;
        self.confettiColour.emissionRange = (CGFloat) M_PI_2;
        self.confettiColour.emissionLongitude = (CGFloat) M_PI;
        self.confettiColour.yAcceleration = 150;
        self.confettiColour.scale = 1.0;
        self.confettiColour.scaleRange = 0.2;
        self.confettiColour.spinRange = 10.0;
        self.confettiColour.color = [[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0] CGColor];
        self.confettiColour.redRange = 0.8;
        self.confettiColour.blueRange = 0.8;
        self.confettiColour.greenRange = 0.8;
        
        self.confettiEmitter.emitterCells = [NSArray arrayWithObjects:self.confettiWhite, self.confettiColour, nil];
        
    }
    
    return self;
}

+ (Class) layerClass {
    return [CAEmitterLayer class];
}

static NSTimeInterval const kDecayStepInterval = 0.1;
- (void) decayStep {
    _confettiEmitter.birthRate -=_decayAmount;
    if (_confettiEmitter.birthRate < 0) {
        _confettiEmitter.birthRate = 0;
    } else {
        [self performSelector:@selector(decayStep) withObject:nil afterDelay:kDecayStepInterval];
    }
}

- (void) decayOverTime:(NSTimeInterval)interval {
    _decayAmount = (CGFloat) (_confettiEmitter.birthRate /  (interval / kDecayStepInterval));
    [self decayStep];
}

- (void) stopEmitting {
    _confettiEmitter.birthRate = 0.0;
}

@end

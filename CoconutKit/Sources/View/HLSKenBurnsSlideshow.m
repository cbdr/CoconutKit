//
//  HLSKenBurnsSlideshow.m
//  CoconutKit
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSKenBurnsSlideshow.h"

#import "HLSAnimation.h"
#import "HLSLogger.h"

const NSTimeInterval kKenBurnsSlideshowDefaultDuration = 3.;

@interface HLSKenBurnsSlideshow () <HLSAnimationDelegate>

- (void)hlsKenBurnsSlideshowInit;

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) NSArray *images;
@property (nonatomic, retain) NSArray *finalFrames;
@property (nonatomic, retain) NSArray *durations;
@property (nonatomic, retain) HLSAnimation *animation;

@end

@implementation HLSKenBurnsSlideshow

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self hlsKenBurnsSlideshowInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self hlsKenBurnsSlideshowInit];
    }
    return self;
}

- (void)hlsKenBurnsSlideshowInit
{
    self.clipsToBounds = YES;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imageView];
        
    self.images = [NSArray array];
    self.finalFrames = [NSArray array];
    self.durations = [NSArray array];
    
    m_currentImageIndex = -1;
}

- (void)dealloc
{
    [self stopAnimating];
    
    self.imageView = nil;
    self.images = nil;
    self.finalFrames = nil;
    self.durations = nil;
    self.animation = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize imageView = m_imageView;

@synthesize images = m_images;

@synthesize finalFrames = m_finalFrames;

@synthesize durations = m_durations;

@synthesize animation = m_animation;

#pragma mark Loading images

- (void)addImage:(UIImage *)image withFinalFrame:(CGRect)finalFrame
{
    return [self addImage:image withFinalFrame:finalFrame duration:kKenBurnsSlideshowDefaultDuration];
}

- (void)addImage:(UIImage *)image withFinalFrame:(CGRect)finalFrame duration:(NSTimeInterval)duration
{
    // TODO: Prevent when an animation is already running
    
    self.images = [self.images arrayByAddingObject:image];
    self.finalFrames = [self.finalFrames arrayByAddingObject:[NSValue valueWithCGRect:finalFrame]];
    self.durations = [self.durations arrayByAddingObject:[NSNumber numberWithDouble:duration]];
}

#pragma mark Playing the slideshow

- (void)startAnimating
{
    NSMutableArray *animationSteps = [NSMutableArray array];
    for (NSUInteger i = 0; i < [self.images count]; ++i) {
        // TODO: Calculate correct end frame
        HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStep];
        animationStep1.duration = [[self.durations objectAtIndex:i] doubleValue];
        HLSViewAnimationStep *viewAnimationStep11 = [HLSViewAnimationStep viewAnimationStep];
        viewAnimationStep11.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        [animationStep1 addViewAnimationStep:viewAnimationStep11 forView:self.imageView];
        [animationSteps addObject:animationStep1];
        
        HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStep];
        animationStep2.duration = 0.;
        HLSViewAnimationStep *viewAnimationStep21 = [HLSViewAnimationStep viewAnimationStep];
        viewAnimationStep21.transform = CGAffineTransformInvert(CGAffineTransformMakeScale(1.3f, 1.3f));
        [animationStep2 addViewAnimationStep:viewAnimationStep21 forView:self.imageView];
        [animationSteps addObject:animationStep2];
    }
    
    self.animation = [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithArray:animationSteps]];
    self.animation.delegate = self;
    [self.animation playAnimated:YES];
}

- (void)stopAnimating
{
    [self.animation cancel];
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{
    self.imageView.image = [self.images firstObject];
}

- (void)animationStepFinished:(HLSAnimationStep *)animationStep animated:(BOOL)animated
{
    // TODO: Display next image
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    // TODO: Loop
}

@end

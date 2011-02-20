//
//  DNAnimView.h
//  BouncyNess
//
//  Created by Andrew Pouliot on 2/19/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>

@class DNUIViewExplicitAnimationProxy;
@interface UIView (ExplicitAnimation)

+ (void)animateExplicitlyWithDuration:(NSTimeInterval)duration frameRate:(double)frameRate animations:(void (^)(double t, double dt))animations;

//Acts like the view, except all property changes are scheduled for the relevant frame instead of immediately
- (DNUIViewExplicitAnimationProxy *)explicitFrameProxy;

@end

@interface DNUIViewExplicitAnimationProxy : NSObject {
@private
	UIView *_proxiedView;
}

//Reading these will not give you the previous-frame values, rather the current values.
@property (nonatomic) float alpha;
@property (nonatomic) CGPoint center;
@property (nonatomic) CGAffineTransform transform;

//Defined as layer.contents, allows image animations
@property (nonatomic, retain) id layerContents;

@end

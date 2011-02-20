//
//  DNAnimView.m
//  BouncyNess
//
//  Created by Andrew Pouliot on 2/19/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import "UIView+ExplicitAnimation.h"

#import <QuartzCore/QuartzCore.h>

@interface DNUIViewExplicitAnimationBuffer : NSObject {
	NSMutableDictionary *_viewAnimationBuffers; //{view: {key:values[]}}
	NSTimeInterval _duration;
}
+ (void)push;
+ (DNUIViewExplicitAnimationBuffer *)current;
+ (void)commit;

//TODO: support time as well for sparse animations?
- (void)setValue:(id)value forKey:(NSString *)key inView:(UIView *)inView;
- (void)commit;
@property (nonatomic) NSTimeInterval duration;

@end

static DNUIViewExplicitAnimationBuffer *_DNUIViewExplicitAnimationBufferCurrent = nil;

@implementation DNUIViewExplicitAnimationBuffer
@synthesize duration = _duration;

+ (void)push;
{
	NSAssert(!_DNUIViewExplicitAnimationBufferCurrent, @"Current limitation: cannot push with a buffer already existing");
	_DNUIViewExplicitAnimationBufferCurrent = [[DNUIViewExplicitAnimationBuffer alloc] init];
}
+ (id)current;
{
	//this is just for debugging, obv nil is not going to crash us
	NSAssert(_DNUIViewExplicitAnimationBufferCurrent, @"Current animation buffer is nil");
	return _DNUIViewExplicitAnimationBufferCurrent;
}
+ (void)commit;
{
	[_DNUIViewExplicitAnimationBufferCurrent commit];
	[_DNUIViewExplicitAnimationBufferCurrent release];
	_DNUIViewExplicitAnimationBufferCurrent = nil;
}

- (id)init;
{
	self = [super init];
	if (!self) return nil;

	_viewAnimationBuffers = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (void)dealloc {
    [_viewAnimationBuffers release];
    [super dealloc];
}

- (void)setValue:(id)value forKey:(NSString *)key inView:(UIView *)inView;
{
	NSValue *viewPointerValue = [NSValue valueWithPointer:inView];
	NSMutableDictionary *viewDictionary = [_viewAnimationBuffers objectForKey:viewPointerValue];
	if (!viewDictionary) {
		viewDictionary = [NSMutableDictionary dictionary];
		[_viewAnimationBuffers setObject:viewDictionary forKey:viewPointerValue];
	}
	
	NSMutableArray *valuesArray = [viewDictionary objectForKey:key];
	if (!valuesArray) {
		valuesArray = [NSMutableArray array];
		[viewDictionary setObject:valuesArray forKey:key];
	}
	[valuesArray addObject:value];
	
}

- (void)commit;
{
	//For each view in the views array
	for (NSValue *viewPointerValue in [_viewAnimationBuffers keyEnumerator]) {
		NSDictionary *dict = [_viewAnimationBuffers objectForKey:viewPointerValue];
		//For each key in the keys array
		UIView *view = (UIView *)[viewPointerValue pointerValue];
		for (NSString *action in [dict keyEnumerator]) {
			CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:action];
			animation.duration = _duration;
			animation.values = [dict objectForKey:action];
			[view.layer addAnimation:animation forKey:action];
		}
	}
}

@end

@interface DNUIViewExplicitAnimationProxy (DNUIViewExplicitAnimationProxyPrivate)
- (id)initWithProxiedView:(UIView *)inView;
@end

@implementation DNUIViewExplicitAnimationProxy
- (id)initWithProxiedView:(UIView *)inView;
{
	self = [super init];
	if (!self) return nil;
	
	_proxiedView = [inView retain];
	
	return self;
}

- (void)dealloc {
    [_proxiedView release];
    [super dealloc];
}

- (float)alpha;
{
	return _proxiedView.alpha;
}

- (void)setAlpha:(float)inAlpha;
{
	[[DNUIViewExplicitAnimationBuffer current] setValue:[NSNumber numberWithFloat:inAlpha] forKey:@"opacity" inView:_proxiedView];
}

- (CGPoint)center;
{
	return _proxiedView.center;
}

- (void)setCenter:(CGPoint)inCenter;
{
	[[DNUIViewExplicitAnimationBuffer current] setValue:[NSValue valueWithCGPoint:inCenter] forKey:@"position" inView:_proxiedView];
}

- (CGAffineTransform)transform;
{
	return _proxiedView.transform;
}

- (void)setTransform:(CGAffineTransform)inTransform;
{
	[[DNUIViewExplicitAnimationBuffer current] setValue:[NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(inTransform)] forKey:@"transform" inView:_proxiedView];
}

- (id)layerContents;
{
	return _proxiedView.layer;
}

- (void)setLayerContents:(id)inContents;
{
	[[DNUIViewExplicitAnimationBuffer current] setValue:inContents forKey:@"contents" inView:_proxiedView];
}


@end


double (^_DNAnimViewAnimationTimingBlock)(double);

@implementation UIView (ExplicitAnimation)

+ (void)animateExplicitlyWithDuration:(NSTimeInterval)duration frameRate:(double)frameRate animations:(void (^)(double t, double dt))animations;
{
	NSUInteger frameCount = MAX(0, duration * frameRate);
	if (frameCount > 1000) {
		NSLog(@"Frame count: %d", frameCount);
	} else if (frameCount > 10000) {
		NSLog(@"Warning: extremely long explicit animation. Ill-advised.");
	}
	
	//Set global buffer for the explicit animation proxies
	[DNUIViewExplicitAnimationBuffer push];
	[DNUIViewExplicitAnimationBuffer current].duration = duration;
	for (int frameNumber=0; frameNumber < frameCount; frameNumber++) {
		animations(1.0 / duration, 1.0/frameRate); //stage 1
	}
	//Unset global buffer for the explicit animation proxies
	
	//This should apply the final animation positions/alphas/whatevers
	//and actually add the animations we've been accumulating to the 
	//animations(duration, 1.0/frameRate); //stage 2
	[DNUIViewExplicitAnimationBuffer commit];
	
}

+ (void)setAnimationTimingBlock:(double (^)(double))inBlock;
{
	if (_DNAnimViewAnimationTimingBlock != inBlock) {
		[_DNAnimViewAnimationTimingBlock autorelease];
		_DNAnimViewAnimationTimingBlock = [inBlock copy];
	}
}

- (UIView *)explicitFrameProxy;
{
	return (UIView *)[[[DNUIViewExplicitAnimationProxy alloc] initWithProxiedView:self] autorelease];
}

- (void)dealloc
{
    [super dealloc];
}

@end

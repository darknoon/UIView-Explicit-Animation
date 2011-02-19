//
//  DNAnimView.m
//  BouncyNess
//
//  Created by Andrew Pouliot on 2/19/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import "DNAnimView.h"

#import <QuartzCore/QuartzCore.h>

@interface DNAnimAction : CAKeyframeAnimation <CAAction>
{
	NSValue *_fromValue;
	NSValue *_toValue;
	double (^_animationCurveBlock)(double);
}

@property (copy, nonatomic) double (^animationCurveBlock)(double);
@property (copy, nonatomic) NSValue *fromValue;
@property (copy, nonatomic) NSValue *toValue;

@end

@implementation DNAnimAction
@synthesize fromValue = _fromValue;
@synthesize toValue = _toValue;
@synthesize animationCurveBlock = _animationCurveBlock;

CGPoint _CGPointLerp(CGPoint a, CGPoint b, double t) {
	return (CGPoint) {
		.x = a.x + t*(b.x - a.x),
		.y = a.y + t*(b.y - a.y),
	};
};

- (void)runActionForKey:(NSString *)event object:(id)anObject arguments:(NSDictionary *)dict;
{
	NSUInteger frames = MAX(0, self.duration * 60.0f);
	self.toValue = [anObject valueForKey:event];
	const char *objCType = [self.fromValue objCType];
	if (strcmp(objCType, @encode(CATransform3D)) == 0) {
	} else if (strcmp(objCType, @encode(CGPoint)) == 0) {
		CGPoint startP = [self.fromValue CGPointValue];
		CGPoint endP = [self.toValue CGPointValue];
		NSMutableArray *values = [NSMutableArray array];
		for (int i=0; i<frames; i++) {
			double t = (double)i/frames;
			double v = _animationCurveBlock(t);
			[values addObject:[NSValue valueWithCGPoint:_CGPointLerp(startP, endP, v)]];
		}
		self.values = values;
	}
	[anObject addAnimation:self forKey:event];
}

@end


double (^_DNAnimViewAnimationTimingBlock)(double);

@implementation DNAnimView

+ (void)setAnimationTimingBlock:(double (^)(double))inBlock;
{
	if (_DNAnimViewAnimationTimingBlock != inBlock) {
		[_DNAnimViewAnimationTimingBlock autorelease];
		_DNAnimViewAnimationTimingBlock = [inBlock copy];
	}
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}

- (id <CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event;
{
	id <CAAction> superAction = [super actionForLayer:layer forKey:event];
	if ((id)superAction != [NSNull null]) {
		CABasicAnimation *basicAnim = (CABasicAnimation *)superAction;
		//NSLog(@"basic animation: %@ => %@ (%@)", basicAnim.fromValue, basicAnim.toValue, basicAnim.valueFunction);
		
		DNAnimAction *action = [[[DNAnimAction alloc] init] autorelease];
		action.duration = basicAnim.duration; //Grab the duration we should have from the super implementation
		action.fromValue = [layer valueForKey:event];
		
		action.animationCurveBlock = _DNAnimViewAnimationTimingBlock ? _DNAnimViewAnimationTimingBlock : ^(double t) {
			return t;
		};
		return action;
	}
	
	return superAction;
}

- (void)dealloc
{
    [super dealloc];
}

@end

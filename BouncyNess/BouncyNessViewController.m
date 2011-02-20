//
//  BouncyNessViewController.m
//  BouncyNess
//
//  Created by Andrew Pouliot on 2/19/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import "BouncyNessViewController.h"

#import "UIView+ExplicitAnimation.h"

@implementation BouncyNessViewController
@synthesize bouncyView;
@synthesize shadowView;

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
	[self animate:nil];
}

- (IBAction)animate:(id)sender;
{
	
	CGPoint startCenter = ((CALayer *)[bouncyView.layer presentationLayer]).position;
	CGPoint endCenter = bouncyViewCenter;

	//Scope for variables in physics simulation
	__block double v = -402;
	__block double p = startCenter.y;
	__block double pt = 0;
	double restitution = 0.7;
	double g = 1080;
	double duration = 2.0 + 0.01 * (endCenter.y - startCenter.y); //Add an additional second for each 100 pixel of height we have
	
	NSLog(@"Duration :%lf", duration);
	
	[UIView animateExplicitlyWithDuration:duration frameRate:30.0 animations:^(double t, double dt) {
		DNUIViewExplicitAnimationProxy *objectProxy = [bouncyView explicitFrameProxy];
		DNUIViewExplicitAnimationProxy *shadowProxy = [shadowView explicitFrameProxy];
		
		//Physics simulation here :)
		pt = t;
		if (p > endCenter.y) {
			v = -restitution * v;
			p = endCenter.y;
		} else {
			v += g * dt;
			p += dt * v;
		}
		objectProxy.alpha = 1.0 + 0.5 * sin(0.1 * t); 
		objectProxy.center = (CGPoint) {.x = endCenter.x, .y = p};
		
		double d = endCenter.y - p;
		shadowProxy.alpha = 0.8 / (1.0 + 0.01 * d);
		shadowProxy.transform = CGAffineTransformMakeScale(1.0 + 0.005 * d, 1.0 + 0.005 * d);
	}];	
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	bouncyViewCenter = bouncyView.center;
	shadowView.center = (CGPoint){.x = bouncyViewCenter.x, .y = CGRectGetMaxY(bouncyView.frame)};
	shadowView.alpha = 0.8;
}

- (void)viewDidUnload
{
	self.bouncyView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end

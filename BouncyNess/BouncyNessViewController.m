//
//  BouncyNessViewController.m
//  BouncyNess
//
//  Created by Andrew Pouliot on 2/19/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import "BouncyNessViewController.h"

#import "DNAnimView.h"

@implementation BouncyNessViewController
@synthesize bouncyView;

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


- (IBAction)animate:(id)sender;
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:4.0];
	
	double omega = 20.0;
	double zeta = 0.33;
	[DNAnimView setAnimationTimingBlock:^(double t){
		double beta = sqrt(1 - zeta * zeta);
		double phi = atan(beta / zeta);
		double result = 1.0 + -1.0 / beta * exp(-zeta * omega * t) * sin(beta * omega * t + phi);
		return result;
	}];
	
	__block double v = -22;
	__block double p = 0;
	__block double pt = 0;
	double restitution = 0.7;
	double g = 80;
	double dt = 1.0/60.0;
	[DNAnimView setAnimationTimingBlock:^(double t){
		pt = t;
		if (p > 1.0) {
			v = -restitution * v;
			p = 1.0;
		} else {
			v += g * dt;
			p += dt * v;
		}
		return p;
	}];
	
	CGRect bouncyViewFrame = bouncyView.frame;
	bouncyViewFrame.origin.y += 10.f;
	bouncyView.frame = bouncyViewFrame;
	
	[UIView commitAnimations];
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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

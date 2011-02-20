//
//  BouncyNessViewController.h
//  BouncyNess
//
//  Created by Andrew Pouliot on 2/19/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DNAnimView;
@interface BouncyNessViewController : UIViewController {
	UIView *bouncyView;
	UIImageView *shadowView;
	//Store this incase we interrupt our animation
	CGPoint bouncyViewCenter;
}
@property (nonatomic, retain) IBOutlet UIView *bouncyView;
@property (nonatomic, retain) IBOutlet UIView *shadowView;

- (IBAction)animate:(id)sender;

@end


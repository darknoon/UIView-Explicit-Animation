//
//  BouncyNessAppDelegate.h
//  BouncyNess
//
//  Created by Andrew Pouliot on 2/19/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BouncyNessViewController;

@interface BouncyNessAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet BouncyNessViewController *viewController;

@end

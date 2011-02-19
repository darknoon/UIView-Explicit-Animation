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
    
	DNAnimView *bouncyView;
}
@property (nonatomic, retain) IBOutlet DNAnimView *bouncyView;

- (IBAction)animate:(id)sender;

@end


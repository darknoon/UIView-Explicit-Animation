//
//  DNAnimView.h
//  BouncyNess
//
//  Created by Andrew Pouliot on 2/19/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DNAnimView : UIView {
    
}

+ (void)setAnimationTimingBlock:(double (^)(double))block;

@end

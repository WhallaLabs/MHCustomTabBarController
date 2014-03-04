/*
 * Copyright (c) 2013 Martin Hartl
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "MHTabBarSegue.h"
#import "MHCustomTabBarController.h"

@implementation MHTabBarSegue
- (void) perform {
    MHCustomTabBarController *tabBarViewController = (MHCustomTabBarController *)self.sourceViewController;
    UIViewController *destinationViewController = (UIViewController *) tabBarViewController.destinationViewController;
    UIViewController *previousViewController = tabBarViewController.oldViewController;
    
    [[destinationViewController view] setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];

    if (!previousViewController) {
        [tabBarViewController addChildViewController:destinationViewController];
        destinationViewController.view.frame = tabBarViewController.container.bounds;
        [tabBarViewController.container addSubview:destinationViewController.view];
        [destinationViewController didMoveToParentViewController:tabBarViewController];
        
        return;
    }
    
    [tabBarViewController setIsTransitioning:YES];
    [previousViewController willMoveToParentViewController:nil];
    [tabBarViewController addChildViewController:destinationViewController];
    
    CGFloat animationOffset = previousViewController.view.frame.size.width;
    if ([self animationDirection] == MHTabBarSegueAnimationDirectionRight) {
        animationOffset = -animationOffset;
    }
    
    CGRect inFrame = CGRectMake(previousViewController.view.frame.origin.x - animationOffset, previousViewController.view.frame.origin.y, previousViewController.view.frame.size.width, previousViewController.view.frame.size.height);
    CGRect outFrame = CGRectMake(previousViewController.view.frame.origin.x + animationOffset, previousViewController.view.frame.origin.y, previousViewController.view.frame.size.width, previousViewController.view.frame.size.height);
    
    destinationViewController.view.frame = inFrame;
    
    [tabBarViewController transitionFromViewController: previousViewController toViewController: destinationViewController
                              duration: 0.25 options:UIViewAnimationOptionCurveEaseOut
                            animations:^{
                                destinationViewController.view.frame = previousViewController.view.frame;
                                previousViewController.view.frame = outFrame;
                            }
                            completion:^(BOOL finished) {
                                [previousViewController removeFromParentViewController];
                                [destinationViewController didMoveToParentViewController:tabBarViewController];
                                [tabBarViewController setIsTransitioning:NO];
                            }];
}

@end

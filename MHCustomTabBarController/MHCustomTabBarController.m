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

#import "MHCustomTabBarController.h"

#import "MHTabBarSegue.h"

@implementation MHCustomTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectedIndex = -1;
    
    _viewControllersByIdentifier = [NSMutableDictionary dictionary];
    
    if (self.childViewControllers.count < 1) {
        [self setSelectedIndex:0];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.destinationViewController.view.frame = self.container.bounds;
    
    [[[self destinationViewController] view] layoutSubviews];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.destinationViewController.view.frame = self.container.bounds;
    
    [[[self destinationViewController] view] layoutSubviews];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (selectedIndex != [self selectedIndex]) {
        _selectedIndex = selectedIndex;
        
        [self performSegueWithIdentifier:[NSString stringWithFormat:@"viewController%d", selectedIndex] sender:[self.buttons objectAtIndex:selectedIndex]];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated
{
    _animateNextTransition = animated;
    [self setSelectedIndex:selectedIndex];
}

#pragma mark - Segue
- (void)loadViewControllerForSeguegue:(MHTabBarSegue *)segue triggeredWithButton:(UIButton *)button {
    self.oldViewController = self.destinationViewController;
    
    //if view controller isn't already contained in the viewControllers-Dictionary
    if (![_viewControllersByIdentifier objectForKey:segue.identifier]) {
        [_viewControllersByIdentifier setObject:segue.destinationViewController forKey:segue.identifier];
    }
    
    for (UIButton *aButton in self.buttons) {
        [aButton setSelected:NO];
    }
    
    NSInteger previousSelectedIndex = _selectedIndex;
    _selectedIndex = [[self buttons] indexOfObject:button];
    
    if (previousSelectedIndex < [self selectedIndex]) {
        [segue setAnimationDirection:MHTabBarSegueAnimationDirectionRight];
    } else {
        [segue setAnimationDirection:MHTabBarSegueAnimationDirectionLeft];
    }
    
    [button setSelected:YES];
    self.destinationIdentifier = segue.identifier;
    self.destinationViewController = [_viewControllersByIdentifier objectForKey:self.destinationIdentifier];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (![segue isKindOfClass:[MHTabBarSegue class]]) {
        [super prepareForSegue:segue sender:sender];
        return;
    }
    
    UIButton *button = (UIButton *)sender;
    
    [self loadViewControllerForSeguegue:segue triggeredWithButton:button];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self.destinationIdentifier isEqual:identifier] || [self isTransitioning]) {
        //Dont perform segue, if visible ViewController is already the destination ViewController
        return NO;
    }
    
    return YES;
}

- (void)setIsTransitioning:(BOOL)isTransitioning
{
    _isTransitioning = isTransitioning;
    
    _animateNextTransition = YES;
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [[_viewControllersByIdentifier allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if (![self.destinationIdentifier isEqualToString:key]) {
            [_viewControllersByIdentifier removeObjectForKey:key];
        }
    }];
}

@end

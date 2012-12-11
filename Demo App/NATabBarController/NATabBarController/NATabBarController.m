//
//  NATabBarController.m
//  NATabBarController
//
//  Created by Nihal Ahmed on 12-11-10.
//  Copyright (c) 2012 Nihal Ahmed. All rights reserved.
//

#import "NATabBarController.h"

static int NATabBarControllerKVOContext;

@interface NATabBarController ()

@property (nonatomic, strong) NSArray *originalViewControllers;

@end

@implementation NATabBarController

@synthesize originalViewControllers = _originalViewControllers;
@synthesize tabBarView = _tabBarView;

// Initializes and returns a newly allocated NATabBarController object with the specified view controllers, portrait height and style
- (id)initWithViewControllers:(NSArray *)array tabBarHeight:(float)height
{
    self = [super init];
    if (self) {
        // Store the view controllers
        [self setOriginalViewControllers:array];
        
        // Add the tab bar
        NATabBar *tabBarView = [[NATabBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height) delegate:self];
        [self.view addSubview:tabBarView];
        _tabBarView = tabBarView;
        
        // Set the first view controller as the only view controller (this is to suppress the More Navigation Controller)
        if(array.count > 0) {
            [self setViewControllers:[NSArray arrayWithObject:[array objectAtIndex:0]]];            
        }
        
        // Hide the original tab bar
        [self.tabBar setAlpha:0];
        
        // Listen to changes in the original tab bar's frame and hidden values
        [self.tabBar addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:&NATabBarControllerKVOContext];
        [self.tabBar addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:&NATabBarControllerKVOContext];
    }
    return self;
}

// By default, auto-rotate to all interface orientations
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#ifdef __IPHONE_6_0
// By default, should auto-rotate
- (BOOL)shouldAutorotate
{
    return YES;
}

// By default, auto-rotate to all interface orientations
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
#endif

// Position the tab bar and content view appropriately
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Set the tab bar height according to the orientation
    float tabBarViewHeight;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        tabBarViewHeight = self.tabBarView.landscapeHeight;
    }
    else {
        tabBarViewHeight = self.tabBarView.portraitHeight;
    }
    
    [self.tabBar setFrame:CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y + self.tabBar.frame.size.height - tabBarViewHeight, self.tabBar.frame.size.width, tabBarViewHeight)];
    
    // Adjust the content view height according to the tab bar height
    UIView *view = [self.view.subviews objectAtIndex:0];
    if(view.frame.size.height != self.tabBar.frame.origin.y + self.tabBar.frame.size.height) {
        [view setFrame:CGRectMake(0, 0, view.frame.size.width, self.tabBar.frame.origin.y)];
    }
}

// Sets the height of the tab bar in landscape mode
- (void)setTabBarLandscapeHeight:(float)height
{
    [self.tabBarView setLandscapeHeight:height];
}

// Selects the view controller at the specified index
- (void)setSelectedTabIndex:(NSUInteger)selectedIndex
{
    if(selectedIndex > self.originalViewControllers.count - 1) return;
    
    UIViewController *selectedViewController = [self.originalViewControllers objectAtIndex:selectedIndex];
    [self.tabBarView setSelectedIndex:selectedIndex];
    [self setViewControllers:[NSArray arrayWithObject:selectedViewController]];
}

// Selects the specified view controller
- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    if([self.viewControllers containsObject:selectedViewController]) return;
    
    for(UIViewController *viewController in self.originalViewControllers) {
        if(viewController == selectedViewController) {
            [self.tabBarView setSelectedIndex:[self.originalViewControllers indexOfObject:viewController]];
            [self setViewControllers:[NSArray arrayWithObject:selectedViewController]];
            break;
        }
    }
}

// Asks the delegate if the tab at the specified index can be selected
- (BOOL)shouldSelectTabAtIndex:(int)index
{
    UIViewController *selectedViewController = [self.originalViewControllers objectAtIndex:index];
    if([self.delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        return [self.delegate tabBarController:self shouldSelectViewController:selectedViewController];
    }
    return YES;
}

// Notifies the delegate that the tab at the specified index was selected
- (void)tabBarDidSelectTabAtIndex:(int)index
{
    UIViewController *selectedViewController = [self.originalViewControllers objectAtIndex:index];
    
    if([self.viewControllers containsObject:selectedViewController]) {
        if([selectedViewController isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)selectedViewController popToRootViewControllerAnimated:YES];
        }
    }
    else {
        [self setViewControllers:[NSArray arrayWithObject:selectedViewController]];
        
        if([self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
            [self.delegate tabBarController:self didSelectViewController:selectedViewController];
        }        
    }
}

// Called when the original tab bar's frame and hidden values change
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context != &NATabBarControllerKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if([keyPath isEqualToString:@"frame"]) {
        [self.tabBar setAlpha:0];
        [self.tabBarView setFrame:self.tabBar.frame];
    }
    else if([keyPath isEqualToString:@"hidden"]) {
        [self.tabBarView setHidden:self.tabBar.hidden];
    }
}

// Clean up
- (void)dealloc
{
    // Stop listening to changes in the original tab bar's frame and hidden values
    [self.tabBar removeObserver:self forKeyPath:@"frame" context:&NATabBarControllerKVOContext];
    [self.tabBar removeObserver:self forKeyPath:@"hidden" context:&NATabBarControllerKVOContext];
}

@end

//
//  NATabBarController.h
//  NATabBarController
//
//  Created by Nihal Ahmed on 12-11-10.
//  Copyright (c) 2012 Nihal Ahmed. All rights reserved.
//

#import "NATabBar.h"

@interface NATabBarController : UITabBarController <NATabBarDelegate>

// Initializes and returns a newly allocated NATabBarController object with the specified view controllers and portrait height
- (id)initWithViewControllers:(NSArray *)array tabBarHeight:(float)height;

// Sets the height of the tab bar in landscape mode
- (void)setTabBarLandscapeHeight:(float)height;

// Selects the view controller at the specified index
- (void)setSelectedTabIndex:(NSUInteger)selectedIndex;

@property (nonatomic, assign, readonly) NATabBar *tabBarView;

@end

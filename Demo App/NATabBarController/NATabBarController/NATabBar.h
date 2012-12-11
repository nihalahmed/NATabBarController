//
//  NATabBar.h
//  NATabBarController
//
//  Created by Nihal Ahmed on 12-11-10.
//  Copyright (c) 2012 Nihal Ahmed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NATabBarItem.h"

// NATabBarDelegate protocol
@protocol NATabBarDelegate <NSObject>

// Returns the view controllers passed to the tab bar controller
- (NSArray *)originalViewControllers;

// Asks the delegate if the tab at the specified index can be selected
- (BOOL)shouldSelectTabAtIndex:(int)index;

// Notifies the delegate that the tab at the specified index was selected
- (void)tabBarDidSelectTabAtIndex:(int)index;

@end

@interface NATabBar : UIView {
    __weak UIView *_containerView;
    __weak UIScrollView *_moreContainerView;
    __weak UIImageView *_backgroundImageView;
    __weak UIButton *_moreBtn;
    NSMutableArray *_btns;
    float _moreContainerViewWidth;
    BOOL _expanded;
}

// Initializes and returns a newly allocated NATabBar object with the specified frame and delegate
- (id)initWithFrame:(CGRect)frame delegate:(id <NATabBarDelegate>)delegate;

// Selects the view controller at the specified index
- (void)setSelectedIndex:(int)selectedIndex;

// Sets the background image of the tab bar
- (void)setBackgroundImage:(UIImage *)image;

// Sets the background image of each tab in the tab bar when it is selected
- (void)setTabSelectedBackgroundImage:(UIImage *)image;

// Sets the image of the more tab when it is in normal and selected state
- (void)setMoreTabImage:(UIImage *)image selectedImage:(UIImage *)selectedImage;

@property (nonatomic, assign) id <NATabBarDelegate> delegate;
@property (nonatomic, assign) float portraitHeight;
@property (nonatomic, assign) float landscapeHeight;

@end

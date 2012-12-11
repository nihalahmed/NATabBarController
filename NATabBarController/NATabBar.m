//
//  NATabBar.m
//  NATabBarController
//
//  Created by Nihal Ahmed on 12-11-10.
//  Copyright (c) 2012 Nihal Ahmed. All rights reserved.
//

#import "NATabBar.h"

#define kMoreBtnTag -1
static int NATabBarKVOContext;

@implementation NATabBar

@synthesize delegate = _delegate;
@synthesize portraitHeight = _portraitHeight;
@synthesize landscapeHeight = _landscapeHeight;

// Initializes and returns a newly allocated NATabBar object with the specified frame, style and delegate
- (id)initWithFrame:(CGRect)frame delegate:(id <NATabBarDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setClipsToBounds:NO];
        [self setBackgroundColor:[UIColor blackColor]];
        [self setDelegate:delegate];
        [self setPortraitHeight:self.frame.size.height];
        [self setLandscapeHeight:self.frame.size.height];
        
        // Array to hold all tabs
        _btns = [[NSMutableArray alloc] init];
        
        // Tab container view
        UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
        [containerView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:containerView];
        _containerView = containerView;
        
        // Tab container background
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:containerView.bounds];
        [backgroundImageView setImage:[UIImage imageNamed:@"TabBarBG.png"]];
        [containerView addSubview:backgroundImageView];
        _backgroundImageView = backgroundImageView;
        
        // Setup tabs for each view controller
        [self setupTabs];
        
        // Listen to changes in the frame value to update layout of the tabs
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:&NATabBarKVOContext];
    }
    return self;
}

// Adds tabs for the view controllers passed to the tab bar controller
- (void)setupTabs
{
    if(![self.delegate respondsToSelector:@selector(originalViewControllers)]) return;
    
    // Get all view controllers
    NSArray *viewControllers = [self.delegate originalViewControllers];
    if(!viewControllers) return;
    
    // Check if more button is required
    int moreTabIndex = [self maximumNumberOfColumns] - 1;
    BOOL showMoreBtn = (viewControllers.count > [self maximumNumberOfColumns]);
    BOOL didAddMoreTab = NO;
    
    // Loop through the view controllers and add a tab for each
    for(int i = 0, j = 0; i < viewControllers.count; i++) {
        // Add a more tab if required
        if(j == moreTabIndex && showMoreBtn && !didAddMoreTab) {
            [self addMoreTab];
            didAddMoreTab = YES;
            j++;
            i--;
            continue;
        }
        
        // Get the title and images from the view controller
        UIViewController *viewController = [viewControllers objectAtIndex:i];
        UITabBarItem *tabBarItem = viewController.tabBarItem;
        NSString *title = tabBarItem.title;
        UIImage *normalImage = tabBarItem.finishedUnselectedImage;
        UIImage *selectedImage = tabBarItem.finishedSelectedImage;
        if(!normalImage) normalImage = tabBarItem.image;
        if(!selectedImage) selectedImage = normalImage;
        UIImage *selectedBackgroundImage = [UIImage imageNamed:@"TabBarSelectedButtonBackground.png"];
        
        // Set up the tab
        NATabBarItem *btn = [NATabBarItem buttonWithType:UIButtonTypeCustom];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setImage:normalImage forState:UIControlStateNormal];
        [btn setImage:selectedImage forState:UIControlStateHighlighted];
        [btn setImage:selectedImage forState:UIControlStateSelected];
        [btn setImage:selectedImage forState:UIControlStateHighlighted | UIControlStateSelected];
        [btn setBackgroundImage:selectedBackgroundImage forState:UIControlStateHighlighted];
        [btn setBackgroundImage:selectedBackgroundImage forState:UIControlStateSelected];
        [btn setBackgroundImage:selectedBackgroundImage forState:UIControlStateHighlighted | UIControlStateSelected];
        [btn setTag:i];
        [btn becomeObserverForObject:tabBarItem];
        [btn addTarget:self action:@selector(tabTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        if(j > moreTabIndex && showMoreBtn) {
            [btn setIsInMoreMenu:YES];
            [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [_moreContainerView addSubview:btn];
            
            float w = [title sizeWithFont:btn.titleLabel.font].width + 44 + 10;
            _moreContainerViewWidth = fminf(self.frame.size.width/2, fmaxf(_moreContainerViewWidth, w));
        }
        else {
            [_containerView addSubview:btn];
        }
        
        [_btns addObject:btn];
        
        // Select the first tab by default
        if(i == 0) {
            [btn setSelected:YES];
        }
        
        j++;
    }
    
    // Update the layout of all the tabs
    [self updateLayout];
}

// Adds the more tab to the tab bar
- (void)addMoreTab
{
    NSString *normalImageName = @"TabBarMore.png";
    NSString *selectedImageName = @"TabBarMore.png";
    
    UIImage *normalImage = [UIImage imageNamed:normalImageName];
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
    if(!selectedImage) selectedImage = normalImage;
    UIImage *selectedBackgroundImage = [UIImage imageNamed:@"TabBarSelectedButtonBackground.png"];
    
    NATabBarItem *btn = [NATabBarItem buttonWithType:UIButtonTypeCustom];
    [btn setImage:normalImage forState:UIControlStateNormal];
    [btn setImage:selectedImage forState:UIControlStateHighlighted];
    [btn setImage:selectedImage forState:UIControlStateSelected];
    [btn setImage:selectedImage forState:UIControlStateHighlighted | UIControlStateSelected];
    [btn setBackgroundImage:selectedBackgroundImage forState:UIControlStateHighlighted];
    [btn setBackgroundImage:selectedBackgroundImage forState:UIControlStateSelected];
    [btn setBackgroundImage:selectedBackgroundImage forState:UIControlStateHighlighted | UIControlStateSelected];
    [btn setTag:kMoreBtnTag];
    [btn addTarget:self action:@selector(moreTabTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:btn];
    [_btns addObject:btn];
    _moreBtn = btn;
    
    // Add more tabs container view
    UIScrollView *moreContainerView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [moreContainerView setBackgroundColor:[UIColor blackColor]];
    [moreContainerView setAlpha:0];
    [self addSubview:moreContainerView];
    _moreContainerView = moreContainerView;
}

// Updates the layout of all the tabs
- (void)updateLayout
{
    if(_btns.count == 0) return;
    
    int numColumns = MIN(_btns.count, [self maximumNumberOfColumns]);
    int moreTabIndex = [self maximumNumberOfColumns] - 1;
    float contentWidth = self.frame.size.width;
    float buttonWidth = contentWidth/numColumns;
    float buttonHeight = self.frame.size.height;
    float moreContainerHeight = 44 * 5;
    float moreContainerContentHeight = 0;
    
    for(int i = 0; i < _btns.count; i++) {
        UIButton *btn = [_btns objectAtIndex:i];
        
        float x, y;
        
        if(i > moreTabIndex && _moreBtn) {
            x = 0;
            y = 44 * (i - moreTabIndex - 1);
            buttonWidth = _moreContainerViewWidth;
            buttonHeight = 44;
            moreContainerContentHeight += 44;
        }
        else {
            x = buttonWidth * i;
            y = 0;
        }
        
        [btn setFrame:CGRectMake(x, y, buttonWidth, buttonHeight)];
    }
    
    moreContainerHeight = fminf(moreContainerHeight, moreContainerContentHeight);
    [_containerView setFrame:self.bounds];
    [_backgroundImageView setFrame:self.bounds];
    [_moreContainerView setFrame:CGRectMake(self.frame.size.width - _moreContainerViewWidth, -moreContainerHeight, _moreContainerViewWidth, moreContainerHeight)];
    [_moreContainerView setContentSize:CGSizeMake(_moreContainerViewWidth, moreContainerContentHeight)];
}

// Called when the more tab is selected
- (void)moreTabTapped:(UIButton *)sender
{
    // Expand or collapse the tab bar
    [self toggleMore];
}

// Called when a tab is selected
- (void)tabTapped:(UIButton *)sender
{
    if([self.delegate respondsToSelector:@selector(shouldSelectTabAtIndex:)]) {
        if(![self.delegate shouldSelectTabAtIndex:sender.tag]) return;
    }
    
    [self collapse];
    
    for(UIButton *btn in _btns) {
        if(btn == sender) {
            [btn setSelected:YES];
        }
        else {
            [btn setSelected:NO];
        }
    }
    
    int maxFirstRowIndex = [self maximumNumberOfColumns] - 2;
    
    // If selected tab is not in the first row, select the more tab as well
    if(sender.tag > maxFirstRowIndex && _moreBtn) {
        [_moreBtn setTag:sender.tag];
        [_moreBtn setSelected:YES];
    }
    else {
        [_moreBtn setTag:kMoreBtnTag];
        [_moreBtn setSelected:NO];
    }
    
    if([self.delegate respondsToSelector:@selector(tabBarDidSelectTabAtIndex:)]) {
        [self.delegate tabBarDidSelectTabAtIndex:sender.tag];
    }
}

// Toggles the expanded/collapsed state of the tab bar
- (void)toggleMore
{
    (_expanded) ? [self collapse] : [self expand];
}

// Expands the tab bar to show all the rows
- (void)expand
{
    _expanded = YES;
    [_moreBtn setSelected:YES];
    [UIView animateWithDuration:0.25 animations:^{
        [_moreContainerView setAlpha:1];
    } completion:^(BOOL finished) {
        [_moreContainerView flashScrollIndicators];
    }];
}

// Collapses the tab bar to show only the first row
- (void)collapse
{
    _expanded = NO;
    if(_moreBtn.tag == kMoreBtnTag) [_moreBtn setSelected:NO];
    [UIView animateWithDuration:0.25 animations:^{
        [_moreContainerView setAlpha:0];
    }];
}

// Selects the view controller at the specified index
- (void)setSelectedIndex:(int)selectedIndex
{
    for(UIButton *btn in _btns) {
        if(btn == _moreBtn) continue;
        
        if(btn.tag == selectedIndex) {
            [self tabTapped:btn];
            break;
        }
    }
}

// Sets the background image of the tab bar
- (void)setBackgroundImage:(UIImage *)image
{
    [_backgroundImageView setImage:image];
}

// Sets the background image of each tab in the tab bar when it is selected
- (void)setSelectedTabBackgroundImage:(UIImage *)image
{
    for(UIButton *btn in _btns) {
        [btn setBackgroundImage:image forState:UIControlStateHighlighted];
        [btn setBackgroundImage:image forState:UIControlStateSelected];
        [btn setBackgroundImage:image forState:UIControlStateHighlighted | UIControlStateSelected];
    }
}

// Sets the image of the more tab when it is in normal and selected state
- (void)setMoreTabImage:(UIImage *)image selectedImage:(UIImage *)selectedImage
{
    if(!selectedImage) selectedImage = image;
    
    [_moreBtn setImage:image forState:UIControlStateNormal];
    [_moreBtn setImage:selectedImage forState:UIControlStateHighlighted];
    [_moreBtn setImage:selectedImage forState:UIControlStateSelected];
    [_moreBtn setImage:selectedImage forState:UIControlStateHighlighted | UIControlStateSelected];
}

// Returns the maximum number of tabs allowed per row
- (int)maximumNumberOfColumns
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 9;
    }
    return 5;
}

// Called when the frame value or badge value changes
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context != &NATabBarKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if([keyPath isEqualToString:@"frame"]) {
        [self performSelector:@selector(updateLayout) withObject:nil afterDelay:0];
    }
}

// If touch is within the tab bar's bounds consume it, otherwise collapse tab bar and call super
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if(CGRectContainsPoint(self.bounds, point) ||
       (_expanded && CGRectContainsPoint(_moreContainerView.frame, point))) {
        return YES;
    }
    else {
        [self collapse];
    }
    
    return [super pointInside:point withEvent:event];
}

// Clean up
- (void)dealloc
{
    // Stop listening to changes in the frame value
    [self removeObserver:self forKeyPath:@"frame" context:&NATabBarKVOContext];
}

@end

//
//  NATabBarItem.m
//  NATabBarController
//
//  Created by Nihal Ahmed on 12-11-12.
//  Copyright (c) 2012 NABZ Software. All rights reserved.
//

#import "NATabBarItem.h"

static int NATabBarItemKVOContext;

#ifdef __IPHONE_6_0
#define TextAlignmentCenter NSTextAlignmentCenter
#define LineBreakTruncatingTail NSLineBreakByTruncatingTail
#else
#define TextAlignmentCenter UITextAlignmentCenter
#define LineBreakTruncatingTail UILineBreakModeTailTruncation
#endif

@implementation NATabBarItem

@synthesize isInMoreMenu = _isInMoreMenu;
@synthesize observedObject = _observedObject;

// Initializes and returns a newly allocated NATabBarItem object with the specified frame
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self.titleLabel setTextAlignment:TextAlignmentCenter];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [self.titleLabel setLineBreakMode:LineBreakTruncatingTail];
        [self.imageView setContentMode:UIViewContentModeCenter];
        [self.imageView setClipsToBounds:NO];
    }
    return self;
}

// Position the image and title appropriately
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // If the item is in the more menu, position the title to the right of the image
    if(self.isInMoreMenu) {
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [self.imageView setCenter:CGPointMake(self.frame.size.height/2, self.frame.size.height/2)];
        [self.titleLabel setFrame:CGRectMake(self.frame.size.height, self.titleLabel.frame.origin.y, self.frame.size.width - self.frame.size.height, self.titleLabel.frame.size.height)];
        return;
    }
    
    // If tab bar height is <= 32px, center the image and hide the title
    if(self.frame.size.height <= 32) {
        [self.imageView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
        [self.titleLabel setHidden:YES];
    }
    
    // Center both the image and title
    else {
        [self.imageView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2 - self.titleLabel.frame.size.height/2)];
        [self.titleLabel setFrame:CGRectMake(0, self.frame.size.height - self.titleLabel.frame.size.height, self.frame.size.width, self.titleLabel.frame.size.height)];
    }
}

// Set the badge value or remove badge badgeValue is nil
- (void)setBadgeValue:(NSString *)badgeValue
{
    BOOL showBadge = (badgeValue && badgeValue != (NSString *)[NSNull null]);
    if(showBadge && badgeValue.length > 0) {
        if(!_badge) {
            UIButton *badge = [UIButton buttonWithType:UIButtonTypeCustom];
            [badge setUserInteractionEnabled:NO];
            [badge setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
            [badge.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
            [badge setTitleEdgeInsets:UIEdgeInsetsMake(-5, 0, 0, 0)];
            [badge setBackgroundImage:[[UIImage imageNamed:@"UIButtonBarBadge.png"] stretchableImageWithLeftCapWidth:11.5 topCapHeight:11] forState:UIControlStateNormal];
            [self addSubview:badge];
            _badge = badge;
        }
        
        float width = [badgeValue sizeWithFont:_badge.titleLabel.font].width;
        width = fminf(width, self.frame.size.width - 16) + 16;
        [_badge setFrame:CGRectMake(self.frame.size.width - width, 1, width, 23)];
        [_badge setTitle:badgeValue forState:UIControlStateNormal];
    }
    else {
        [_badge removeFromSuperview];
        _badge = nil;
    }
}

// Observe for changes in the badge value
- (void)becomeObserverForObject:(id)object
{
    [object addObserver:self forKeyPath:@"badgeValue" options:NSKeyValueObservingOptionNew context:&NATabBarItemKVOContext];
    [self setObservedObject:object];
}

// Called when the frame value or badge value changes
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(context != &NATabBarItemKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if([keyPath isEqualToString:@"badgeValue"]) {
        // Find the view controller to update the badge value
        [self setBadgeValue:[change objectForKey:NSKeyValueChangeNewKey]];
    }
}

// Clean up
- (void)dealloc
{
    // Stop listening to changes in the frame value
    [self.observedObject removeObserver:self forKeyPath:@"badgeValue" context:&NATabBarItemKVOContext];
}

@end

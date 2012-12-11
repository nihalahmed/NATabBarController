NATabBarController
=========================

NATabBarController is a fully customizable subclass of UITabBarController with additional features.

Features
--------

- Full customizable look
- A popup menu replacement for the 'More Navigation Controller'
- Different tab bar height for portrait and landscape
- Uses the default UITabBarControllerDelegate
- Supported on iPhone and iPad with iOS 5 onwards
- Requires ARC

Installation
------------

1. Add the `NATabBarController` folder to your Xcode project

2. Import the `NATabBarController.h` file

Usage
-----

Usage is similar to that of a typical UITabBarController. NATabBarController will use the titles and images specified in the `tabBarItem` property of each view controller.

You can also specify a different height for the tab bar when in landscape mode.

<pre>
    self.tabBarController = [[NATabBarController alloc] initWithViewControllers:viewControllers tabBarHeight:44];
    [self.tabBarController setTabBarLandscapeHeight:32];
</pre>


Customization
-------------

To customize the look of the tab bar, access the `tabBarView` property of NATabBarController and use the following methods:

<pre>
    - (void)setBackgroundImage:(UIImage *)image
    - (void)setSelectedTabBackgroundImage:(UIImage *)image
    - (void)setMoreTabImage:(UIImage *)image selectedImage:(UIImage *)selectedImage
</pre>
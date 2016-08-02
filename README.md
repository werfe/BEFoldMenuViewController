# BEFoldMenuViewController
<img src="https://github.com/werfe/BEFoldMenuViewController/blob/master/BEFoldMenuViewControllerDemo/images/captureAnimation.gif?raw=true" width="320">

Description
--------------

# Table of Contents
1. [Features](#features)
3. [Installation](#installation)
4. [Supported versions](#supported-versions)
5. [Usage](#usage)
6. [Attributes](#attributes)
8. [Public interface](#public-interface)
9. [License](#license)
10. [Contact](#contact)

##<a name="features"> Features </a>
- [x] Easy to use, easy to customize.
- [x] Automatic orientation change adjustments.
- [x] Storyboard and xib support.


<a name="installation"> Installation </a>
--------------
* via werfe: github "werfe/BEFoldMenuViewController".
* or copy BEFoldMenuViewController folder to your project.


<a name="supported-versions"> Supported Versions </a>
-----------------------------

* iOS 7.0 or later

<a name="usage"> Usage </a>
--------------

### Programmatically

In `AppDelegate.m` add some codes below inside `didFinishLaunchingWithOptions` function

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //... init homeVC, leftMenu and rightMenu
    
    BEFoldMenuViewController *foldMenu = [[BEFoldMenuViewController alloc] init];
    [foldMenu.view setFrame:[UIScreen mainScreen].bounds];
    foldMenu.topViewController = _leftMenu;
    foldMenu.leftViewController = _homeVC;
    foldMenu.rightViewController = _rightMenu ;
    foldMenu.delegate = _leftMenu;
    return YES;
}
```

### Using Storyboard segue
**Step 1.** In the storyboard file, choose view controller that you want to have left/right menu effect then change this custom class to `BEFoldMenuViewController`.

**Step 2.** Add three custom segues from the `Fold Menu View Controller` scene, one for the center view controller, one for the left menu view controller and the other for the right menu view controller. 

Remember to set all the appropriate attributes of each segue in the Attributes Inspector like that:

![Example](https://github.com/werfe/BEFoldMenuViewController/blob/master/BEFoldMenuViewControllerDemo/images/segueSetup.png?raw=true)


<a name="attributes"> Attributes </a>
--------------

| Attribute for drawing  |  Value |      Description      |
|----------|-----|-----------------------------|
|`mainViewController`| UIViewController | The center view controller.|
|`leftViewController`| UIViewController | The under left view controller. After setup this attribute, if it not equal `nil`, value of `leftMenuEnabled` is automatically set to YES.|
|`rightViewController`| UIViewController | The under right view controller. After setup this attribute, if it not equal `nil`, value of `rightMenuEnabled` is automatically set to YES.|
|`menuState`| BSMenuState |  Readonly attribute, it returns state of menu include: left menu is showing, right menu is showing or main view is showing.|
|`isDragging`| BOOL |  Readonly attribute, it returns YES when user dragging and returns NO when user release their finger.|
|`topShadowColor`| UIColor | Drop shadow color of main view. |
|`topShadowWidth`| CGFloat | Drop shadow width of main view. |
|`topShadowOpacity`| CGFloat | Drop shadow opacity of main view. |
|`animationDuration`| CGFloat | Duration for animation show/hide menu. |



| Attribute for Left menu  | Value  |      Description      |
|----------|-------------|------|
|`leftMenuEnabled`| BOOL | Boolean flag, support enable or disable show left menu.|
|`leftMenuWidth`| CGFloat | The width of left menu. |
|`foldEffeectEnabled`| BOOL | Boolean flag, support enable or disable fold effect of left menu. |


| Attribute for Right menu  | Value  |      Description      |
|----------|-------------|------|
|`rightMenuEnabled`| BOOL | Boolean flag, support enable or disable show right menu.|
|`rightMenuWidth`| CGFloat | The width of right menu. |

| Attribute for Storyboard  | Value  |      Description      |
|----------|-------------|------|
|`mainSegueIdentifier`| NSString | Identifier for custom segue of Storyboard. Use this attribute for project using Storyboar. |
|`leftSegueIdentifier`| NSString | Identifier for custom segue of Storyboard. Use this attribute for project using Storyboar. |
|`rightSegueIdentifier`| NSString | Identifier for custom segue of Storyboard. Use this attribute for project using Storyboar. |


<a name="public-interface"> Public interface </a>
--------------

###Delegate

The methods declared by the BEFoldMenuDelegate protocol allow the adopting delegate to respond to messages from the BEFoldMenuViewController class and thus respond to, and in some affect, operations such as dragging,show, hide and slide animations.

```objective-c
-(void)foldMenuControllerWillBeginDragging:(UIViewController*) foldMenuController;
-(void)foldMenuControllerWillEndDragging:(UIViewController*) foldMenuController;
-(void)foldMenuControllerDidEndDragging:(UIViewController*) foldMenuController;
-(void)foldMenuControllerWillStartAnimation:(UIViewController*) foldMenuController duration:(CGFloat) duration;
-(void)foldMenuControllerDidEndAnimation:(UIViewController*) foldMenuController;


//Left menu
-(void)foldMenuController:(UIViewController*) foldMenuController didShowLeftMenu:(UIViewController*) leftMenuController;
//Right menu
-(void)foldMenuController:(UIViewController*) foldMenuController didShowRighMenu:(UIViewController*) leftMenuController;
//Hide menu
-(void)foldMenuControllerDidHideMenu:(UIViewController*) foldMenuController;
```


###Public methods

BEFoldMenuViewController support two method for show/hide left or right menu with animation:

```objective-c
-(void)leftMenuAction;
-(void)rightMenuAction;
```


<a name="license"> License </a>
--------------

```BEFoldMenuViewController``` is developed by Vũ Trường Giang (aka Werfe) and is released under the MIT license. See the ```LICENSE``` file for more details.

In my Sample project, background image is downloaded from [ilikewallpaper](http://www.ilikewallpaper.net/) and [Pinterest](www.pinterest.com). Thanks.

<a name="contact"> Contact </a>
--------------

You can contact me at email adress werfeee@gmail.com. If you find any issues on the project, you can open a ticket. Pull requests are also welcome.

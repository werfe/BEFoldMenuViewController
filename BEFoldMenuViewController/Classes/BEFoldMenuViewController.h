//
//  BEFoldMenuViewController.h
//  vozForums
//
//  Created by Vũ Trường Giang on 7/21/16.
//  Copyright © 2016 Vũ Trường Giang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEFAULT_MAIN_SEGUE_IDENTIFIER @"mainSegueIdentifier"
#define DEFAULT_LEFT_SEGUE_IDENTIFIER @"leftSegueIdentifier"
#define DEFAULT_RIGHT_SEGUE_IDENTIFIER @"rightSegueIdentifier"

typedef NS_ENUM(NSUInteger, BSMenuState) {
    BSMenuStateLeftOpen,
    BSMenuStateRightOpen,
    BSMenuStateCenterOpen,
};

@protocol BEFoldMenuDelegate;

@interface BEFoldMenuViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) UIViewController *mainViewController;

@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, assign) BOOL leftMenuEnabled;
@property (nonatomic, assign) BOOL foldEffeectEnabled;
@property (nonatomic, assign) CGFloat leftMenuWidth;

@property (nonatomic, strong) UIViewController *rightViewController;
@property (nonatomic, assign) BOOL rightMenuEnabled;
@property (nonatomic, assign) CGFloat rightMenuWidth;

@property (nonatomic, weak) id<BEFoldMenuDelegate> delegate;

@property (nonatomic, assign, readonly ) BSMenuState menuState;
@property (nonatomic, assign, readonly) BOOL isDragging;

@property (nonatomic, strong) UIColor *topShadowColor;
@property (nonatomic, assign) CGFloat topShadowWidth;
@property (nonatomic, assign) CGFloat topShadowOpacity;

@property (nonatomic, assign) CGFloat animationDuration;


//Properties for support Storyboard
@property (nonatomic,copy) NSString *mainSegueIdentifier;
@property (nonatomic,copy) NSString *leftSegueIdentifier;
@property (nonatomic,copy) NSString *rightSegueIdentifier;


-(void)leftMenuAction;
-(void)rightMenuAction;

@end

#pragma mark - BEFoldMenuDelegate
@protocol BEFoldMenuDelegate <NSObject>
//
-(void)foldMenuControllerWillBeginDragging:(UIViewController*) foldMenuController;
-(void)foldMenuControllerWillEndDragging:(UIViewController*) foldMenuController;
-(void)foldMenuControllerDidEndDragging:(UIViewController*) foldMenuController;
-(void)foldMenuControllerWillStartAnimation:(UIViewController*) foldMenuController duration:(CGFloat) duration;
-(void)foldMenuControllerDidEndAnimation:(UIViewController*) foldMenuController;


//Left
-(void)foldMenuController:(UIViewController*) foldMenuController didShowLeftMenu:(UIViewController*) leftMenuController;
//Right
-(void)foldMenuController:(UIViewController*) foldMenuController didShowRighMenu:(UIViewController*) leftMenuController;
//Hide
-(void)foldMenuControllerDidHideMenu:(UIViewController*) foldMenuController;
@end

#pragma mark - UIViewController Extension
@interface UIViewController (FoldMenuController)

-(BEFoldMenuViewController*)foldMenuController;

@end

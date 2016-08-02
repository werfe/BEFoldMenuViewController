//
//  BEFoldMenuViewController.m
//  vozForums
//
//  Created by Vũ Trường Giang on 7/21/16.
//  Copyright © 2016 Vũ Trường Giang. All rights reserved.
//

#import "BEFoldMenuViewController.h"
#import "UIView+Frame.h"

#define FOLD_OPACITY_MAXIMUM 0.3f

#define DEFAULT_LEFT_MENU_WIDTH 200.0f
#define DEFAULT_RIGHT_MENU_WIDTH 200.0f

#define SCREEN_WIDTH    CGRectGetWidth([UIScreen mainScreen].bounds)
#define SCREEN_HEIGHT   CGRectGetHeight([UIScreen mainScreen].bounds)

#define DEFAULT_TOP_SHADOW_WIDTH 5.0f
#define DEFAULT_TOP_SHADOW_COLOR [UIColor blackColor]
#define DEFAULT_TOP_SHADOW_OPACITY 0.6f

#define DEFAULT_ANIMATION_DURATION 0.2f

#define IS_IOS_7_OR_LESS ([[UIDevice currentDevice].systemVersion floatValue] <8.0)?YES:NO

@interface BEFoldMenuViewController ()

@property (nonatomic, assign, readwrite ) __block BSMenuState menuState;
@property (nonatomic, assign, readwrite) __block BOOL isDragging;

//Properties for fold left menu
@property (nonatomic, assign) CATransform3D transform3DEffect;
@property (nonatomic, strong) CALayer *topSleeve;
@property (nonatomic, strong) CALayer *middleSleeve;
@property (nonatomic, strong) CALayer *middleShadow;
@property (nonatomic, strong) CALayer *firstJointLayer;
@property (nonatomic, strong) CALayer *secondJointLayer;
@property (nonatomic, strong) CALayer *perspectiveLayer;

@property (nonatomic, strong) UIView *overlayPerspectiveView;

@property (nonatomic, strong) UIView *overlayMainView;

@end

@implementation BEFoldMenuViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializeData];
    if (self.storyboard) {
        [self performSegueWithIdentifier:@"mainSegue" sender:nil];
        [self performSegueWithIdentifier:@"leftSegue" sender:nil];
        [self performSegueWithIdentifier:@"rightSegue" sender:nil];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [self initCaptureLayer];
    [_overlayPerspectiveView removeFromSuperview];
    [self foldViewWithSpace:0.0f];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -  Data preparing method
-(void)initializeData{
    
    _menuState = BSMenuStateCenterOpen;
    
    _topShadowColor = DEFAULT_TOP_SHADOW_COLOR;
    _topShadowOpacity = DEFAULT_TOP_SHADOW_OPACITY;
    _topShadowWidth = DEFAULT_TOP_SHADOW_WIDTH;
    
    _animationDuration = DEFAULT_ANIMATION_DURATION;
    
    _leftMenuWidth = DEFAULT_LEFT_MENU_WIDTH;
    _rightMenuWidth = DEFAULT_RIGHT_MENU_WIDTH;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:panGesture];
    
}

-(void)initCaptureLayer{
    UIImage * viewImage = nil;
    UIImage *leftImage = nil;
    UIImage *rightImage = nil;
    
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(_leftViewController.view.bounds.size, NO, [UIScreen mainScreen].scale);
        //NOTE: use drawViewHierarchyInRect is more performance than renderInContext:
        [_leftViewController.view drawViewHierarchyInRect:CGRectMake(0, 0, _leftViewController.view.bounds.size.width, _leftViewController.view.bounds.size.height) afterScreenUpdates:NO];
        viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGSize halfsize = CGSizeMake(viewImage.size.width / 2, viewImage.size.height);
        CGSize fullsize = CGSizeMake(viewImage.size.width, viewImage.size.height);
        
        // The left half of the image >> full image
        UIGraphicsBeginImageContextWithOptions(fullsize, YES, [UIScreen mainScreen].scale);
        [viewImage drawAtPoint:CGPointMake(0, 0) blendMode:kCGBlendModeNormal alpha:1.0];
        leftImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        UIGraphicsBeginImageContextWithOptions(halfsize, YES, [UIScreen mainScreen].scale);
        [viewImage drawAtPoint:CGPointMake(-halfsize.width, 0) blendMode:kCGBlendModeNormal alpha:1.0];
        rightImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    if (!_overlayPerspectiveView) {
        
        CGFloat width = _leftMenuWidth;
        CGFloat height = SCREEN_HEIGHT;
        _overlayPerspectiveView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        _overlayPerspectiveView.backgroundColor = [UIColor blackColor];
        _overlayPerspectiveView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        _perspectiveLayer = [CALayer layer];
        _perspectiveLayer.frame = CGRectMake(0, 0, width/2, height);
        [_overlayPerspectiveView.layer addSublayer:_perspectiveLayer];
        
        _firstJointLayer = [CATransformLayer layer];
        _firstJointLayer.frame = _overlayPerspectiveView.bounds;
        [_perspectiveLayer addSublayer:_firstJointLayer];
        
        _topSleeve = [CALayer layer];
        _topSleeve.frame = CGRectMake(0, 0, width, height);
        _topSleeve.anchorPoint = CGPointMake(0, 0.5);
        _topSleeve.contents = (__bridge id)[leftImage CGImage];
        
        _topSleeve.position = CGPointMake(0, height/2);
        [_firstJointLayer addSublayer:_topSleeve];
        _topSleeve.masksToBounds = NO;
        
        _secondJointLayer = [CATransformLayer layer];
        _secondJointLayer.frame = _overlayPerspectiveView.bounds;
        _secondJointLayer.frame = CGRectMake(0, 0, width, height);
        _secondJointLayer.anchorPoint = CGPointMake(0, 0.5);
        _secondJointLayer.position = CGPointMake(width/2, height/2);
        
        [_firstJointLayer addSublayer:_secondJointLayer];
        
        _middleSleeve = [CALayer layer];
        _middleSleeve.frame = CGRectMake(0, 0, width/2, height);
        _middleSleeve.anchorPoint = CGPointMake(0, 0.5);
        _middleSleeve.contents = (__bridge id)[rightImage CGImage];
        _middleSleeve.position = CGPointMake(0, height/2);
        
        [_secondJointLayer addSublayer:_middleSleeve];
        _middleSleeve.masksToBounds = YES;
        
        
        _firstJointLayer.anchorPoint = CGPointMake(0, 0.5);
        _firstJointLayer.position = CGPointMake(0, height/2);
        
        _middleShadow = [CALayer layer];
        [_middleSleeve addSublayer:_middleShadow];
        _middleShadow.frame = _middleSleeve.bounds;
        _middleShadow.backgroundColor = [UIColor blackColor].CGColor;
        _middleShadow.opacity = 0.0;
        
        _transform3DEffect = CATransform3DIdentity;
        _transform3DEffect.m34 = 1.0/(-2000.0);
        _perspectiveLayer.sublayerTransform = _transform3DEffect;
        
        [_leftViewController.view addSubview:_overlayPerspectiveView];

    }else{
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        _topSleeve.contents = (id)leftImage.CGImage;
        _middleSleeve.contents = (id)rightImage.CGImage;
        
        [_leftViewController.view addSubview:_overlayPerspectiveView];
        [CATransaction commit];
    }
    
    [_leftViewController.view bringSubviewToFront:_overlayPerspectiveView];

}

#pragma mark - Public Method
-(void)setMainViewController:(UIViewController *)mainViewController{
    if (!mainViewController) {
        return;
    }
    if (_mainViewController) {
        [_mainViewController.view removeFromSuperview];
        [_mainViewController willMoveToParentViewController:nil];
        [_mainViewController beginAppearanceTransition:NO animated:NO];
        [_mainViewController removeFromParentViewController];
        [_mainViewController endAppearanceTransition];
        [_overlayMainView removeFromSuperview];
    }
    
    _mainViewController = mainViewController;
    [self addChildViewController:_mainViewController];
    [self didMoveToParentViewController:self];
    
    if ([self isViewLoaded]) {
        [_mainViewController.view setFrame:[UIScreen mainScreen].bounds];
        if (!_overlayMainView) {
            _overlayMainView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [_overlayMainView setBackgroundColor:[UIColor clearColor]];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            [_overlayMainView addGestureRecognizer:tapGesture];
            [_overlayMainView setHidden:YES];
        }else{
            [_overlayMainView removeFromSuperview];
            [_overlayMainView setHidden:YES];
        }
        [_mainViewController beginAppearanceTransition:YES animated:NO];
        [self.view addSubview:_mainViewController.view];
        [_mainViewController.view addSubview:_overlayMainView];
        _overlayMainView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _mainViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

        [self setupTopViewShadow];
        
        [_mainViewController endAppearanceTransition];
    }
}


-(void)setLeftViewController:(UIViewController *)leftViewController{
    if (!leftViewController) {
        _leftMenuEnabled = NO;
        return;
    }
    if (_leftViewController) {
        [_leftViewController.view removeFromSuperview];
        [_leftViewController willMoveToParentViewController:nil];
        [_leftViewController beginAppearanceTransition:NO animated:NO];
        [_leftViewController removeFromParentViewController];
        [_leftViewController endAppearanceTransition];
    }
    
    _leftViewController = leftViewController;
    [self addChildViewController:_leftViewController];
    [self didMoveToParentViewController:self];
    
    CGRect leftViewFrame = [UIScreen mainScreen].bounds;
    leftViewFrame.size.width = _leftMenuWidth;
    [_leftViewController.view setFrame:leftViewFrame];
    [self.view insertSubview:_leftViewController.view belowSubview:_mainViewController.view];
    _leftViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin;
    _leftMenuEnabled = YES;
    _foldEffeectEnabled = YES;
}

-(void)setRightViewController:(UIViewController *)rightViewController{
    if (!rightViewController) {
        _rightMenuEnabled = NO;
        return;
    }
    if (_rightViewController) {
        [_rightViewController.view removeFromSuperview];
        [_rightViewController willMoveToParentViewController:nil];
        [_rightViewController beginAppearanceTransition:NO animated:NO];
        [_rightViewController removeFromParentViewController];
        [_rightViewController endAppearanceTransition];
    }
    
    _rightViewController = rightViewController;
    [self addChildViewController:_rightViewController];
    [self didMoveToParentViewController:self];
    
    CGRect rightViewFrame = CGRectMake(SCREEN_WIDTH-_rightMenuWidth, 0, _rightMenuWidth, SCREEN_HEIGHT);
    [_rightViewController.view setFrame:rightViewFrame];
    [self.view insertSubview:_rightViewController.view belowSubview:_mainViewController.view];
    _rightViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
    _rightMenuEnabled = YES;
}

-(void)setLeftMenuWidth:(CGFloat)leftMenuWidth{
    _leftMenuWidth = leftMenuWidth;
    
    if (!_leftViewController) {
        return;
    }
    
    CGFloat currentDeviceWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat currentDeviceHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    if (IS_IOS_7_OR_LESS) {
        UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
        if (UIDeviceOrientationIsLandscape(currentOrientation)) {
            currentDeviceWidth = CGRectGetHeight([UIScreen mainScreen].bounds);
            currentDeviceHeight = CGRectGetWidth([UIScreen mainScreen].bounds);
        }else if (UIDeviceOrientationIsPortrait(currentOrientation)){
            currentDeviceWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
            currentDeviceHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        }
    }
    CGRect leftViewFrame = CGRectMake(0, 0, currentDeviceWidth, currentDeviceHeight);
    leftViewFrame.size.width = _leftMenuWidth;
    [_leftViewController.view setFrame:leftViewFrame];
}
-(void)setRightMenuWidth:(CGFloat)rightMenuWidth{
    _rightMenuWidth = rightMenuWidth;
    
    if (!_rightViewController) {
        return;
    }
    
    CGFloat currentDeviceWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat currentDeviceHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    if (IS_IOS_7_OR_LESS) {
        UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
        if (UIDeviceOrientationIsLandscape(currentOrientation)) {
            currentDeviceWidth = CGRectGetHeight([UIScreen mainScreen].bounds);
            currentDeviceHeight = CGRectGetWidth([UIScreen mainScreen].bounds);
        }else if (UIDeviceOrientationIsPortrait(currentOrientation)){
            currentDeviceWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
            currentDeviceHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        }
    }
    CGRect rightViewFrame = CGRectMake(currentDeviceWidth-_rightMenuWidth, 0, _rightMenuWidth, currentDeviceHeight);
    [_rightViewController.view setFrame:rightViewFrame];
}


-(void)leftMenuAction{
    if (_menuState == BSMenuStateRightOpen) {
        return;
    }
    [self initCaptureLayer];
    [self.view sendSubviewToBack:_rightViewController.view];
    if (_menuState == BSMenuStateCenterOpen) {
        [self animateWithState:BSMenuStateLeftOpen duration:_animationDuration];
    }
    else{
        [self animateWithState:BSMenuStateCenterOpen duration:_animationDuration];
    }
}

-(void)rightMenuAction{
    if (_menuState == BSMenuStateLeftOpen) {
        return;
    }
    [self initCaptureLayer];
    [self.view sendSubviewToBack:_leftViewController.view];
    if (_menuState == BSMenuStateCenterOpen) {
        [self animateWithState:BSMenuStateRightOpen duration:_animationDuration];
    }
    else{
        [self animateWithState:BSMenuStateCenterOpen duration:_animationDuration];
    }
}

#pragma mark - UIGestureRecognizer method
-(IBAction)tap:(UIPanGestureRecognizer *)recognizer{
    [self animateWithState:BSMenuStateCenterOpen duration:0.15f];
}
- (IBAction)pan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    static CGFloat distance = 0.0f;
    static CGFloat tx = 0.0f;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            if (_delegate && [_delegate respondsToSelector:@selector(foldMenuControllerWillBeginDragging:)]) {
                __weak id weakSelf = self;
                [_delegate foldMenuControllerWillBeginDragging:weakSelf];
            }else{
                NSLog(@"%s Delegate not response to selector",__PRETTY_FUNCTION__);
            }
            if (_foldEffeectEnabled == YES) {
                [self initCaptureLayer];
            }
            _isDragging = YES;
            
            tx = _mainViewController.view.transform.tx;
            
            break;
        case UIGestureRecognizerStateChanged:{
            _isDragging = YES;
            if (tx >0) {
                //if current state is Left Menu open
                if(translation.x>0){
                    //Move to right
                    distance = (0.0f + _leftMenuWidth);
                }else{
                    //Move to dileft
                    distance = (translation.x + _leftMenuWidth);
                    if (_rightMenuEnabled == YES) {
                        if (distance < -_rightMenuWidth) {
                            distance = (0.0f - _rightMenuWidth);
                        }
                        if (distance <= 0) {
                            [self.view sendSubviewToBack:_leftViewController.view];
                        }
                    }else{
                        if (distance < 0.0f) {
                            distance = 0.0f;
                        }
                    }
                }
                [self foldViewWithSpace: distance];
            }else if (tx == 0){
                //If current state is Hide All Menu
                if (translation.x>=0) {
                    //Move to right for show Left menu
                    distance = translation.x;
                    if (_leftMenuEnabled == YES) {
                        if (distance> _leftMenuWidth) {
                            distance = _leftMenuWidth;
                        }
                        if (distance >=0) {
                            //Bring left menu to behin of right menu
                            [self.view sendSubviewToBack:_rightViewController.view];
                        }
                    }else{
                        distance = 0.0f;
                    }
                    [self foldViewWithSpace:distance];
                }else{
                    //Move to left to show Right menu
                    distance = translation.x;
                    if (_rightMenuEnabled == YES) {
                        if (distance < -_rightMenuWidth) {
                            distance = -_rightMenuWidth;
                        }
                        if (distance<=0) {
                            [self.view sendSubviewToBack:_leftViewController.view];
                        }
                    }else{
                        distance = 0.0f;
                    }
                    [self foldViewWithSpace:distance];
                }
                
            }else if (tx < 0){
                //if current state is Right Menu open
                if(translation.x>=0){
                    //Move to right
                    distance = translation.x - _rightMenuWidth;
                    if (_leftMenuEnabled == YES) {
                        if (distance > _leftMenuWidth) {
                            distance = _leftMenuWidth;
                        }
                        if (distance >=0) {
                            [self.view sendSubviewToBack:_rightViewController.view];
                        }
                    }else{
                        if (distance > 0.0f) {
                            distance = 0.0f;
                        }
                    }
                }else if (translation.x<0){
                    //Move to left
                    distance = 0 - _rightMenuWidth;
                }
                [self foldViewWithSpace:distance];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{
            // Cancel or finish depending on how the gesture ended.
            if (_delegate && [_delegate respondsToSelector:@selector(foldMenuControllerWillEndDragging:)]) {
                __weak id weakSelf = self;
                [_delegate foldMenuControllerWillEndDragging:weakSelf];
            }else{
                NSLog(@"%s Delegate not response to selector",__PRETTY_FUNCTION__);
            }
            _isDragging = NO;
            CGFloat velocity = [recognizer velocityInView:self.view].x;
            CGFloat tx = _mainViewController.view.transform.tx;
            
            if (tx > 0) {
                //If swipe for showing left menu
                [self.view sendSubviewToBack:_rightViewController.view];
                if (velocity > 0) {
                    if (velocity > 800){
                        [self animateWithState:BSMenuStateLeftOpen duration:_animationDuration*0.8f];
                    }
                    else{
                        if (tx < _leftMenuWidth/2) {
                            [self animateWithState:BSMenuStateCenterOpen duration:_animationDuration];
                        }else{
                            [self animateWithState:BSMenuStateLeftOpen duration:_animationDuration];
                        }
                        
                    }
                }else{
                    if (velocity < -800){
                        [self animateWithState:BSMenuStateCenterOpen duration:_animationDuration*0.8f];
                    }
                    else{
                        if (tx > _rightMenuWidth/2) {
                            [self animateWithState:BSMenuStateLeftOpen duration:_animationDuration];
                        }else{
                            [self animateWithState:BSMenuStateCenterOpen duration:_animationDuration];
                        }
                    }
                }
            }else{
                //If swipe for showing right menu
                [self.view sendSubviewToBack:_leftViewController.view];
                if (velocity > 0) {
                    if (velocity > 800){
                        [self animateWithState:BSMenuStateCenterOpen duration:_animationDuration*0.8f];
                    }
                    else{
                        if (fabs(tx) < _rightMenuWidth/2) {
                            [self animateWithState:BSMenuStateCenterOpen duration:_animationDuration];
                        }else{
                            [self animateWithState:BSMenuStateRightOpen duration:_animationDuration];
                        }
                        
                    }
                }else{
                    if (velocity < -800){
                        [self animateWithState:BSMenuStateRightOpen duration:_animationDuration*0.8f];
                    }
                    else{
                        if (fabs(tx) > _rightMenuWidth/2) {
                            [self animateWithState:BSMenuStateRightOpen duration:_animationDuration];
                        }else{
                            
                            [self animateWithState:BSMenuStateCenterOpen duration:_animationDuration];
                        }
                    }
                }

            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(foldMenuControllerDidEndDragging:)]) {
                __weak id weakSelf = self;
                [_delegate foldMenuControllerDidEndDragging:weakSelf];
            }else{
                NSLog(@"%s Delegate not response to selector",__PRETTY_FUNCTION__);
            }
            
            break;
        }
        default:
            NSLog(@"unhandled state for gesture=%@", recognizer);
    }

}

#pragma mark - Private method
-(void)foldViewWithSpace:(CGFloat) space{
    CGFloat theSpace = space;

    CGFloat ratio = theSpace/_leftViewController.view.width;
    //Cạnh kề
    CGFloat adjacentEdge = theSpace/2;
    
    //Cạnh huyền
    CGFloat hypotenuseEdge = _leftViewController.view.width/2;
    
    CGFloat angle = acos(adjacentEdge/hypotenuseEdge);
    
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES]; // no animations
    if (_foldEffeectEnabled == YES) {
        _firstJointLayer.transform = CATransform3DMakeRotation(angle, 0.0, 1.0, 0.0);
        
        _secondJointLayer.transform = CATransform3DMakeRotation(-2*angle, 0.0, 1.0, 0.0);
        
        _middleShadow.opacity = 0.3*(1-ratio);
    }
    
    _mainViewController.view.transform = CGAffineTransformMakeTranslation(theSpace, 0);
    [CATransaction commit];
    
}

-(CGFloat)convertToRadians:(float) input
{
    return input* M_PI / 180.0f;
}
-(void)animateWithState:(BSMenuState)menuState duration:(NSTimeInterval) duration
{
    __weak BEFoldMenuViewController *weakSelf = self;
    
    __block CGFloat foldAngle = 0.0f;
    __block CGFloat foldOpacity = 0.0f;
    __block CGFloat translationX = 0.0f;
    
    __block BSMenuState _theMenuState = menuState;
    
    switch (menuState) {
        case BSMenuStateLeftOpen:{
            if (_leftMenuEnabled == YES) {
                foldAngle = 0.0f;
                foldOpacity = 0.0f;
                translationX = _leftMenuWidth;
                break;
            }//else go to next case
        }
        case BSMenuStateRightOpen:{
            
            if (_rightMenuEnabled == YES) {
                foldAngle = 0.0f;
                foldOpacity = 0.0f;
                translationX = -_rightMenuWidth;
                break;
            }// else go to next case
        }
        case BSMenuStateCenterOpen:{
            _theMenuState = BSMenuStateCenterOpen;
            foldAngle = M_PI_2;
            foldOpacity = FOLD_OPACITY_MAXIMUM;
            translationX = 0.0f;
            break;
        }
        default:
            break;
    }
    
    if (_leftMenuEnabled == NO && _rightMenuEnabled == NO) {
        _theMenuState = BSMenuStateCenterOpen;
        foldAngle = M_PI_2;
        foldOpacity = FOLD_OPACITY_MAXIMUM;
        translationX = 0.0f;
    }
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    if (_delegate && [_delegate respondsToSelector:@selector(foldMenuControllerWillStartAnimation:duration:)]) {
        [_delegate foldMenuControllerWillStartAnimation:weakSelf duration:duration];
    }else{
        NSLog(@"%s Delegate not response to selector",__PRETTY_FUNCTION__);
    }
    [CATransaction begin];
    CABasicAnimation*  animation = nil;
    
    if (_foldEffeectEnabled == YES) {
        animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [animation setDuration:duration];
        [animation setAutoreverses:NO];
        [animation setRepeatCount:0];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [animation setFromValue:[NSNumber numberWithFloat:_middleShadow.opacity]];
        [animation setToValue:[NSNumber numberWithDouble:foldOpacity]];
        [_middleShadow addAnimation:animation forKey:@"middleShadow.opacity"];
        
        animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        [animation setDuration:duration];
        [animation setAutoreverses:NO];
        [animation setRepeatCount:0];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [animation setFromValue:[NSValue valueWithCATransform3D:_firstJointLayer.transform]];
        [animation setToValue:[NSValue valueWithCATransform3D:CATransform3DMakeRotation(foldAngle, 0.0, 1.0, 0.0)]];
        [_firstJointLayer addAnimation:animation forKey:@"firstJointLayer.transform"];
        
        animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        [animation setDuration:duration];
        [animation setAutoreverses:NO];
        [animation setRepeatCount:0];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [animation setFromValue:[NSValue valueWithCATransform3D:_secondJointLayer.transform]];
        [animation setToValue:[NSValue valueWithCATransform3D:CATransform3DMakeRotation(-2*foldAngle, 0.0, 1.0, 0.0)]];
        [_secondJointLayer addAnimation:animation forKey:@"secondJointLayer.transform"];
    }
    
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    [animation setDuration:duration];
    [animation setAutoreverses:NO];
    [animation setRepeatCount:0];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [animation setFromValue:[NSValue valueWithCATransform3D:_mainViewController.view.layer.transform]];
    [animation setToValue:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(translationX, 0, 0)]];
    
    
    
    [CATransaction setCompletionBlock:^{
        weakSelf.menuState = _theMenuState;
        if (weakSelf.foldEffeectEnabled == YES) {
            [weakSelf.firstJointLayer removeAnimationForKey:@"firstJointLayer.transform"];
            [weakSelf.secondJointLayer removeAnimationForKey:@"secondJointLayer.transform"];
            [weakSelf.middleShadow removeAnimationForKey:@"middleShadow.opacity"];
        }
        [weakSelf.mainViewController.view.layer removeAnimationForKey:@"mainViewController.transform"];
        [weakSelf foldViewWithSpace:translationX];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.isDragging == NO) {
                [weakSelf.overlayPerspectiveView removeFromSuperview];
                //mainView = nil;
                [[UIApplication sharedApplication] endIgnoringInteractionEvents]; 
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(foldMenuControllerDidEndAnimation:)]) {
                    [weakSelf.delegate foldMenuControllerDidEndAnimation:weakSelf];
                }else{
                    NSLog(@"%s Delegate not response to selector",__PRETTY_FUNCTION__);
                }
                
                switch (_theMenuState) {
                    case BSMenuStateLeftOpen:{
                        [weakSelf.overlayMainView setHidden:NO];
//                        [weakSelf.mainViewController.view bringSubviewToFront:weakSelf.overlayMainView];
                        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(foldMenuController:didShowLeftMenu:)]) {
                            __weak id weakLeft = weakSelf.leftViewController;
                            [weakSelf.delegate foldMenuController:weakSelf didShowLeftMenu:weakLeft];
                        }else{
                            NSLog(@"%s Delegate not response to selector",__PRETTY_FUNCTION__);
                        }
                        break;
                    }
                    case BSMenuStateRightOpen:{
                        [weakSelf.overlayMainView setHidden:NO];
//                        [weakSelf.mainViewController.view bringSubviewToFront:weakSelf.overlayMainView];
                        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(foldMenuController:didShowRighMenu:)]) {
                            __weak id weakRight = weakSelf.rightViewController;
                            [weakSelf.delegate foldMenuController:weakSelf didShowRighMenu:weakRight];
                        }else{
                            NSLog(@"%s Delegate not response to selector",__PRETTY_FUNCTION__);
                        }
                        break;
                    }
                    case BSMenuStateCenterOpen:{
                        [weakSelf.overlayMainView setHidden:YES];
                        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(foldMenuControllerDidHideMenu:)]) {
                            [weakSelf.delegate foldMenuControllerDidHideMenu:weakSelf];
                        }else{
                            NSLog(@"%s Delegate not response to selector",__PRETTY_FUNCTION__);
                        }
                        break;
                    }
                    default:
                        break;
                }
            }
        });
        
        
    }];
    [_mainViewController.view.layer addAnimation:animation forKey:@"mainViewController.transform"];
    [CATransaction commit];
}

-(void)setupTopViewShadow{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(-_topShadowWidth, -_topShadowWidth, _mainViewController.view.width+2*_topShadowWidth, _mainViewController.view.height+2*_topShadowWidth)];
    
    _mainViewController.view.layer.masksToBounds = NO;
    _mainViewController.view.layer.shadowColor = _topShadowColor.CGColor;
    _mainViewController.view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    _mainViewController.view.layer.shadowOpacity = _topShadowOpacity;
    _mainViewController.view.layer.shadowPath = shadowPath.CGPath;
}
-(void)setupFoldLayout{
    CGFloat currentDeviceWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat currentDeviceHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    if (IS_IOS_7_OR_LESS) {
        UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
        if (UIDeviceOrientationIsLandscape(currentOrientation)) {
            currentDeviceWidth = CGRectGetHeight([UIScreen mainScreen].bounds);
            currentDeviceHeight = CGRectGetWidth([UIScreen mainScreen].bounds);
        }else if (UIDeviceOrientationIsPortrait(currentOrientation)){
            currentDeviceWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
            currentDeviceHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        }
    }
    
    CGRect leftMenuFrame = CGRectMake(0, 0, _leftMenuWidth, currentDeviceHeight);
    
    _overlayPerspectiveView.frame = leftMenuFrame;
    
    _perspectiveLayer.frame = CGRectMake(0, 0, _leftMenuWidth/2, currentDeviceHeight);
    _firstJointLayer.frame = _overlayPerspectiveView.bounds;
    _topSleeve.frame = CGRectMake(0, 0, _leftMenuWidth, currentDeviceHeight);
    _topSleeve.position = CGPointMake(0, currentDeviceHeight/2);
    _secondJointLayer.frame = CGRectMake(0, 0, _leftMenuWidth, currentDeviceHeight);
    _secondJointLayer.position = CGPointMake(_leftMenuWidth/2, currentDeviceHeight/2);
    _middleSleeve.frame = CGRectMake(0, 0, _leftMenuWidth/2, currentDeviceHeight);
    _middleSleeve.position = CGPointMake(0, currentDeviceHeight/2);
    _firstJointLayer.position = CGPointMake(0, currentDeviceHeight/2);
    _middleShadow.frame = _middleSleeve.bounds;
    
    [self setupTopViewShadow];
}

#pragma mark - UIInterfaceOrientation
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self setupFoldLayout];
}
@end

#pragma mark - UIViewController Extension
@implementation UIViewController (FoldMenuController)

-(BEFoldMenuViewController*)foldMenuController{
    
    UIViewController *viewController = self.parentViewController ? self.parentViewController : self.presentingViewController;
    while (!(viewController == nil || [viewController isKindOfClass:[BEFoldMenuViewController class]])) {
        viewController = viewController.parentViewController ? viewController.parentViewController : viewController.presentingViewController;
    }
    
    return (BEFoldMenuViewController *)viewController;
}

@end

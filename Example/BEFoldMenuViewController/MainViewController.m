//
//  MainViewController.m
//  BEFoldMenuViewControllerDemo
//
//  Created by Vũ Trường Giang on 8/1/16.
//  Copyright © 2016 Vũ Trường Giang. All rights reserved.
//

#import "MainViewController.h"
#import "BEFoldMenuViewController.h"


@interface MainViewController ()<BEFoldMenuDelegate>

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Main View Controller";
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(buttonMenuTapped)];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Right" style:UIBarButtonItemStylePlain target:self action:@selector(buttonRightMenuTapped)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    self.foldMenuController.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Action for button
-(void)buttonMenuTapped{
    [self.foldMenuController leftMenuAction];
}
-(void)buttonRightMenuTapped{
    [self.foldMenuController rightMenuAction];
}

#pragma mark - BEFoldMenuDelegate
-(void)foldMenuControllerWillBeginDragging:(UIViewController*) foldMenuController{
    NSLog(@"WillBeginDragging");
    [self.foldMenuController.leftViewController.view endEditing:YES];
}
-(void)foldMenuControllerWillEndDragging:(UIViewController*) foldMenuController{
    NSLog(@"WillEndDragging");
}
-(void)foldMenuControllerDidEndDragging:(UIViewController*) foldMenuController{
    NSLog(@"DidEndDragging");
}
-(void)foldMenuControllerWillStartAnimation:(UIViewController*) foldMenuController duration:(CGFloat) duration{
    NSLog(@"WillStartAnimation");
}
-(void)foldMenuControllerDidEndAnimation:(UIViewController*) foldMenuController{
    NSLog(@"DidEndAnimation");
}


//Left
-(void)foldMenuController:(UIViewController*) foldMenuController didShowLeftMenu:(UIViewController*) leftMenuController{
    NSLog(@"didShowLeftMenu");
}
//Right
-(void)foldMenuController:(UIViewController*) foldMenuController didShowRighMenu:(UIViewController*) leftMenuController{
    NSLog(@"didShowRighMenu");
}
//Hide
-(void)foldMenuControllerDidHideMenu:(UIViewController*) foldMenuController{
    NSLog(@"DidHideMenu");
}
@end

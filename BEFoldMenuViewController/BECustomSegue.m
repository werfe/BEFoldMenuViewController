//
//  CustomSegue.m
//  BEFoldMenuViewControllerDemo
//
//  Created by Vũ Trường Giang on 8/1/16.
//  Copyright © 2016 Vũ Trường Giang. All rights reserved.
//

#import "BECustomSegue.h"
#import "BEFoldMenuViewController.h"

@implementation BECustomSegue

-(void)perform{
    NSLog(@"Identifier %@",self.identifier);
    
    if ([self.sourceViewController isKindOfClass:[BEFoldMenuViewController class]]) {
        BEFoldMenuViewController *foldViewController = (BEFoldMenuViewController *)self.sourceViewController;
        
        if ([self.identifier isEqualToString:foldViewController.mainSegueIdentifier]) {
            foldViewController.mainViewController = self.destinationViewController;
        }else if([self.identifier isEqualToString:foldViewController.leftSegueIdentifier]){
            foldViewController.leftViewController = self.destinationViewController;
        }else if([self.identifier isEqualToString:foldViewController.rightSegueIdentifier]){
            foldViewController.rightViewController = self.destinationViewController;
        }
    }
    
}

@end

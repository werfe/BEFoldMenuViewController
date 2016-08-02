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
        if ([self.identifier isEqualToString:@"mainSegue"]) {
            ((BEFoldMenuViewController *)self.sourceViewController).mainViewController = self.destinationViewController;
        }else if([self.identifier isEqualToString:@"leftSegue"]){
            ((BEFoldMenuViewController *)self.sourceViewController).leftViewController = self.destinationViewController;
        }else if([self.identifier isEqualToString:@"rightSegue"]){
            ((BEFoldMenuViewController *)self.sourceViewController).rightViewController = self.destinationViewController;
        }
    }
    
}

@end

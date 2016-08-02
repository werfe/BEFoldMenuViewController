//
//  MyTableViewCell.m
//  BEFoldMenuViewControllerDemo
//
//  Created by Vũ Trường Giang on 8/1/16.
//  Copyright © 2016 Vũ Trường Giang. All rights reserved.
//

#import "MyTableViewCell.h"

@implementation MyTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

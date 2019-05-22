//
//  WSHLKoalaBabyCell.m
//  Test自定义布局--瀑布流
//
//  Created by WSHL on 2019/5/14.
//  Copyright © 2019年 Haier. All rights reserved.
//

#import "WSHLKoalaBabyCell.h"
#import "WSHLKoalaBaby.h"

@interface WSHLKoalaBabyCell ()

@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@end

@implementation WSHLKoalaBabyCell

- (void)awakeFromNib {
    [super awakeFromNib];
}


#pragma mark - Setter

- (void)setKoalaBaby:(WSHLKoalaBaby *)koalaBaby {
    _koalaBaby = koalaBaby;
    
    self.photoView.image = [UIImage imageNamed:_koalaBaby.img];
}


@end

//
//  WSHLWaterFlowLayout.h
//  Test自定义布局--瀑布流
//
//  Created by WSHL on 2019/5/10.
//  Copyright © 2019年 Haier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSHLWaterFlowLayout;

/**
 设置代理，由代理决定cell的高度值
 */
@protocol WSHLWaterFlowLayoutDelegate <NSObject>

@required

/**
 由代理(外界)决定高度(强制实现)
 */
- (CGFloat)waterFlowLayout:(WSHLWaterFlowLayout *)waterFlowLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth;

@optional

/**
 可以由外界决定几列排列
 */
- (NSInteger)numberOfColsInCollectionViewLayout:(WSHLWaterFlowLayout *)collectionViewLayout;
/**
 可以由外界决定每两列间的间距
 */
- (NSInteger)marginInCollectionViewLayout:(WSHLWaterFlowLayout *)collectionViewLayout;
/**
 可以由外界决定edgeInsets
 */
- (UIEdgeInsets)edgeInsetsInCollectionViewLayout:(WSHLWaterFlowLayout *)collectionViewLayout;


@end

@interface WSHLWaterFlowLayout : UICollectionViewLayout

@property (nonatomic, weak) id <WSHLWaterFlowLayoutDelegate> delegate;

@end

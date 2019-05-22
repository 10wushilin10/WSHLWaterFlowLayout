//
//  WSHLWaterFlowLayout.m
//  Test自定义布局--瀑布流
//
//  Created by WSHL on 2019/5/10.
//  Copyright © 2019年 Haier. All rights reserved.
//

#import "WSHLWaterFlowLayout.h"

@interface WSHLWaterFlowLayout ()

/**
 存放所有cell的布局属性
 */
@property (nonatomic, strong) NSMutableArray *attrsArray;
/**
 存放所有列的高度值
 */
@property (nonatomic, strong) NSMutableArray *colHeights;
/**
 内容最大高度(将内容的最大高度存储，便于计算出最终的contentSize)
 */
@property (nonatomic, assign) CGFloat contentHeight;


// 将基本数据处理的方法进行声明，目的是为了方便使用点语法调用那些方法(在 interface 中声明的方法，才可以通过点语法调用)
/**
 列数
 */
- (NSInteger)cols;
/**
 cell间距(纵向与横向一样，也可以分开)
 */
- (CGFloat)margin;
/**
 整体内间距
 */
- (UIEdgeInsets)edgeInsets;

@end

/**
 默认3列
 */
static NSInteger const WSHLCols = 3;
/**
 默认间距
 */
static CGFloat const WSHLMargin = 10;
/**
 默认整体内间距
 */
static UIEdgeInsets const WSHLEdgeInsets = {10, 10, 10, 10};
/*
 按照静态常量的常规写法，可能首先会按照下面的方式写一个 UIEdgeInsets 常量：
 
 static UIEdgeInsets const WSHLEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
 
 但是这样写，系统肯定会报错。因为 UIEdgeInsetsMake 方法内部调用了一个函数(可以进入方法查看)，函数的调用肯定是不能写成静态常量的，因为函数是在程序运行过程中才确定的，而静态常量是在编译阶段就确定下来的，因此，系统肯定会报错。
 解决方法：由于 UIEdgeInsets 是一个结构体，因此，日常在定义结构体常量时，一个大括号就可以搞定了，大括号内的4个值分别赋值给了结构体的4个属性。
 */


@implementation WSHLWaterFlowLayout

/**
 将计算所有cell布局属性的代码放入prepareLayout方法中，是因为prepareLayout方法只会调用一次，这正好符合循环利用机制，计算过的布局无需重复计算。(如果放在layoutAttributesForElementsInRect:方法中，由于该方法会被多次调用，只要一滚动就会被调用，因为滚动之后对应的rect就会变，因此很多布局会被重复计算，这样对性能不够友好)
 */
- (void)prepareLayout {
    
    [super prepareLayout];
    
    // 清空之前所有的布局属性(因为collectionview每次刷新时会重新调用prepareLayout方法，因此，此时也要重新计算每个cell对应的布局属性，如果不做清空处理，那么数组中会重复添加布局属性，数组会越来越大，导致数据个数不统一)
    [self.attrsArray removeAllObjects];
    // 同样的，清空存储的所有列的高度值
    [self.colHeights removeAllObjects];
    // 同样的，清空内容的最大高度
    self.contentHeight = 0;
    
    // 设置默认高度(防止第一次取数时候，数组中没有元素)
    for (NSInteger integer = 0; integer < self.cols; integer++) {
        [self.colHeights addObject:@(WSHLEdgeInsets.top)];
    }
    
    NSInteger items = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger item = 0; item < items; item++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        // 获取indexPath位置cell对应的布局属性
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
    
        [self.attrsArray addObject:attrs];
    }
}

/**
 决定cell的排布
 */
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {

    return self.attrsArray;
}


/**
 返回indexPath位置cell的布局属性
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat w = (self.collectionView.bounds.size.width - WSHLEdgeInsets.left - WSHLEdgeInsets.right - (self.cols - 1) * self.margin) / self.cols;
    // 由代理来计算高度，因为此代理方法是 required，因此不需要做if判断
    CGFloat h = [self.delegate waterFlowLayout:self heightForItemAtIndexPath:indexPath itemWidth:w];
    // 找出高度最短的那一列
//    __block NSInteger destCol = 0;
//    __block CGFloat minColHeight = MAXFLOAT;
//    [self.colHeights enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        CGFloat colHeight = obj.floatValue;
//        if (minColHeight > colHeight) {
//            destCol = idx;
//            minColHeight = colHeight;
//        }
//
//    }];
    // 用for循环，可以提高效率，因为可以在一开始将self.colHeights[0]赋值给minColHeight，然后从index[1]位置的元素开始遍历，这样就可以少遍历一次，而上面运用的block方法是只能从index[0]位置的元素开始遍历的。
    NSInteger destCol = 0;
    CGFloat minColHeight = [self.colHeights[0] floatValue];
    for (NSInteger integer = 1; integer < self.colHeights.count; integer++) {
        CGFloat colHeight = [self.colHeights[integer] floatValue];
        if (minColHeight > colHeight) {
            destCol = integer;
            minColHeight = colHeight;
        }
    }
    // 设置x、y值
    CGFloat x = WSHLEdgeInsets.left + destCol * (w + self.margin);
    CGFloat y = self.margin;
    if (indexPath.item > 3) { // 第一行
        y = minColHeight + self.margin;
    }
    
    attrs.frame = CGRectMake(x, y, w, h);
    
    // 更新这一列的高度值
    self.colHeights[destCol] = @(CGRectGetMaxY(attrs.frame));
    
    CGFloat colHeight = [self.colHeights[destCol] floatValue];
    if (self.contentHeight < colHeight) {
        self.contentHeight = colHeight;
    }
    
    return attrs;
}

/**
 滚动范围
 */
- (CGSize)collectionViewContentSize {
    
    return CGSizeMake(0, self.contentHeight);
}


#pragma mark - Lazy

- (NSMutableArray *)attrsArray {
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

- (NSMutableArray *)colHeights {
    if (!_colHeights) {
        _colHeights = [NSMutableArray array];
    }
    return _colHeights;
}


#pragma mark - 基本数据处理

- (NSInteger)cols {
    if ([self.delegate respondsToSelector:@selector(numberOfColsInCollectionViewLayout:)]) {
        return [self.delegate numberOfColsInCollectionViewLayout:self];
    }
    return WSHLCols;
}

- (CGFloat)margin {
    if ([self.delegate respondsToSelector:@selector(marginInCollectionViewLayout:)]) {
        return [self.delegate marginInCollectionViewLayout:self];
    }
    return WSHLMargin;
}

- (UIEdgeInsets)edgeInsets {
    if ([self.delegate respondsToSelector:@selector(edgeInsetsInCollectionViewLayout:)]) {
        return [self.delegate edgeInsetsInCollectionViewLayout:self];
    }
    return WSHLEdgeInsets;
}

@end

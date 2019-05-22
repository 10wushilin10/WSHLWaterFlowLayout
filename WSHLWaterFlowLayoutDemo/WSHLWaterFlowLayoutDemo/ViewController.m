//
//  ViewController.m
//  Test自定义布局--瀑布流
//
//  Created by WSHL on 2019/5/10.
//  Copyright © 2019年 Haier. All rights reserved.
//

#import "ViewController.h"
#import "WSHLWaterFlowLayout.h"
#import "WSHLKoalaBabyCell.h"
#import "WSHLKoalaBaby.h"
#import <MJRefresh.h>


@interface ViewController () <UICollectionViewDataSource, WSHLWaterFlowLayoutDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
/**
 考拉图集
 */
@property (nonatomic, strong) NSMutableArray *koalas;

@end

static NSString * const cellId = @"koala";

@implementation ViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupLayout];
    
    [self setupRefresh];
}


#pragma mark - Settings

/**
 设置布局
 */
- (void)setupLayout {
    // 创建布局
    WSHLWaterFlowLayout *layout = [[WSHLWaterFlowLayout alloc] init];
    layout.delegate = self;
    CGRect frame = [UIScreen mainScreen].bounds;
    // 代码创建collectionView时，必须要设定layout，否则会崩
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    [self.view addSubview:collectionView];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    // 注册cell
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([WSHLKoalaBabyCell class]) bundle:nil] forCellWithReuseIdentifier:cellId];
    self.collectionView = collectionView;
}


#pragma mark - Refresh

/**
 设置刷新
 */
- (void)setupRefresh {
    
    self.collectionView.mj_header = [MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewKoalas)];
    [self.collectionView.mj_header beginRefreshing];
    self.collectionView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreKoalas)];
    self.collectionView.mj_footer.hidden = YES;
}

- (void)loadNewKoalas {
    
    // 模拟网络刷新
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"plist"];
        NSArray *koalas = [WSHLKoalaBaby arrayOfModelsFromDictionaries:[[NSArray alloc] initWithContentsOfFile:filePath] error:nil];
        
        [self.koalas removeAllObjects];
        [self.koalas addObjectsFromArray:koalas];
        
        [self.collectionView reloadData];
        
        [self.collectionView.mj_header endRefreshing];
    });
}

- (void)loadMoreKoalas {
    // 模拟网络刷新
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"plist"];
        NSArray *koalas = [WSHLKoalaBaby arrayOfModelsFromDictionaries:[[NSArray alloc] initWithContentsOfFile:filePath] error:nil];
        [self.koalas addObjectsFromArray:koalas];
        
        [self.collectionView reloadData];
        
        [self.collectionView.mj_footer endRefreshing];
    });
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    collectionView.mj_footer.hidden = self.koalas.count == 0;
    return self.koalas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WSHLKoalaBabyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    cell.koalaBaby = self.koalas[indexPath.item];
    
    return cell;
}


#pragma mark - WSHLWaterFlowLayoutDelegate

- (CGFloat)waterFlowLayout:(WSHLWaterFlowLayout *)waterFlowLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)itemWidth {
    
    WSHLKoalaBaby *koala = self.koalas[indexPath.item];
    return itemWidth * koala.h.floatValue / koala.w.floatValue;
}

- (NSInteger)numberOfColsInCollectionViewLayout:(WSHLWaterFlowLayout *)collectionViewLayout {
    
    return 4;
}


#pragma mark - Lazy

- (NSMutableArray *)koalas {
    if (!_koalas) {
        _koalas = [NSMutableArray array];
    }
    return _koalas;
}

@end

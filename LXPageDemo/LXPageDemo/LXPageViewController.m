//
//  LXPageViewController.m
//  Stars
//
//  Created by livesxu on 2018/9/17.
//  Copyright © 2018年 ShuJin. All rights reserved.
//

#import "LXPageViewController.h"

@interface LXPageViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (nonatomic,   copy) NSString *reuseIdentifier;

@property (nonatomic, strong) NSMutableArray *pageLoadArray;//存放pageIndex相关信息

@property (nonatomic, assign) NSUInteger itemsCount;

@property (nonatomic, strong) UICollectionView *collectionTaps;

@property (nonatomic, strong) UIScrollView *pageScroll;

@property (nonatomic, strong) UIView *indicator;//承接指示器

@property (nonatomic, assign) BOOL isPageScrollAction;//是否在滚动中
@property (nonatomic, assign) CGFloat scrollOffsetXStand;
@property (nonatomic, assign) BOOL isAddFlag;//控制加执行
@property (nonatomic, assign) BOOL isReduceFlag;//控制减执行

@end

@implementation LXPageViewController

- (instancetype)initWithFrame:(CGRect)frame Delegate:(id<LXPageDelegate>)delegate;{
    
    self = [super init];
    if (self) {
        
        _reuseIdentifier = [NSString stringWithFormat:@"%@_%p",NSStringFromClass([PageTapCollectionCell class]),self];
        _currentIndex = -1;//初始 -1 不存在
        self.view.frame = frame;
        self.delegate = delegate;
    }
    return self;
}

- (void)reloadData;{
    
    _itemsCount  = [self.delegate numberOfPages];
    
    if (!_itemsCount) return;
    
    [self.collectionTaps reloadData];
    
    [self otherConfig];
}

- (void)setDelegate:(id<LXPageDelegate>)delegate {
    _delegate = delegate;
    
    if ([self.delegate respondsToSelector:@selector(numberOfPages)] && [self.delegate respondsToSelector:@selector(lxPageTapsView:ReusableCell:)] && [self.delegate respondsToSelector:@selector(lxPageTapSizeAtIndex:)]) {
        
        _itemsCount  = [self.delegate numberOfPages];
        
        [self.view addSubview:self.collectionTaps];
        [self.view addSubview:self.pageScroll];
        //取 -1 tap的高度作为头视图高度
        self.collectionTaps.frame = CGRectMake(0, 0, self.view.bounds.size.width, [self.delegate lxPageTapSizeAtIndex:-1].height);
        self.pageScroll.frame = CGRectMake(0, CGRectGetMaxY(self.collectionTaps.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.collectionTaps.frame));
    }
    
    [self otherConfig];
}

- (void)otherConfig {
    
    if (!_itemsCount) return;
    
    self.pageScroll.contentSize = CGSizeMake(_itemsCount*self.view.bounds.size.width, CGRectGetHeight(self.pageScroll.frame));

    if ([self.delegate respondsToSelector:@selector(lxPageIndicator)] && !_indicator) {
        
        _indicator = [self.delegate lxPageIndicator];
        _indicator.hidden = YES;
        [self.collectionTaps addSubview:_indicator];
    }
    
    if ([self.delegate respondsToSelector:@selector(lxPageTapsWithinScreenAlignmentCenter)] && [self.delegate lxPageTapsWithinScreenAlignmentCenter]) {
        
        CGFloat x = 0;
        for (NSInteger i = 0; i < _itemsCount; i++) {
            
            x += [self.delegate lxPageTapSizeAtIndex:i].width;
        }
        
        if (x < [UIScreen mainScreen].bounds.size.width) {
            
            self.collectionTaps.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - x)/2, 0, x, self.collectionTaps.frame.size.height);
        }
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    
    if (currentIndex == _currentIndex) {
        
        return ;
    }
    
    if ([self.delegate respondsToSelector:@selector(lxPageShouldScrollIndex:)] && ![self.delegate lxPageShouldScrollIndex:currentIndex]) {
        
        self.pageScroll.contentOffset = CGPointMake(_currentIndex * self.view.bounds.size.width, 0);
        self.pageScroll.scrollEnabled = NO;//终止手势继续滑动
        _isPageScrollAction = NO;//滚动标志NO
        self.pageScroll.scrollEnabled = YES;//恢复滚动
        return ;
    }
    //加载主数据页面
    if ([self.delegate respondsToSelector:@selector(lxPageIndex:)] && ![self.pageLoadArray containsObject:@(currentIndex)]) {
        
        [self.pageLoadArray addObject:@(currentIndex)];
        
        UIView *pageOne = [self.delegate lxPageIndex:currentIndex];
        pageOne.frame = CGRectMake(currentIndex * self.view.bounds.size.width, 0, self.view.bounds.size.width, CGRectGetHeight(self.pageScroll.frame));
        [self.pageScroll addSubview:pageOne];
    }
    
    if (!_isPageScrollAction) {
        
        self.pageScroll.contentOffset = CGPointMake(currentIndex * self.view.bounds.size.width, 0);
        _currentIndex = currentIndex;
        if ([self.delegate respondsToSelector:@selector(lxPageDidScrollIndex:)]) {
            
            [self.delegate lxPageDidScrollIndex:_currentIndex];
        }
        
        //越屏滚动
        UICollectionViewCell *cell = [self.collectionTaps cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]];
        CGFloat x = cell.frame.origin.x;
        CGFloat w = cell.frame.size.width;
        if (!cell) {
            
            for (NSInteger i = 0; i < _currentIndex; i++) {
                
                x += [self.delegate lxPageTapSizeAtIndex:i].width;
            }
            
            w = [self.delegate lxPageTapSizeAtIndex:_currentIndex].width;
        }
        if (-self.collectionTaps.contentOffset.x + x + w > self.view.bounds.size.width) {
            
            [self.collectionTaps scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
        }
        if (-self.collectionTaps.contentOffset.x + x < 0) {
            
            [self.collectionTaps scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
        
        //指示器
        if (_indicator) {
            
            _indicator.frame = CGRectMake(x + (w - CGRectGetWidth(_indicator.frame))/2, CGRectGetHeight(self.collectionTaps.frame) - CGRectGetHeight(_indicator.frame), CGRectGetWidth(_indicator.frame), CGRectGetHeight(_indicator.frame));
            
            _indicator.hidden = NO;
            [self.collectionTaps bringSubviewToFront:_indicator];
        }
    }
}

- (UICollectionView *)collectionTaps {
    if (!_collectionTaps) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionTaps = [[UICollectionView alloc] initWithFrame:CGRectZero
                                             collectionViewLayout:flowLayout];
        _collectionTaps.backgroundColor = [UIColor clearColor];
        _collectionTaps.showsHorizontalScrollIndicator = NO;
        _collectionTaps.showsVerticalScrollIndicator = NO;
        [_collectionTaps registerClass:[PageTapCollectionCell class] forCellWithReuseIdentifier:_reuseIdentifier];
        _collectionTaps.dataSource = self;
        _collectionTaps.delegate = self;
        
    }
    return _collectionTaps;
}

- (UIScrollView *)pageScroll {
    
    if (!_pageScroll) {
        
        _pageScroll = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _pageScroll.pagingEnabled = YES;
        _pageScroll.delegate = self;
        _pageScroll.showsHorizontalScrollIndicator = NO;
    }
    return _pageScroll;
}

- (NSMutableArray *)pageLoadArray {
    
    if (!_pageLoadArray) {
        
        _pageLoadArray = [NSMutableArray array];
    }
    return _pageLoadArray;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;{
    
    return _itemsCount;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;{
    
    PageTapCollectionCell *collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
    
    return [self.delegate lxPageTapsView:indexPath.item ReusableCell:collectionCell];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;{
    
    return [self.delegate lxPageTapSizeAtIndex:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.currentIndex = indexPath.item;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == self.pageScroll && self.isPageScrollAction) {
        
        CGFloat dif = scrollView.contentOffset.x - self.scrollOffsetXStand;
        if (dif > 0 && !_isAddFlag) {
            self.currentIndex += 1;
            _isAddFlag = YES;
            return;
        }
        
        if (dif < 0 && !_isReduceFlag) {
            self.currentIndex -= 1;
            _isReduceFlag = YES;
            return;
        }
    }
}
//开始
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (scrollView == self.pageScroll) {
        _isAddFlag = NO;
        _isReduceFlag = NO;
        self.isPageScrollAction = YES;
        self.scrollOffsetXStand = self.pageScroll.contentOffset.x;
    }
}
//结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView == self.pageScroll) {
        self.isPageScrollAction = NO;
        self.currentIndex = (NSInteger)((self.pageScroll.contentOffset.x) / self.view.bounds.size.width);
    }
}

@end

@interface PageTapCollectionCell ()

@end

@implementation PageTapCollectionCell

@end

//
//  LXPageViewController.h
//  Stars
//
//  Created by livesxu on 2018/9/17.
//  Copyright © 2018年 ShuJin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PageTapCollectionCell;

@protocol LXPageDelegate <NSObject>

@required

/**
 数据源
 
 @return 展示数据量
 */
- (NSInteger)numberOfPages;
/**
 数据源
 @param index 下标
 @return page
 */
- (UIView *)lxPageIndex:(NSInteger)index;

/**
 数据头视图

 @param index 下标
 @param reusableCell 复用cell(基础cell)
 @return header
 */
- (PageTapCollectionCell *)lxPageTapsView:(NSInteger)index ReusableCell:(PageTapCollectionCell *)reusableCell;

/**
 数据头视图大小

 @param index 下标
 @return size
 */
- (CGSize)lxPageTapSizeAtIndex:(NSInteger)index;

@optional

/**
 指示器view

 @return 指示器view
 */
- (UIView *)lxPageIndicator;

/**
 是否可滚动到index - 默认YES
 @param index index
 @return 是否可滚动到index
 */
- (BOOL)lxPageShouldScrollIndex:(NSInteger)index;

/**
 标签栏在未超过一屏幕情况下居中排布

 @return 是否居中排布,默认NO 
 */
- (BOOL)lxPageTapsWithinScreenAlignmentCenter;

/**
 滚动到index
 @param index 下标
 */
- (void)lxPageDidScrollIndex:(NSInteger)index;

@end

@interface LXPageViewController : UIViewController

@property (nonatomic, assign) id<LXPageDelegate> delegate;

@property (nonatomic, assign) NSInteger currentIndex;//可设定默认index

- (instancetype)initWithFrame:(CGRect)frame Delegate:(id<LXPageDelegate>)delegate;

- (void)reloadData;

@end

@interface PageTapCollectionCell : UICollectionViewCell

@end

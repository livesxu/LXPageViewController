//
//  ViewController.m
//  LXPageDemo
//
//  Created by livesxu on 2018/9/18.
//  Copyright © 2018年 Livesxu. All rights reserved.
//

#import "ViewController.h"

#import "LXPageViewController.h"

@interface ViewController ()<LXPageDelegate>

@property (nonatomic, strong) LXPageViewController *topTitle;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self addChildViewController:self.topTitle];
    [self.view addSubview:self.topTitle.view];
}


- (LXPageViewController *)topTitle {
    
    if (!_topTitle) {
        
        _topTitle = [[LXPageViewController alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 300) Delegate:self];
        _topTitle.currentIndex = 0;
    }
    return _topTitle;
}

#pragma mark - LXPageDelegate
/**
 数据源
 
 @return 展示数据量
 */
- (NSInteger)numberOfPages;{
    
    return 10;
}
/**
 数据源
 @param index 下标
 @return page
 */
- (UIView *)lxPageIndex:(NSInteger)index;{
    

    UILabel *test = [[UILabel alloc]init];
    test.text = [NSString stringWithFormat:@"%ld <^>",index];
    return test;
}

/**
 数据头视图
 
 @param index 下标
 @param reusableCell 复用cell(基础cell)
 @return header
 */
- (PageTapCollectionCell *)lxPageTapsView:(NSInteger)index ReusableCell:(PageTapCollectionCell *)reusableCell;{
    
    NSArray *titles = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];

    //自定义样式范例
    UILabel *label = [reusableCell.contentView viewWithTag:10002];
    if (!label) {
        label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 10002;
        [reusableCell.contentView addSubview:label];
    }
    label.text = titles[index];
    
    if (index == self.selectedIndex) {
        
        label.textColor = [UIColor greenColor];
    } else {
        label.textColor = [UIColor blackColor];
    }
    
    return reusableCell;
}

/**
 数据头视图大小
 
 @param index 下标
 @return size
 */
- (CGSize)lxPageTapSizeAtIndex:(NSInteger)index;{
    
    return CGSizeMake(50, 30);
}

/**
 指示器view
 
 @return 指示器view
 */
- (UIView *)lxPageIndicator;{
    
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 3)];
    viewLine.backgroundColor = [UIColor redColor];
    return viewLine;
}

/**
 是否可滚动到index - 默认YES
 @param index index
 @return 是否可滚动到index
 */
//- (BOOL)lxPageShouldScrollIndex:(NSInteger)index;{
//
//    if (index == 2 || index == 3) {
//
//        return NO;
//    }
//    return YES;
//}
/**
 滚动到index
 @param index 下标
 */
- (void)lxPageDidScrollIndex:(NSInteger)index;{
    
    self.selectedIndex = index;
    
    [self.topTitle reloadData];
}

@end

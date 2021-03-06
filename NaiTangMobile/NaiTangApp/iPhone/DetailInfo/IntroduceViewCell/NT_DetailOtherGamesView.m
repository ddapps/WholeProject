//
//  NT_DetailOtherGamesView.m
//  NaiTangApp
//
//  Created by 张正超 on 14-3-7.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_DetailOtherGamesView.h"
#import "NT_CustomPageControl.h"
#import "NT_AppDetailInfo.h"
#import "UIButton+WebCache.h"
#import "NT_HttpEngine.h"
#import "NT_WifiBrowseImage.h"
#import "EGOImageView.h"

@implementation NT_DetailOtherGamesView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor whiteColor];
        self.otherGameArray = [NSArray array];
        /*
        UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
        lineImageView.image = [UIImage imageNamed:@"line.png"];
        [self addSubview:lineImageView];
         */
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
        lineView.backgroundColor = [UIColor colorWithHex:@"#f0f0f0"];
        [self addSubview:lineView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 24)];
        titleLabel.text = @"大家还喜欢";
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        titleLabel.backgroundColor = [UIColor clearColor];
        //titleLabel.textColor = [UIColor colorWithHex:@"#505a5f"];
        titleLabel.textColor = Text_Color_Title;
        [self addSubview:titleLabel];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 26, SCREEN_WIDTH-20, 100)];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate =self;
        [self addSubview:self.scrollView];
        
        //滚动圆点
        _pageControl = [[NT_CustomPageControl alloc] initWithFrame:CGRectMake(0, _scrollView.bottom - 10, _scrollView.width, 18)];
        if ([[[UIDevice currentDevice] systemVersion] floatValue]<7)
        {
            //小于iOS7的处理，因为iOS7默认会调用两次，但<7的版本却不会，目前没找到问题。
            _pageControl.currentPage = 0;
        }
        _pageControl.backgroundColor  = [UIColor clearColor];
        _pageControl.numberOfPages = 3;
        _pageControl.userInteractionEnabled = NO;
        [self addSubview:_pageControl];
        
        
    }
    return self;
}

//相关游戏信息
- (void)refreshWithAppInfo:(NSArray *)otherGames
{
    [self.scrollView removeAllSubViews];
    self.otherGameArray = otherGames;
    
    if (otherGames.count>0)
    {
        [otherGames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NT_AppDetailInfo *detailInfo = (NT_AppDetailInfo *)obj;
            /*
             UIButton *btn = [UIButton buttonWithFrame:CGRectMake(5+75 * idx, 5, 65, 65) image:nil target:self action:@selector(appBtnPressed:)];
             
             [btn setImageWithURL:[NSURL URLWithString:detailInfo.round_pic] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default-icon.png"]];
             
             btn.imageView.layer.cornerRadius = 15;
             btn.imageView.clipsToBounds = YES;
             btn.tag = idx;
             [self.scrollView addSubview:btn];
             
             UILabel *nameLabel = [UILabel labelWithFrame:CGRectMake(0, btn.height, btn.width, 20) textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:10]];
             nameLabel.textAlignment = UITextAlignmentCenter;
             nameLabel.text = detailInfo.game_name;
             [btn addSubview:nameLabel];
             */
            
            EGOImageView *imgView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"default-icon.png"]];
            imgView.frame = CGRectMake(5+75 * idx, 5, 65, 65);
            imgView.layer.cornerRadius = 15;
            imgView.clipsToBounds = YES;
            imgView.tag = idx;
            
            //点击图片
            imgView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(appBtnPressed:)];
            [imgView addGestureRecognizer:tap];
            [self.scrollView addSubview:imgView];
            
            //开启或关闭wifi时，图片显示方式
            NT_WifiBrowseImage *wifiImage = [[NT_WifiBrowseImage alloc] init];
            [wifiImage wifiBrowseImage:imgView urlString:detailInfo.round_pic];
            
            UILabel *nameLabel = [UILabel labelWithFrame:CGRectMake(5+75 * idx, imgView.height+2, imgView.width, 20) textColor:Text_Color_Title font:[UIFont systemFontOfSize:10]];
            nameLabel.textAlignment = UITextAlignmentCenter;
            nameLabel.text = detailInfo.game_name;
            [self.scrollView addSubview:nameLabel];
        }];
        
        self.scrollView.contentSize = CGSizeMake(((5+70)*otherGames.count), self.scrollView.height);
        self.pageControl.numberOfPages = (otherGames.count+4-1)/4;
    }
}

//其他游戏图片按钮事件
- (void)appBtnPressed:(UITapGestureRecognizer *)tap
{
    int tag = tap.view.tag;
    if (self.otherGameArray.count>0)
    {
        NT_AppDetailInfo *detailInfo = [self.otherGameArray objectAtIndex:tag];
        NSInteger appID = [detailInfo.appId integerValue];
        if (self.otherGamesViewDelegate&&[self.otherGamesViewDelegate respondsToSelector:@selector(getOtherGamesInfo:isOtherGames:)]) {
            [self.otherGamesViewDelegate getOtherGamesInfo:appID isOtherGames:YES];
        }
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;//根据坐标算页数
    _pageControl.currentPage = page;//页数赋值给pageControl的当前页
}


@end

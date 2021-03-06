//
//  NT_AppDetailInfo.h
//  NaiTangApp
//
//  Created by 张正超 on 14-3-3.
//  Copyright (c) 2014年 张正超. All rights reserved.
//
//  游戏基本信息和详情信息

#import <Foundation/Foundation.h>

//游戏类型 无限金币 纯净正版
typedef enum
{
    DownloadTypeUnknow = 0,
    DownloadTypeAppStore = 1,
    DownloadTypeNormalIpa = 2,
    DownloadTypeNolimitGold = 3,
    NOBreakDownloadTypeNolimitGold = 5,
}DownloadType;

@interface NT_AppDetailInfo : NSObject

@property (nonatomic,retain) NSMutableArray *downloadArray;
@property (nonatomic,retain) NSString *game_name,*round_pic,*score,*size,*is_much_money
,*appId,*star_count,*apple_id,*jre,*minVersion;
@property (nonatomic,strong) NSString *descriptionString,*fee,*app_version_name;
@property (nonatomic,strong) NSString *package,*categoryID,*categoryName,*stypeName;
//兼容最低版本
//@property (nonatomic,assign) CGFloat  minVersion;
+ (NT_AppDetailInfo *)inforFromDetailDic:(NSDictionary *)dic;

@end

@interface NT_DownloadAddInfo : NSObject
@property (nonatomic,retain) NSString *archives_name,*download_addr,*version_name;
@property (nonatomic,assign) DownloadType versionType;
+ (NT_DownloadAddInfo *)inforFromDetailDic:(NSDictionary *)dic;
- (DownloadType)downloadType;
@end

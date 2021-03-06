//
//  NT_UpdateAppInfo.h
//  NaiTangApp
//
//  Created by 张正超 on 14-3-2.
//  Copyright (c) 2014年 张正超. All rights reserved.
//
//  下载-可更新Model

#import <Foundation/Foundation.h>

@interface NT_UpdateAppInfo : NSObject <NSCoding>

@property (nonatomic,strong)NSString *download_addr,*game_name,*package,*version_code,*version_name,*fileSize,*iconName,*appId,*news_version;
@property (nonatomic,assign) int updateState;
@property (nonatomic,assign) BOOL isUpdateIgnore;  //是否忽略更新

+ (NT_UpdateAppInfo *)dictToInfo:(NSDictionary *)dic;
+ (BOOL)versionCompare:(NSString *)firstVersion and:(NSString *)secondVersion;

@end

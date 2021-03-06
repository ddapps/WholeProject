//
//  NT_SettingManager.m
//  NaiTangApp
//
//  Created by 张正超 on 14-3-2.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_SettingManager.h"
#import "NT_MacroDefine.h"

@implementation NT_SettingManager

+ (BOOL)showUpdateTips
{
    if (![USERDEFAULT objectForKey:KShowUpdateTipsKey]) {
        return YES;
    }
    return [USERDEFAULT boolForKey:KShowUpdateTipsKey];
}
+ (void)setShowUpdateTips:(BOOL)showUpdate
{
    [USERDEFAULT setBool:showUpdate forKey:KShowUpdateTipsKey];
    [USERDEFAULT synchronize];
}

+ (BOOL)onlyDownloadUseWifi
{
    if (![USERDEFAULT objectForKey:KOnlyDownloadUseWifi]) {
        return YES;
    }
    return [USERDEFAULT boolForKey:KOnlyDownloadUseWifi];
}
+ (void)setOnlyDownloadUseWifi:(BOOL)onlyDownloadUseWifi
{
    [USERDEFAULT setBool:onlyDownloadUseWifi forKey:KOnlyDownloadUseWifi];
    [USERDEFAULT synchronize];
}

+ (BOOL)clearDataWhenQuitNT
{
    if (![USERDEFAULT objectForKey:KClearDataWhenQuitNT]) {
        return YES;
    }
    return [USERDEFAULT boolForKey:KClearDataWhenQuitNT];
}
+ (void)setClearDataWhenQuitNT:(BOOL)clearDataWhenQuitNT
{
    [USERDEFAULT setBool:clearDataWhenQuitNT forKey:KClearDataWhenQuitNT];
    [USERDEFAULT synchronize];
}

@end

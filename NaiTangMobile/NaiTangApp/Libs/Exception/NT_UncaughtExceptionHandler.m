//
//  NT_UncaughtExceptionHandler.m
//  NaiTangApp
//
//  Created by 张正超 on 14-3-2.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_UncaughtExceptionHandler.h"
#import <libkern/OSAtomic.h>
#import <execinfo.h>

NSString * const NTUncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const NTUncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const NTUncaughtExceptionHandlerAddressKey = @"UncaughtExceptionHandlerAddressKey";

volatile int32_t NTUncaughtExceptionCount = 0;
const int32_t NTUncaughtExceptionMaximum = 10;

const NSInteger NTUncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger NTUncaughtExceptionHandlerReportAddressCount = 5;

@implementation NT_UncaughtExceptionHandler

+ (NSArray *)backtrace
{
    void * callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int i = NTUncaughtExceptionHandlerSkipAddressCount; i<NTUncaughtExceptionHandlerSkipAddressCount+NTUncaughtExceptionHandlerReportAddressCount; i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return backtrace;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (self.exceptions) {
            [self exceptionToMail:self.exceptions];
        }
        
        dismissed = YES;
    }
}

- (void)exceptionToMail:(NSException *)exception
{
    NSArray *arr = [[exception userInfo] objectForKey:NTUncaughtExceptionHandlerAddressKey];
    if (!arr) {
        arr = [[exception userInfo] objectForKey:NTUncaughtExceptionHandlerSignalKey];
    }
    NSString *urlStr = [NSString stringWithFormat:@"mailto://lixia张正超@163.com?subject=bug报告&body=程序出现异常，请将错误信息发送给我们，帮助我们及时修改，感谢您的配合!<br><br><br>" "错误详情：<br>%@<br>---------<br>%@<br>------<br>%@",[exception name],[exception reason],[arr componentsJoinedByString:@"<br>"]];
    
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [[UIApplication sharedApplication] openURL:url];
    
}

- (void)handleException:(NSException *)exception
{
    self.exceptions = exception;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"抱歉，程序出现了异常" message:[NSString stringWithFormat:@"建议您点击退出按钮并重新打开应用，然后将异常信息邮件发送给我们。若您是首次使用邮箱，请将收件人后的‘//’删除"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
    [alert show];
    
    
    
    CFRunLoopRef runLoop= CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!dismissed) {
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqualToString:NTUncaughtExceptionHandlerSignalExceptionName])
    {
        kill(getpid(), [[[exception userInfo] objectForKey:NTUncaughtExceptionHandlerSignalKey] intValue]);
    }
    else
    {
        [exception raise];
    }
}

@end

void HandleException(NSException *exception)
{
    int32_t exceptionCount = OSAtomicIncrement32(&NTUncaughtExceptionCount);
    if (exceptionCount > NTUncaughtExceptionMaximum) {
        return;
    }
    
    NSArray *callStack = [NT_UncaughtExceptionHandler backtrace];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    
    [userInfo setObject:callStack forKey:NTUncaughtExceptionHandlerAddressKey];
    
    [[[NT_UncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:[NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo]
     waitUntilDone:YES];
}
NSString* getAppInfo() {
    
    NSString *appInfo = [NSString stringWithFormat:@"App : %@ %@(%@)\nDevice : %@\nOS Version : %@ %@\n",
                         
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                         
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                         
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                         
                         [UIDevice currentDevice].model,
                         
                         [UIDevice currentDevice].systemName,
                         
                         [UIDevice currentDevice].systemVersion];
    
    return appInfo;
    
}

void SignalHandler(int signal)
{
    int32_t exceptionCount = OSAtomicIncrement32(&NTUncaughtExceptionCount);
    if (exceptionCount > NTUncaughtExceptionMaximum) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary
                                     dictionaryWithObject:[NSNumber numberWithInt:signal]
                                     forKey:NTUncaughtExceptionHandlerSignalKey];
    
    NSArray *callStack = [NT_UncaughtExceptionHandler backtrace];
    [userInfo setObject:callStack forKey:NTUncaughtExceptionHandlerAddressKey];
    
    [[[NT_UncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:[NSException
                 exceptionWithName:NTUncaughtExceptionHandlerSignalExceptionName
                 reason:[NSString stringWithFormat:@"Signal %d was raised.\n%@",signal,getAppInfo()]
                 userInfo:
                 [NSDictionary
                  dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:NTUncaughtExceptionHandlerSignalKey]]
     waitUntilDone:YES];
}


void InstallUncaughtExceptionHandler(void)
{
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL,SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}


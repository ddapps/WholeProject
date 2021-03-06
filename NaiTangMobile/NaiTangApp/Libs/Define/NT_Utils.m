//
//  NT_Utils.m
//  NaiTangApp
//
//  Created by 张正超 on 14-2-26.
//  Copyright (c) 2014年 张正超. All rights reserved.
//

#import "NT_Utils.h"

NSString *getFilePath(NSString* filename, NSString* ext) {
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *pathToUserCopyOfPlist = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", filename, ext]];
	
	if ([fileManager fileExistsAtPath:pathToUserCopyOfPlist] == NO) {
		
		
		NSString *pathToDefaultPlist = [[NSBundle mainBundle] pathForResource:filename ofType:ext];
		if ([fileManager copyItemAtPath:pathToDefaultPlist toPath:pathToUserCopyOfPlist error:&error] == NO) {
			//NSAssert1(0, @"Failed to copy data with error message '%@'.", [error localizedDescription]);
		}
		
	}
	return pathToUserCopyOfPlist;
	
}


NSString *getBundleFilePath(NSString* filename, NSString* ext) {
	return [[NSBundle mainBundle] pathForResource:filename ofType:ext];
}

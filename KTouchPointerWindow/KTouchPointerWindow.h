//
//  KTouchPointerWindow.h
//	v0.1.0
//  Created by Ito Kei on 12/03/02.
//  Copyright (c) 2012年 itok. All rights reserved.
//
/*
 * call this function to start show pointer
 * 
 * ex)
 * - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 *      KTouchPointerWindowInstall();
 *      ...
 * }
 */

#ifdef __cplusplus
extern "C" {
#endif
	
#import <UIKit/UIKit.h>

void KTouchPointerWindowInstall();
void KTouchPointerWindowInstallWithOptions(UIColor* color, CGFloat radius, NSTimeInterval fadeout);

#ifdef __cplusplus
}
#endif
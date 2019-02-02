//
//  RCTRootView+XPush.h
//  Pods-MedCRM
//
//  Created by wangcong on 2018/11/26.
//

#import <Foundation/Foundation.h>
#import <React/RCTRootView.h>

/**
 * 将RCTBridge改为适合单bridge模式，为RCTBridge添加自动引用计数功能，
 * 此功能由RCTRootView init及dealloc时实现；并在自动引用计数的基础之上
 * 为RCTBridge添加功能:在引用计数为0时，是否自动reload资源，默认为false，主要
 * 解决在非下次启动情况下使RN模块更新到最新
 *
 * Updated by wangcong on 2018/11/2.
 *
 */
@interface RCTRootView (XPush)

@end

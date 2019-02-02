//
//  RCTBridge+XPush.h
//  Pods-MedCRM
//
//  Created by wangcong on 2018/11/26.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridge.h>

/**
 * Updated by wangcong on 2018/11/2.
 * 将RCTBridge改为适合单bridge模式，为RCTBridge添加自动引用计数功能，
 * 此功能由RCTRootView init及dealloc时实现；并在自动引用计数的基础之上
 * 为RCTBridge添加功能:在引用计数为0时，是否自动reload资源，默认为true，主要
 * 解决在非下次启动情况下使RN模块更新到最新
 *
 * Updated by wangcong on 2018/11/6.
 * 新增移除已加载module的功能，当有更新退出页面后再次进入则可以立马得到最新
 *
 * Updated by wangcong on 2018/11/7.
 * 新增内存警告重新reload（在内存警告时RN页面的资源加载会不正确）
 *
 */
@interface RCTBridge (XPush)

/// 设置当持有RCTBridge的RCTRootView个数为0时，是否自动reload，此过程是通过RCTRootView的init与dealloc自动控制，默认=false
@property (nonatomic, assign) BOOL shouldReloadAfterAutomaticReferenceCountEqualZero;

@property (nonatomic, strong, readonly) NSArray<NSString *> *modules;

/// MARK: 额外添加其他业务模块
- (void)enqueueApplicationModule:(NSString *)module at:(NSURL *)bundleURL onSourceLoad:(RCTSourceLoadBlock)onSourceLoad;

/**
 * MARK: 此方法用于需要同步加载其他模块，最佳使用方式是在实现RCTBridgeDelegate中loadSourceForBridge:withBlock:调用；
 * 如果不是在RCTBridgeDelegate 代理中调用，请在代理之前invalidate当前RCTBridge
 */
- (void)loadSourceWith:(NSArray<NSString *> *)modules at:(NSArray<NSURL *> *)bundleURLs onSourceLoad:(RCTSourceLoadBlock)onSourceLoad;

/// MARK: 移除已经存在的模块包，当下次enqueueApplicationModule操作，可以加载最新版本
- (void)deleteModuleIfNeeded:(NSString *)module;

@end


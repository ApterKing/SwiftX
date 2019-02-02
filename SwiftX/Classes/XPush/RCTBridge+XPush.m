//
//  RCTBridge+XPush.m
//  Pods-MedCRM
//
//  Created by wangcong on 2018/11/26.
//

#import "RCTBridge+XPush.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <React/RCTJavaScriptLoader.h>

static NSString *kAutomaticReferenceCount = @"kAutomaticReferenceCount";
static NSString *kShouldReloadAfterAutomaticReferenceCountEqualZero = @"kShouldReloadAfterAutomaticReferenceCountEqualZero";
static NSString *kExtraModule = @"kExtraModule";

@interface RCTBridgeEnqueueError: NSError

+ (instancetype)errorWithMessage:(NSString *)message;

@end

@implementation RCTBridgeEnqueueError

+ (instancetype)errorWithMessage:(NSString *)message {
    return [RCTBridgeEnqueueError errorWithDomain:@"RNPushManagerErrorDomain" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:message, @"RNPushManagerErrorKey", nil]];
}

- (NSString *)localizedDescription {
    return [NSString stringWithFormat:@"errorDomain: %@;  code: %lu;  errorMsg: %@", self.domain, self.code, self.userInfo[@"RNPushManagerErrorKey"]];
}

@end

@interface RCTBridge (XExtraModule)

// 记录额外加载的module
@property(nonatomic, strong) NSDictionary *extraModule;

// 记录当前被多少个RCTRootView引用
@property (nonatomic, assign) NSInteger automaticReferenceCount;

@end

@implementation RCTBridge (XPush)

#pragma mark swizzling
+ (void)load {
    [RCTBridge swizzling:@selector(initWithDelegate:launchOptions:) with:@selector(swizzling_initWithDelegate:launchOptions:)];
    [RCTBridge swizzling:@selector(reload) with:@selector(swizzling_reload)];
    [RCTBridge swizzling:NSSelectorFromString(@"dealloc") with:@selector(swizzling_dealloc)];
}

+ (void)swizzling:(SEL)originalSelector with:(SEL)swizzedSelector {
    Class clazz = RCTBridge.class;
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    Method swizzedMethod = class_getInstanceMethod(clazz, swizzedSelector);
    
    if (class_addMethod(clazz, originalSelector, method_getImplementation(swizzedMethod), method_getTypeEncoding(swizzedMethod))) {
        class_replaceMethod(clazz, swizzedSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzedMethod);
    }
}

- (instancetype)swizzling_initWithDelegate:(id<RCTBridgeDelegate>)delegate launchOptions:(NSDictionary *)launchOptions {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(memoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    return [self swizzling_initWithDelegate:delegate launchOptions:launchOptions];
}

- (void)swizzling_reload {
    self.extraModule = [NSDictionary dictionary];
    objc_setAssociatedObject(self, &kShouldReloadAfterAutomaticReferenceCountEqualZero, nil, OBJC_ASSOCIATION_ASSIGN);
    [self swizzling_reload];
}

- (void)swizzling_dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self swizzling_dealloc];
}

- (void)memoryWarning {
    NSLog(@"RNPushManager  RCTBridge内存警告");
    if (self.automaticReferenceCount == 0) {
        [self reload];
    } else {
        self.shouldReloadAfterAutomaticReferenceCountEqualZero = true;
    }
}

#pragma mark getter setter
- (NSInteger)automaticReferenceCount {
    id object = objc_getAssociatedObject(self, &kAutomaticReferenceCount);
    if (object != nil) {
        return [object integerValue];
    } else {
        return 0;
    }
}

- (void)setAutomaticReferenceCount:(NSInteger)automaticReferenceCount {
    if (self.shouldReloadAfterAutomaticReferenceCountEqualZero && automaticReferenceCount == 0) {
        [self reload];
    }
    objc_setAssociatedObject(self, &kAutomaticReferenceCount, [NSNumber numberWithInteger:automaticReferenceCount], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)shouldReloadAfterAutomaticReferenceCountEqualZero {
    id object = objc_getAssociatedObject(self, &kShouldReloadAfterAutomaticReferenceCountEqualZero);
    if (object != nil) {
        return [object boolValue];
    } else {
        return false;
    }
}

- (void)setShouldReloadAfterAutomaticReferenceCountEqualZero:(BOOL)shouldReloadAfterAutomaticReferenceCountEqualZero {
    objc_setAssociatedObject(self, &kShouldReloadAfterAutomaticReferenceCountEqualZero, [NSNumber numberWithBool:shouldReloadAfterAutomaticReferenceCountEqualZero], OBJC_ASSOCIATION_ASSIGN);
}

- (NSArray<NSString *> *)modules {
    return self.extraModule.allKeys;
}

- (NSDictionary *)extraModule {
    NSDictionary *extra = objc_getAssociatedObject(self, &kExtraModule);
    if (!extra) {
        extra = [NSDictionary dictionary];
    }
    return extra;
}

- (void)setExtraModule:(NSDictionary *)extraModule {
    if (extraModule) {
        objc_setAssociatedObject(self, &kExtraModule, extraModule, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

#pragma mark 加载额外的module
- (void)enqueueApplicationModule:(NSString *)module at:(NSURL *)bundleURL onSourceLoad:(RCTSourceLoadBlock)onSourceLoad {
    // 已经加载过的module，则不需要重新加载
    if ([self.modules containsObject:module]) {
        onSourceLoad(nil, nil);
        NSLog(@"RNPushManager  enqueueApplicationModule added = yes");
        return;
    }
    NSLog(@"RNPushManager  enqueueApplicationModule  added = no");
    __weak typeof(self) weakSelf = self;
    [RCTJavaScriptLoader loadBundleAtURL:bundleURL onProgress:^(RCTLoadingProgress *progressData) {
        
    } onComplete:^(NSError *error, RCTSource *source) {
        if (error == nil) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            Class selfClazz = object_getClass(strongSelf);
            NSString *propertyName = @"batchedBridge";
            NSString *selectorName = @"enqueueApplicationScript:url:onComplete:";
            
            // 检测是否存在batchedBridge属性
            if (class_getProperty(selfClazz, propertyName.UTF8String) != nil) {
                RCTBridge *batchedBridge = [strongSelf valueForKey:propertyName];
                Class batchedClazz = object_getClass(batchedBridge);
                SEL selector = NSSelectorFromString(selectorName);
                dispatch_block_t onComplete = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableDictionary* extraModule = [NSMutableDictionary dictionaryWithDictionary:strongSelf.extraModule];
                        [extraModule setObject:bundleURL forKey:module];
                        strongSelf.extraModule = extraModule;
                        onSourceLoad(nil, source);
                    });
                };
                
                // 检测是否响应enqueueApplicationScript:url:onComplete:方法
                if (class_respondsToSelector(batchedClazz, selector)) {
                    ((void(*)(id, SEL, NSData*, NSURL*, dispatch_block_t))objc_msgSend)(batchedBridge, selector, source.data, source.url, onComplete);
                } else {
                    onSourceLoad([RCTBridgeEnqueueError errorWithMessage:[NSString stringWithFormat:@"couldn't not response %@", selectorName]], source);
                }
            } else {
                onSourceLoad([RCTBridgeEnqueueError errorWithMessage:[NSString stringWithFormat:@"couldn't not find property %@", propertyName]], source);
            }
        } else {
            onSourceLoad(error, nil);
        }
    }];
}

#pragma 加载资源，此方法如果在RCTBridgeDelete 代理loadSourceForBridge:withBlock:中调用，那么reload将会自动重新加载
- (void)loadSourceWith:(NSArray<NSString *> *)modules at:(NSArray<NSURL *> *)bundleURLs onSourceLoad:(RCTSourceLoadBlock)onSourceLoad {
    NSLog(@"RNPushManager  loadSourceWith: %@", modules);
    __weak typeof(self) weakSelf = self;
    
    // 优先加载自身的bundleURL，成功后加载其他extraModule
    [RCTJavaScriptLoader loadBundleAtURL:self.bundleURL onProgress:^(RCTLoadingProgress *progressData) {
        
    } onComplete:^(NSError *error, RCTSource *source) {
        
        // 这里需要注意的是，必须优先将bundleURL通知回调完成，才能够继续加载额外模块
        onSourceLoad(error, source);
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (modules.count != 0) {
            dispatch_after(DISPATCH_TIME_NOW + 0.5, dispatch_get_main_queue(), ^{
                strongSelf.extraModule = [NSDictionary dictionary];
                [strongSelf enqueueApplicationModules:modules at:bundleURLs onSourceLoad:^(NSError *error, RCTSource *source) {
                    NSLog(@"RNPushManager  loadSourceWith  extras  finish");
                }];
            });
        }
        
    }];
}

#pragma 同时加载更多module
- (void)enqueueApplicationModules:(NSArray<NSString *> *)modules at:(NSArray<NSURL *> *)bundleURLs onSourceLoad:(RCTSourceLoadBlock)onSourceLoad {
    
    if (modules.count != bundleURLs.count) { return; }
    
    NSLog(@"RNPushManager  enqueueApplicationModules: %@", modules);
    
    // 需要同步加载完成所有模块，才能够回调
    __block NSLock *sync_lock = [[NSLock alloc] init];
    __block NSInteger index = 0;
    for (int i = 0; i < modules.count; i++) {
        [self enqueueApplicationModule:modules[i] at:bundleURLs[i] onSourceLoad:^(NSError *error, RCTSource *source) {
            [sync_lock lock];
            index += 1;
            if (error) {
                onSourceLoad(error, source);
            } else {
                if (index == modules.count) {
                    onSourceLoad(nil, source);
                }
            }
            [sync_lock unlock];
        }];
    }
}

#pragma mark 移除指定的模块包
- (void)deleteModuleIfNeeded:(NSString *)module {
    if ([self.modules containsObject:module]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.extraModule];
        [dict removeObjectForKey:module];
        self.extraModule = dict;
    }
}

@end


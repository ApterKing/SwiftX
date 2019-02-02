//
//  RCTRootView+XPush.m
//  Pods-MedCRM
//
//  Created by wangcong on 2018/11/26.
//

#import "RCTRootView+XPush.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation RCTRootView (XPush)

+ (void)load {
    [RCTRootView swizzling:@selector(initWithBridge:moduleName:initialProperties:) with:@selector(swizzling_initWithBridge:moduleName:initialProperties:)];
    [RCTRootView swizzling:NSSelectorFromString(@"dealloc") with:@selector(swizzling_dealloc)];
}

+ (void)swizzling:(SEL)originalSelector with:(SEL)swizzedSelector {
    Class clazz = RCTRootView.class;
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    Method swizzedMethod = class_getInstanceMethod(clazz, swizzedSelector);
    
    if (class_addMethod(clazz, originalSelector, method_getImplementation(swizzedMethod), method_getTypeEncoding(swizzedMethod))) {
        class_replaceMethod(clazz, swizzedSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzedMethod);
    }
}

- (instancetype)swizzling_initWithBridge:(RCTBridge *)bridge moduleName:(NSString *)moduleName initialProperties:(NSDictionary *)initialProperties {
    [self increment:bridge automaticReferenceCount:1];
    return [self swizzling_initWithBridge:bridge moduleName:moduleName initialProperties:initialProperties];
}

- (void)swizzling_dealloc {
    [self increment:self.bridge automaticReferenceCount:-1];
    [self swizzling_dealloc];
}

- (void)increment:(RCTBridge *)bridge automaticReferenceCount:(NSInteger)count {
    Class clazz = object_getClass(bridge);
    
    SEL automaticReferenceCountSEL = NSSelectorFromString(@"automaticReferenceCount");
    SEL setAutomaticReferenceCountSEL =  NSSelectorFromString(@"setAutomaticReferenceCount:");
    if (class_respondsToSelector(clazz, automaticReferenceCountSEL) && class_respondsToSelector(clazz, setAutomaticReferenceCountSEL)) {
        NSInteger referenceCount = ((NSInteger(*)(id, SEL))objc_msgSend)(bridge, automaticReferenceCountSEL);
        referenceCount += count;
        (((void(*)(id, SEL, NSInteger))objc_msgSend)(bridge, setAutomaticReferenceCountSEL, referenceCount));
    }
}

@end


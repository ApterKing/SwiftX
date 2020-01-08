//
//  UIButton+Extension.m
//  FBusiness
//
//  Created by wangcong on 2020/1/8.
//

#import "UIButton+Extension.h"
#import <objc/runtime.h>

@implementation UIButton (Extension)

+ (void)load {
    Method originalMethod = class_getInstanceMethod([self class], @selector(initWithCoder:));
    Method swizedMethod = class_getInstanceMethod([self class], @selector(adjustInitWithCoder:));
    method_exchangeImplementations(originalMethod, swizedMethod);
}

- (instancetype)adjustInitWithCoder:(NSCoder *)aDecoder {
    [self adjustInitWithCoder:aDecoder];
    self.titleLabel.font = [UIFont fontWithDescriptor:self.titleLabel.font.fontDescriptor size:self.titleLabel.font.pointSize];
    return self;
}

@end


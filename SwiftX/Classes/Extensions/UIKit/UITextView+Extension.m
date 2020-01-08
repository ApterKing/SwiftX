//
//  UITextView+Extension.m
//  FBusiness
//
//  Created by wangcong on 2020/1/8.
//

#import "UITextView+Extension.h"
#import <objc/runtime.h>

@implementation UITextView (Extension)

+ (void)load {
    Method originalMethod = class_getInstanceMethod([self class], @selector(initWithCoder:));
    Method swizedMethod = class_getInstanceMethod([self class], @selector(adjustInitWithCoder:));
    method_exchangeImplementations(originalMethod, swizedMethod);
}

- (instancetype)adjustInitWithCoder:(NSCoder *)aDecoder {
    [self adjustInitWithCoder:aDecoder];
    self.font = [UIFont fontWithDescriptor:self.font.fontDescriptor size:self.font.pointSize];
    return self;
}

@end

//
//  UIFont+Extension.m
//  FBusiness
//
//  Created by wangcong on 2020/1/8.
//

#import "UIFont+Extension.h"
#import <objc/runtime.h>

@implementation UIFont (Extension)

+ (void)load {
    Method systemMethod = class_getClassMethod([self class], @selector(systemFontOfSize:));
    Method adjustFontMethond = class_getClassMethod([self class], @selector(adjustFontSize:));
    method_exchangeImplementations(systemMethod, adjustFontMethond);


    Method fontWithNameMethod = class_getClassMethod([self class], @selector(fontWithName:size:));
    Method adjustFontNameMethod = class_getClassMethod([self class], @selector(adjustFontName:size:));
    method_exchangeImplementations(fontWithNameMethod, adjustFontNameMethod);

    Method fontWithDescriptorMethod = class_getClassMethod([self class], @selector(fontWithDescriptor:size:));
    Method adjustFontWithDescriptorMethod = class_getClassMethod([self class], @selector(adjustFontWithDescriptor:size:));
    method_exchangeImplementations(fontWithDescriptorMethod, adjustFontWithDescriptorMethod);

    NSLog(@"font load: %@     font scale: %.2f", NSStringFromCGSize(UIScreen.mainScreen.bounds.size), UIScreen.mainScreen.bounds.size.width / 375);
}

+ (UIFont *)adjustFontSize:(CGFloat)size {
    CGFloat scale = UIScreen.mainScreen.bounds.size.width / 375;
    return [UIFont adjustFontSize:size * (scale < 1 ? 1 : scale)];
}

+ (UIFont *)adjustFontName:(NSString *)fontName size:(CGFloat)size {
    CGFloat scale = UIScreen.mainScreen.bounds.size.width / 375;
    return [UIFont adjustFontName:fontName size:size * (scale < 1 ? 1 : scale)];
}

+ (UIFont *)adjustFontWithDescriptor:(UIFontDescriptor *)descriptor size:(CGFloat)size {
    CGFloat scale = UIScreen.mainScreen.bounds.size.width / 375;
    return [UIFont adjustFontWithDescriptor:descriptor size: size * (scale < 1 ? 1 : scale)];
}

@end

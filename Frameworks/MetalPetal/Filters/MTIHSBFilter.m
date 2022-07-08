//
//  MTIHSBFilter.m
//  MetalPetal
//
//  Created by Yu Ao on 17/01/2018.
//

#import "MTIHSBFilter.h"
#import "MTIFunctionDescriptor.h"

@implementation MTIHSBFilter

- (instancetype)init {
    if (self = [super init]) {
        _hue = 0.5;
        _saturation = 0.5;
        _brightness = 0.5;
    }
    return self;
}

+ (MTIFunctionDescriptor *)fragmentFunctionDescriptor {
    return [[MTIFunctionDescriptor alloc] initWithName:@"hueSaturationBrightness"];
}

- (NSDictionary<NSString *,id> *)parameters {
    return @{@"hue": @(self.hue),
             @"saturation": @(self.saturation),
             @"brightness": @(self.brightness)
    };
}

+ (MTIAlphaTypeHandlingRule *)alphaTypeHandlingRule {
    return MTIAlphaTypeHandlingRule.generalAlphaTypeHandlingRule;
}

@end

//
//  MTILiquifyFilter.m
//  MetalPetal
//
//  Created by Yu Ao on 2019/2/14.
//

#import "MTILiquifyFilter.h"
#import "MTIFunctionDescriptor.h"
#import "MTIVector+SIMD.h"

@implementation MTILiquifyFilter

+ (MTIFunctionDescriptor *)fragmentFunctionDescriptor {
    return [[MTIFunctionDescriptor alloc] initWithName:@"liquify"];
}

- (NSDictionary<NSString *,id> *)parameters {
    return @{@"oldCenter": [MTIVector vectorWithFloat2:_oldCenter],
             @"center": [MTIVector vectorWithFloat2:_center],
             @"radius": @(_radius),
             @"pressure": @(_pressure)};
}

+ (MTIAlphaTypeHandlingRule *)alphaTypeHandlingRule {
    return MTIAlphaTypeHandlingRule.passthroughAlphaTypeHandlingRule;
}

@end

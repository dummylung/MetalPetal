//
//  MTIAlterColorFilter.m
//  Pods
//
//  Created by Yu Ao on 08/01/2018.
//

#import "MTIAlterColorFilter.h"
#import "MTIFunctionDescriptor.h"
#import "MTIVector.h"
#import "MTIVector+SIMD.h"

@implementation MTIAlterColorFilter

- (instancetype)init {
    if (self = [super init]) {
        _color = MTIColorMake(1.0, 1.0, 1.0, 1.0);
    }
    return self;
}

+ (MTIFunctionDescriptor *)fragmentFunctionDescriptor {
    return [[MTIFunctionDescriptor alloc] initWithName:@"alterColor"];
}

- (NSDictionary<NSString *,id> *)parameters {
    return @{
        @"color": [MTIVector vectorWithFloat4:MTIColorToFloat4(self.color)]
    };
}

+ (MTIAlphaTypeHandlingRule *)alphaTypeHandlingRule {
    return MTIAlphaTypeHandlingRule.passthroughAlphaTypeHandlingRule;
}

@end

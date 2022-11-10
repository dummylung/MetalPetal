//
//  MTIPixellateFilter.m
//  Pods
//
//  Created by Yu Ao on 08/01/2018.
//

#import "MTIBlackToTransparentFilter.h"
#import "MTIFunctionDescriptor.h"
#import "MTIVector.h"
#import "MTIVector+SIMD.h"

@implementation MTIBlackToTransparentFilter

- (instancetype)init {
    if (self = [super init]) {
        _color = MTIColorMake(1.0, 1.0, 1.0, 1.0);
    }
    return self;
}

+ (MTIFunctionDescriptor *)fragmentFunctionDescriptor {
    return [[MTIFunctionDescriptor alloc] initWithName:@"blackToTransparent"];
}

- (NSDictionary<NSString *,id> *)parameters {
    return @{@"color": [MTIVector vectorWithFloat4:MTIColorToFloat4(self.color)]};
}

+ (MTIAlphaTypeHandlingRule *)alphaTypeHandlingRule {
    return MTIAlphaTypeHandlingRule.passthroughAlphaTypeHandlingRule;
}

@end

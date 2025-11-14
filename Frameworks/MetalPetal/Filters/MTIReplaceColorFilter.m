//
//  MTIAlterColorFilter.m
//  Pods
//
//  Created by Yu Ao on 08/01/2018.
//

#import "MTIReplaceColorFilter.h"
#import "MTIFunctionDescriptor.h"
#import "MTIVector.h"
#import "MTIVector+SIMD.h"

@implementation MTIReplaceColorFilter

- (instancetype)init {
    if (self = [super init]) {
        _color = MTIColorMake(1.0, 1.0, 1.0, 1.0);
    }
    return self;
}

+ (MTIFunctionDescriptor *)fragmentFunctionDescriptor {
    return [[MTIFunctionDescriptor alloc] initWithName:@"replaceColor"];
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

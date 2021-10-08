//
//  MTIMask.m
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import "MTIMask.h"

@implementation MTIMask

- (instancetype)initWithContent:(MTIImage *)content component:(MTIColorComponent)component mode:(MTIMaskMode)mode scale:(CGFloat)scale depth1:(CGFloat)depth1 blendMode1:(MTIMaskBlendMode)blendMode1 depth2:(CGFloat)depth2 blendMode2:(MTIMaskBlendMode)blendMode2 {
    if (self = [super init]) {
        _content = content;
        _component = component;
        _mode = mode;
        _scale = scale;
        _depth1 = depth1;
        _blendMode1 = blendMode1;
        _depth2 = depth2;
        _blendMode2 = blendMode2;
    }
    return self;
}

- (instancetype)initWithContent:(MTIImage *)content {
    return [self initWithContent:content component:MTIColorComponentRed mode:MTIMaskModeNormal scale:1.0 depth1:1.0 blendMode1:MTIMaskBlendModeMultiply depth2:0.0 blendMode2:MTIMaskBlendModeNone];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end

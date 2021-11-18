//
//  MTIMask.m
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import "MTIMask.h"

@implementation MTIMask

- (instancetype)initWithContent:(MTIImage *)content component:(MTIColorComponent)component mode:(MTIMaskMode)mode scale:(CGFloat)scale depth:(CGFloat)depth blendMode:(MTIBlendMode)blendMode {
    if (self = [super init]) {
        _content = content;
        _component = component;
        _mode = mode;
        _scale = scale;
        _depth = depth;
        _blendMode = blendMode;
    }
    return self;
}

- (instancetype)initWithContent:(MTIImage *)content {
    return [self initWithContent:content component:MTIColorComponentRed mode:MTIMaskModeNormal scale:1.0 depth:1.0 blendMode:MTIBlendModeMultiply];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end

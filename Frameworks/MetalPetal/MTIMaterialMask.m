//
//  MTIMaterialMask.m
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import "MTIMaterialMask.h"

@implementation MTIMaterialMask

- (instancetype)initWithContent:(MTIImage *)content component:(MTIColorComponent)component mode:(MTIMaskMode)mode scale:(CGFloat)scale depth1:(CGFloat)depth1 depth1Inverted:(BOOL)depth1Inverted blendMode1:(MTIMaskBlendMode)blendMode1 depth2:(CGFloat)depth2 depth2Inverted:(BOOL)depth2Inverted blendMode2:(MTIMaskBlendMode)blendMode2 {
    if (self = [super init]) {
        _content = content;
        _component = component;
        _mode = mode;
        _scale = scale;
        _depth1 = depth1;
        _depth1Inverted = depth1Inverted;
        _blendMode1 = blendMode1;
        _depth2 = depth2;
        _depth2Inverted = depth2Inverted;
        _blendMode2 = blendMode2;
    }
    return self;
}

- (instancetype)initWithContent:(MTIImage *)content {
    return [self initWithContent:content component:MTIColorComponentRed mode:MTIMaskModeNormal scale:1.0 depth1:0.0 depth1Inverted:TRUE blendMode1:MTIMaskBlendModeOverlay depth2:0.8 depth2Inverted:FALSE blendMode2:MTIMaskBlendModeHardLight];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end

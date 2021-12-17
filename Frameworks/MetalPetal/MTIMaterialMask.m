//
//  MTIMaterialMask.m
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import "MTIMaterialMask.h"

@implementation MTIMaterialMask

- (instancetype)initWithContent:(MTIImage *)content component:(MTIColorComponent)component mode:(MTIMaskMode)mode type:(MTIMaskType)type movement:(CGFloat)movement scale:(CGFloat)scale zoom:(CGFloat)zoom rotation:(CGFloat)rotation depth:(CGFloat)depth offsetJitter:(CGPoint)offsetJitter blendMode:(MTIBlendMode)blendMode depth1:(CGFloat)depth1 depth1Inverted:(BOOL)depth1Inverted blendMode1:(MTIBlendMode)blendMode1 depth2:(CGFloat)depth2 depth2Inverted:(BOOL)depth2Inverted blendMode2:(MTIBlendMode)blendMode2 {
    if (self = [super initWithContent:content component:component mode:mode type:type movement:movement scale:scale zoom:zoom rotation:rotation depth:depth offsetJitter:offsetJitter blendMode:blendMode]) {
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
    return [self initWithContent:content component:MTIColorComponentRed mode:MTIMaskModeNormal type:MTIMaskTypeMoving movement:1.0 scale:1.0 zoom:1.0 rotation:0 depth:1 offsetJitter:CGPointZero blendMode:MTIBlendModeNormal depth1:0.2 depth1Inverted:TRUE blendMode1:MTIBlendModeOverlay depth2:0.8 depth2Inverted:FALSE blendMode2:MTIBlendModeHardLight];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end

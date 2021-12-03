//
//  MTIMask.m
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import "MTIMask.h"

@implementation MTIMask

- (instancetype)initWithContent:(MTIImage *)content component:(MTIColorComponent)component mode:(MTIMaskMode)mode type:(MTIMaskType)type movement:(CGFloat)movement scale:(CGFloat)scale zoom:(CGFloat)zoom rotation:(CGFloat)rotation depth:(CGFloat)depth offsetJitter:(CGFloat)offsetJitter blendMode:(MTIBlendMode)blendMode {
    if (self = [super init]) {
        _content = content;
        _component = component;
        _mode = mode;
        _type = type;
        _movement = movement;
        _scale = scale;
        _zoom = zoom;
        _rotation = rotation;
        _depth = depth;
        _offsetJitter = offsetJitter;
        _blendMode = blendMode;
    }
    return self;
}

- (instancetype)initWithContent:(MTIImage *)content {
    return [self initWithContent:content component:MTIColorComponentRed mode:MTIMaskModeNormal type:MTIMaskTypeMoving movement:0 scale:1.0 zoom:0 rotation:0 depth:1 offsetJitter:0 blendMode:MTIBlendModeMultiply];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end

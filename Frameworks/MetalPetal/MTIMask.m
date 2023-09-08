//
//  MTIMask.m
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import "MTIMask.h"

@implementation MTIMask

- (instancetype)initWithContent:(MTIImage *)content contentFlipOptions:(MTILayerFlipOptions)contentFlipOptions component:(MTIColorComponent)component mode:(MTIMaskMode)mode type:(MTIMaskType)type movement:(CGFloat)movement scale:(CGFloat)scale zoom:(CGFloat)zoom rotation:(CGFloat)rotation depth:(CGFloat)depth offsetJitter:(CGPoint)offsetJitter blendMode:(MTIBlendMode)blendMode position:(CGPoint)position size:(CGSize)size {
    if (self = [super init]) {
        _content = content;
        _contentFlipOptions = contentFlipOptions;
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
        _position = position;
        _size = size;
    }
    return self;
}


- (instancetype)initWithContent:(MTIImage *)content component:(MTIColorComponent)component mode:(MTIMaskMode)mode {
    return [self initWithContent:content contentFlipOptions:MTILayerFlipOptionsDonotFlip component:component mode:mode type:MTIMaskTypeMoving movement:0 scale:1.0 zoom:0 rotation:0 depth:1 offsetJitter:CGPointZero blendMode:MTIBlendModeMultiply position:CGPointZero size:CGSizeZero];
}

- (instancetype)initWithContent:(MTIImage *)content {
    return [self initWithContent:content component:MTIColorComponentRed mode:MTIMaskModeNormal];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end

//
//  MTICompositingLayer.m
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import "MTILayer.h"
#import "MTIImage.h"

@implementation MTILayer

- (instancetype)initWithContent:(MTIImage *)content contentRegion:(CGRect)contentRegion compositingMask:(MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity blendMode:(MTIBlendMode)blendMode {
    return [self initWithContent:content
                   contentRegion:contentRegion
              contentFlipOptions:MTILayerFlipOptionsDonotFlip
                 compositingMask:compositingMask
                      layoutUnit:layoutUnit
                        position:position
                            size:size
                        rotation:rotation
                         opacity:opacity
                       blendMode:blendMode];
}

- (instancetype)initWithContent:(MTIImage *)content layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity blendMode:(MTIBlendMode)blendMode {
    return [self initWithContent:content
                   contentRegion:content.extent
              contentFlipOptions:MTILayerFlipOptionsDonotFlip
                 compositingMask:nil
                      layoutUnit:layoutUnit
                        position:position
                            size:size
                        rotation:rotation
                         opacity:opacity
                       blendMode:blendMode];
}

- (instancetype)initWithContent:(MTIImage *)content contentRegion:(CGRect)contentRegion contentFlipOptions:(MTILayerFlipOptions)contentFlipOptions compositingMask:(MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity blendMode:(MTIBlendMode)blendMode {
    return [self initWithContent:content
                   contentRegion:contentRegion
              contentFlipOptions:contentFlipOptions
                 compositingMask:compositingMask
                      layoutUnit:layoutUnit
                        position:position
                            size:size
                        rotation:rotation
                         opacity:opacity
                       tintColor:MTIColorClear
                       blendMode:blendMode];
}

- (instancetype)initWithContent:(MTIImage *)content contentRegion:(CGRect)contentRegion contentFlipOptions:(MTILayerFlipOptions)contentFlipOptions compositingMask:(MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity tintColor:(MTIColor)tintColor blendMode:(MTIBlendMode)blendMode {
    return [self initWithContent:content
                   contentRegion:contentRegion
              contentFlipOptions:contentFlipOptions
                            mask:nil
                 compositingMask:compositingMask
                      layoutUnit:layoutUnit
                        position:position
                            size:size
                        rotation:rotation
                         opacity:opacity
                       tintColor:tintColor
                       blendMode:blendMode];
}

- (instancetype)initWithContent:(MTIImage *)content contentRegion:(CGRect)contentRegion contentFlipOptions:(MTILayerFlipOptions)contentFlipOptions mask:(nullable MTIMask *)mask compositingMask:(nullable MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity tintColor:(MTIColor)tintColor blendMode:(MTIBlendMode)blendMode {
    return [self initWithContent:content contentRegion:contentRegion contentFlipOptions:contentFlipOptions mask:mask compositingMask:compositingMask layoutUnit:layoutUnit position:position size:size rotation:rotation opacity:opacity cornerRadius:MTICornerRadiusMake(0) cornerCurve:MTICornerCurveCircular tintColor:tintColor blendMode:blendMode isHidden:NO scissorRect:CGRectNull];
}

- (instancetype)initWithContent:(MTIImage *)content contentRegion:(CGRect)contentRegion contentFlipOptions:(MTILayerFlipOptions)contentFlipOptions mask:(nullable MTIMask *)mask compositingMask:(nullable MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity cornerRadius:(MTICornerRadius)cornerRadius cornerCurve:(MTICornerCurve)cornerCurve tintColor:(MTIColor)tintColor blendMode:(MTIBlendMode)blendMode isHidden:(BOOL)isHidden scissorRect:(CGRect)scissorRect {
    if (self = [super init]) {
        _content = content;
        _contentRegion = contentRegion;
        _contentFlipOptions = contentFlipOptions;
        _mask = mask;
        _compositingMask = compositingMask;
        _layoutUnit = layoutUnit;
        _position = position;
        _size = size;
        _rotation = rotation;
        _opacity = opacity;
        _cornerRadius = cornerRadius;
        _cornerCurve = cornerCurve;
        _tintColor = tintColor;
        _blendMode = blendMode;
        _isHidden = isHidden;
        _scissorRect = scissorRect;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (CGSize)sizeInPixelForBackgroundSize:(CGSize)backgroundSize {
    switch (_layoutUnit) {
        case MTILayerLayoutUnitPixel:
            return _size;
        case MTILayerLayoutUnitFractionOfBackgroundSize:
            return CGSizeMake(backgroundSize.width * _size.width, backgroundSize.height * _size.height);
        default:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unknown MTILayerLayoutUnit" userInfo:@{@"Unit": @(_layoutUnit)}];
    }
}

- (CGPoint)positionInPixelForBackgroundSize:(CGSize)backgroundSize {
    switch (_layoutUnit) {
        case MTILayerLayoutUnitPixel:
            return _position;
        case MTILayerLayoutUnitFractionOfBackgroundSize:
            return CGPointMake(backgroundSize.width * _position.x, backgroundSize.height * _position.y);
        default:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unknown MTILayerLayoutUnit" userInfo:@{@"Unit": @(_layoutUnit)}];
    }
}

@end

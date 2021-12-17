//
//  MTICompositingLayer.m
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import "MTILayer.h"
#import "MTIImage.h"

@implementation MTILayer

//- (instancetype)initWithContent:(MTIImage *)content contentRegion:(CGRect)contentRegion compositingMask:(MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity blendMode:(MTIBlendMode)blendMode {
//    return [self initWithContent:content
//                   contentRegion:contentRegion
//              contentFlipOptions:MTILayerFlipOptionsDonotFlip
//                 compositingMask:compositingMask
//                      layoutUnit:layoutUnit
//                        position:position
//                            size:size
//                        rotation:rotation
//                         opacity:opacity
//                       blendMode:blendMode];
//}
//
//- (instancetype)initWithContent:(MTIImage *)content layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity blendMode:(MTIBlendMode)blendMode {
//    return [self initWithContent:content
//                   contentRegion:content.extent
//              contentFlipOptions:MTILayerFlipOptionsDonotFlip
//                 compositingMask:nil
//                      layoutUnit:layoutUnit
//                        position:position
//                            size:size
//                        rotation:rotation
//                         opacity:opacity
//                       blendMode:blendMode];
//}
//
//- (instancetype)initWithContent:(MTIImage *)content contentRegion:(CGRect)contentRegion contentFlipOptions:(MTILayerFlipOptions)contentFlipOptions compositingMask:(MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity blendMode:(MTIBlendMode)blendMode {
//    return [self initWithContent:content
//                   contentRegion:contentRegion
//              contentFlipOptions:contentFlipOptions
//                 compositingMask:compositingMask
//                      layoutUnit:layoutUnit
//                        position:position
//                            size:size
//                        rotation:rotation
//                         opacity:opacity
//                       tintColor:MTIColorClear
//                       blendMode:blendMode];
//}
//
//- (instancetype)initWithContent:(MTIImage *)content contentRegion:(CGRect)contentRegion contentFlipOptions:(MTILayerFlipOptions)contentFlipOptions compositingMask:(MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity tintColor:(MTIColor)tintColor blendMode:(MTIBlendMode)blendMode {
//    return [self initWithContent:content
//                   contentRegion:contentRegion
//              contentFlipOptions:contentFlipOptions
//                            mask:nil
//                 compositingMask:compositingMask
//                      layoutUnit:layoutUnit
//                        position:position
//                            size:size
//                        rotation:rotation
//                         opacity:opacity
//                       tintColor:tintColor
//                       blendMode:blendMode];
//}
//
//- (instancetype)initWithContent:(MTIImage *)content contentRegion:(CGRect)contentRegion contentFlipOptions:(MTILayerFlipOptions)contentFlipOptions mask:(nullable MTIMask *)mask compositingMask:(nullable MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity tintColor:(MTIColor)tintColor blendMode:(MTIBlendMode)blendMode {
//    return [self initWithContent:content
//                   contentRegion:contentRegion
//              contentFlipOptions:contentFlipOptions
//                            mask:mask
//                 compositingMask:compositingMask
//                      layoutUnit:layoutUnit
//                        position:position
//                            size:size
//                        rotation:rotation
//                         opacity:opacity
//                    cornerRadius:MTICornerRadiusMake(0)
//                     cornerCurve:MTICornerCurveCircular
//                       tintColor:tintColor
//                       blendMode:blendMode
//                        fillMode:MTILayerFillModeNormal];
//}

- (instancetype)initWithContent:(MTIImage *)content contentRegion:(CGRect)contentRegion mask:(MTIMask *)mask compositingMask:(MTIMask *)compositingMask materialMask:(MTIMaterialMask *)materialMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position startPosition:(CGPoint)startPosition size:(CGSize)size startSize:(CGSize)startSize rotation:(float)rotation opacity:(float)opacity cornerRadius:(MTICornerRadius)cornerRadius cornerCurve:(MTICornerCurve)cornerCurve tintColor:(MTIColor)tintColor blendMode:(nonnull MTIBlendMode)blendMode renderingMode:(MTILayerRenderingMode)renderingMode renderingBlendMode:(MTIBlendMode)renderingBlendMode fillMode:(MTILayerFillMode)fillMode shape:(MTIShape *)shape {
    if (self = [super init]) {
        _content = content;
        _contentRegion = contentRegion;
        _mask = mask;
        _compositingMask = compositingMask;
        _materialMask = materialMask;
        _layoutUnit = layoutUnit;
        _position = position;
        _startPosition = startPosition;
        _size = size;
        _startSize = startSize;
        _rotation = rotation;
        _opacity = opacity;
        _cornerRadius = cornerRadius;
        _cornerCurve = cornerCurve;
        _tintColor = tintColor;
        _blendMode = blendMode;
        _renderingMode = renderingMode;
        _renderingBlendMode = renderingBlendMode;
        _fillMode = fillMode;
        _shape = shape;
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

- (CGSize)startSizeInPixelForBackgroundSize:(CGSize)backgroundSize {
    switch (_layoutUnit) {
        case MTILayerLayoutUnitPixel:
            return _startSize;
        case MTILayerLayoutUnitFractionOfBackgroundSize:
            return CGSizeMake(backgroundSize.width * _startSize.width, backgroundSize.height * _startSize.height);
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

- (CGPoint)startPositionInPixelForBackgroundSize:(CGSize)backgroundSize {
    switch (_layoutUnit) {
        case MTILayerLayoutUnitPixel:
            return _startPosition;
        case MTILayerLayoutUnitFractionOfBackgroundSize:
            return CGPointMake(backgroundSize.width * _startPosition.x, backgroundSize.height * _startPosition.y);
        default:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unknown MTILayerLayoutUnit" userInfo:@{@"Unit": @(_layoutUnit)}];
    }
}

@end

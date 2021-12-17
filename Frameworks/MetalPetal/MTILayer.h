//
//  MTICompositingLayer.h
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import <CoreGraphics/CoreGraphics.h>
#if __has_include(<MetalPetal/MetalPetal.h>)
#import <MetalPetal/MTIBlendModes.h>
#import <MetalPetal/MTIColor.h>
#import <MetalPetal/MTICorner.h>
#import <MetalPetal/MTIShape.h>
#import <MetalPetal/MTIMaterialMask.h>
#else
#import "MTIBlendModes.h"
#import "MTIColor.h"
#import "MTICorner.h"
#import "MTIShape.h"
#import "MTIMaterialMask.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class MTIImage, MTIMask, MTIMaterialMask;

typedef NS_CLOSED_ENUM(NSInteger, MTILayerLayoutUnit) {
    MTILayerLayoutUnitPixel,
    MTILayerLayoutUnitFractionOfBackgroundSize
} NS_SWIFT_NAME(MTILayer.LayoutUnit);


typedef NS_ENUM(NSInteger, MTILayerFillMode) {
    MTILayerFillModeNormal,
    MTILayerFillModeSubstract
} NS_SWIFT_NAME(MTILayer.FillMode);

typedef NS_ENUM(NSInteger, MTILayerRenderingMode) {
    MTILayerRenderingModeLightGlaze,
    MTILayerRenderingModeIntenseBlending
} NS_SWIFT_NAME(MTILayer.RenderingMode);


/// A MTILayer represents a compositing layer for MTIMultilayerCompositingFilter. MTILayers use a UIKit like coordinate system.
__attribute__((objc_subclassing_restricted))
@interface MTILayer: NSObject <NSCopying>

@property (nonatomic, strong, readonly) MTIImage *content;

@property (nonatomic, readonly) CGRect contentRegion; //pixel

/// A mask that applies to the `content` of the layer. This mask is resized and aligned with the layer.
@property (nonatomic, strong, readonly, nullable) MTIMask *mask;

/// A mask that applies to the `content` of the layer. This mask is resized and aligned with the background.
@property (nonatomic, strong, readonly, nullable) MTIMask *compositingMask;

@property (nonatomic, strong, readonly, nullable) MTIMaterialMask *materialMask;

@property (nonatomic, readonly) MTILayerLayoutUnit layoutUnit;

@property (nonatomic, readonly) CGPoint position;

@property (nonatomic, readonly) CGPoint startPosition;

@property (nonatomic, readonly) CGSize size;

@property (nonatomic, readonly) CGSize startSize;

@property (nonatomic, readonly) float rotation; //rad

@property (nonatomic, readonly) float opacity;

@property (nonatomic, readonly) MTICornerRadius cornerRadius;

@property (nonatomic, readonly) MTICornerCurve cornerCurve;

/// Tint the content to with the color. If the tintColor's alpha is zero original content is rendered.
@property (nonatomic, readonly) MTIColor tintColor;

@property (nonatomic, copy, readonly) MTIBlendMode blendMode;

@property (nonatomic, readonly) MTILayerRenderingMode renderingMode;

@property (nonatomic, copy, readonly) MTIBlendMode renderingBlendMode;

@property (nonatomic, readonly) MTILayerFillMode fillMode;

@property (nonatomic, readonly) MTIShape *shape;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

//- (instancetype)initWithContent:(MTIImage *)content layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity blendMode:(MTIBlendMode)blendMode;
//
//- (instancetype)initWithContent:(MTIImage *)content contentRegion:(CGRect)contentRegion compositingMask:(nullable MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity blendMode:(MTIBlendMode)blendMode;
//
//- (instancetype)initWithContent:(MTIImage *)content contentRegion:(CGRect)contentRegion contentFlipOptions:(MTILayerFlipOptions)contentFlipOptions compositingMask:(nullable MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity blendMode:(MTIBlendMode)blendMode;
//
//- (instancetype)initWithContent:(MTIImage *)content contentRegion:(CGRect)contentRegion contentFlipOptions:(MTILayerFlipOptions)contentFlipOptions compositingMask:(nullable MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity tintColor:(MTIColor)tintColor blendMode:(MTIBlendMode)blendMode;
//
//- (instancetype)initWithContent:(MTIImage *)content contentRegion:(CGRect)contentRegion contentFlipOptions:(MTILayerFlipOptions)contentFlipOptions mask:(nullable MTIMask *)mask compositingMask:(nullable MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity tintColor:(MTIColor)tintColor blendMode:(MTIBlendMode)blendMode;

- (instancetype)initWithContent:(MTIImage *)content contentRegion:(CGRect)contentRegion mask:(nullable MTIMask *)mask compositingMask:(nullable MTIMask *)compositingMask materialMask:(nullable MTIMaterialMask *)materialMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position startPosition:(CGPoint)startPosition size:(CGSize)size startSize:(CGSize)startSize rotation:(float)rotation opacity:(float)opacity cornerRadius:(MTICornerRadius)cornerRadius cornerCurve:(MTICornerCurve)cornerCurve tintColor:(MTIColor)tintColor blendMode:(MTIBlendMode)blendMode renderingMode:(MTILayerRenderingMode)renderingMode renderingBlendMode:(MTIBlendMode)renderingBlendMode fillMode:(MTILayerFillMode)fillMode shape:(MTIShape *)shape NS_DESIGNATED_INITIALIZER;

- (CGSize)sizeInPixelForBackgroundSize:(CGSize)backgroundSize;

- (CGSize)startSizeInPixelForBackgroundSize:(CGSize)backgroundSize;

- (CGPoint)positionInPixelForBackgroundSize:(CGSize)backgroundSize;

- (CGPoint)startPositionInPixelForBackgroundSize:(CGSize)backgroundSize;

@end

NS_ASSUME_NONNULL_END


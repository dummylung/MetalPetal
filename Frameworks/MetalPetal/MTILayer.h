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
#else
#import "MTIBlendModes.h"
#import "MTIColor.h"
#import "MTICorner.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class MTIImage, MTIMask, MTILayerPattern;

typedef NS_CLOSED_ENUM(NSInteger, MTILayerLayoutUnit) {
    MTILayerLayoutUnitPixel,
    MTILayerLayoutUnitFractionOfBackgroundSize
} NS_SWIFT_NAME(MTILayer.LayoutUnit);

typedef NS_OPTIONS(NSUInteger, MTILayerFlipOptions) {
    MTILayerFlipOptionsDonotFlip = 0,
    MTILayerFlipOptionsFlipVertically = 1 << 0,
    MTILayerFlipOptionsFlipHorizontally = 1 << 1,
} NS_SWIFT_NAME(MTILayer.FlipOptions);

typedef NS_CLOSED_ENUM(NSInteger, MTILayerPatternType) {
    MTILayerPatternTypeSeamlessSquareMirror = 0,
    MTILayerPatternTypeSeamlessCrossMirror = 1,
    MTILayerPatternTypeSeamlessPyramidMirror = 2,
    MTILayerPatternTypeSeamedHalfDrop = 3,
    MTILayerPatternTypeSeamedHalfDropFlip = 4,
    MTILayerPatternTypeSeamedHalfBrick = 5,
    MTILayerPatternTypeSeamedHalfBrickFlip = 6,
    MTILayerPatternTypeSeamedFullDrop = 7,
    MTILayerPatternTypeSeamedPipe = 8,
    MTILayerPatternTypeSeamedHorizontalZigzag = 9,
    MTILayerPatternTypeSeamedVerticalZigzag = 10,
    MTILayerPatternTypeSeamedBasketWeave = 20,
    MTILayerPatternTypeSeamedWave = 11,
    MTILayerPatternTypeSeamedMountain = 12,
    MTILayerPatternTypeSeamedChevron = 13,
    MTILayerPatternTypeSeamedWindmill = 14,
    MTILayerPatternTypeSeamedCurrent = 15,
    MTILayerPatternTypeSeamedFishScale = 16,
    MTILayerPatternTypeSeamedFallenLeaves = 17,
    MTILayerPatternTypeSeamedBowtie = 18,
    MTILayerPatternTypeSeamedButterfly = 19
} NS_SWIFT_NAME(MTILayer.PatternType);


/// A MTILayer represents a compositing layer for MTIMultilayerCompositingFilter. MTILayers use a UIKit like coordinate system.
__attribute__((objc_subclassing_restricted))
@interface MTILayer: NSObject <NSCopying>

@property (nonatomic, strong, readonly) NSUUID *refId;

@property (nonatomic, strong, readonly) MTIImage *content;

@property (nonatomic, readonly) CGRect contentRegion; //pixel

@property (nonatomic, readonly) MTILayerFlipOptions contentFlipOptions;

/// A mask that applies to the `content` of the layer. This mask is resized and aligned with the layer.
@property (nonatomic, strong, readonly, nullable) MTIMask *mask;

/// A mask that applies to the `content` of the layer. This mask is resized and aligned with the background.
@property (nonatomic, strong, readonly, nullable) MTIMask *compositingMask;

@property (nonatomic, readonly) MTILayerLayoutUnit layoutUnit;

@property (nonatomic, readonly) CGPoint position;

@property (nonatomic, readonly) CGSize size;

@property (nonatomic, readonly) float rotation; //rad

@property (nonatomic, readonly) float opacity;

@property (nonatomic, readonly) MTICornerRadius cornerRadius;

@property (nonatomic, readonly) MTICornerCurve cornerCurve;

/// Tint the content to with the color. If the tintColor's alpha is zero original content is rendered.
@property (nonatomic, readonly) MTIColor tintColor;

@property (nonatomic, copy, readonly) MTIBlendMode blendMode;

@property (nonatomic, readonly) BOOL isHidden;

@property (nonatomic, readonly, nullable) NSArray<NSValue *> *scissorRects;

@property (nonatomic, readonly, nullable) MTILayerPattern *pattern;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithRefId:(nullable NSUUID *)refId content:(MTIImage *)content layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity blendMode:(MTIBlendMode)blendMode;

- (instancetype)initWithRefId:(nullable NSUUID *)refId content:(MTIImage *)content contentRegion:(CGRect)contentRegion compositingMask:(nullable MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity blendMode:(MTIBlendMode)blendMode;

- (instancetype)initWithRefId:(nullable NSUUID *)refId content:(MTIImage *)content contentRegion:(CGRect)contentRegion contentFlipOptions:(MTILayerFlipOptions)contentFlipOptions compositingMask:(nullable MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity blendMode:(MTIBlendMode)blendMode;

- (instancetype)initWithRefId:(nullable NSUUID *)refId content:(MTIImage *)content contentRegion:(CGRect)contentRegion contentFlipOptions:(MTILayerFlipOptions)contentFlipOptions compositingMask:(nullable MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity tintColor:(MTIColor)tintColor blendMode:(MTIBlendMode)blendMode;

- (instancetype)initWithRefId:(nullable NSUUID *)refId content:(MTIImage *)content contentRegion:(CGRect)contentRegion contentFlipOptions:(MTILayerFlipOptions)contentFlipOptions mask:(nullable MTIMask *)mask compositingMask:(nullable MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity tintColor:(MTIColor)tintColor blendMode:(MTIBlendMode)blendMode;

- (instancetype)initWithRefId:(nullable NSUUID *)refId content:(MTIImage *)content contentRegion:(CGRect)contentRegion contentFlipOptions:(MTILayerFlipOptions)contentFlipOptions mask:(nullable MTIMask *)mask compositingMask:(nullable MTIMask *)compositingMask layoutUnit:(MTILayerLayoutUnit)layoutUnit position:(CGPoint)position size:(CGSize)size rotation:(float)rotation opacity:(float)opacity cornerRadius:(MTICornerRadius)cornerRadius cornerCurve:(MTICornerCurve)cornerCurve tintColor:(MTIColor)tintColor blendMode:(MTIBlendMode)blendMode isHidden:(BOOL)isHidden scissorRects:(nullable NSArray <NSValue *> *)scissorRects pattern:(nullable MTILayerPattern *)pattern NS_DESIGNATED_INITIALIZER;

- (CGSize)sizeInPixelForBackgroundSize:(CGSize)backgroundSize;

- (CGPoint)positionInPixelForBackgroundSize:(CGSize)backgroundSize;

@end

NS_ASSUME_NONNULL_END


//
//  MTIMask.h
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import <UIKit/UIKit.h>

#if __has_include(<MetalPetal/MetalPetal.h>)
#import <MetalPetal/MTIColor.h>
#else
#import "MTIColor.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class MTIImage;

typedef NS_ENUM(NSInteger, MTIMaskMode) {
    MTIMaskModeNormal = 0,
    MTIMaskModeOneMinusMaskValue
};

typedef CF_ENUM (NSInteger, MTIMaskBlendMode) {
    MTIMaskBlendModeNone = 0,
    MTIMaskBlendModeMultiply,
    MTIMaskBlendModeDarken,
    MTIMaskBlendModeColourBurn,
    MTIMaskBlendModeLinearBurn,
    MTIMaskBlendModeLighten,
    MTIMaskBlendModeColourDodge,
    MTIMaskBlendModeOverlay,
    MTIMaskBlendModeHardMix,
    MTIMaskBlendModeDifference,
    MTIMaskBlendModeSubtract,
    MTIMaskBlendModeDivide,
    MTIMaskBlendModeHeight,
    MTIMaskBlendModeLinearHeight
};

__attribute__((objc_subclassing_restricted))
@interface MTIMask : NSObject <NSCopying>

@property (nonatomic, strong, readonly) MTIImage *content;

@property (nonatomic, readonly) MTIColorComponent component;

@property (nonatomic, readonly) MTIMaskMode mode;

@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGFloat depth1;
@property (nonatomic, readonly) MTIMaskBlendMode blendMode1;
@property (nonatomic, readonly) CGFloat depth2;
@property (nonatomic, readonly) MTIMaskBlendMode blendMode2;
@property (nonatomic, readonly) CGFloat brightness;
@property (nonatomic, readonly) CGFloat contrast;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithContent:(MTIImage *)content component:(MTIColorComponent)component mode:(MTIMaskMode)mode scale:(CGFloat)scale depth1:(CGFloat)depth1 blendMode1:(MTIMaskBlendMode)blendMode1 depth2:(CGFloat)depth2 blendMode2:(MTIMaskBlendMode)blendMode2 NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithContent:(MTIImage *)content;

@end

NS_ASSUME_NONNULL_END

//
//  MTIMaterialMask.h
//  MetalPetal
//
//  Created by Yu Ao on 14/11/2017.
//

#import <UIKit/UIKit.h>

#if __has_include(<MetalPetal/MetalPetal.h>)
#import <MetalPetal/MTIColor.h>
#import <MetalPetal/MTIMask.h>
#else
#import "MTIColor.h"
#import "MTIMask.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class MTIImage;

__attribute__((objc_subclassing_restricted))
@interface MTIMaterialMask : MTIMask <NSCopying>

@property (nonatomic, readonly) CGFloat depth1;
@property (nonatomic, readonly) BOOL depth1Inverted;
@property (nonatomic, readonly) MTIBlendMode blendMode1;
@property (nonatomic, readonly) CGFloat depth2;
@property (nonatomic, readonly) BOOL depth2Inverted;
@property (nonatomic, readonly) MTIBlendMode blendMode2;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithContent:(MTIImage *)content component:(MTIColorComponent)component mode:(MTIMaskMode)mode type:(MTIMaskType)type movement:(CGFloat)movement scale:(CGFloat)scale zoom:(CGFloat)zoom rotation:(CGFloat)rotation depth:(CGFloat)depth offsetJitter:(CGPoint)offsetJitter blendMode:(MTIBlendMode)blendMode depth1:(CGFloat)depth1 depth1Inverted:(BOOL)depth1Inverted blendMode1:(MTIBlendMode)blendMode1 depth2:(CGFloat)depth2 depth2Inverted:(BOOL)depth2Inverted blendMode2:(MTIBlendMode)blendMode2 NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithContent:(MTIImage *)content;

@end

NS_ASSUME_NONNULL_END

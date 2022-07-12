//
//  MTILiquifyFilter.h
//  MetalPetal
//
//  Created by Yu Ao on 2019/2/14.
//

#import <simd/simd.h>
#if __has_include(<MetalPetal/MetalPetal.h>)
#import <MetalPetal/MTIUnaryImageRenderingFilter.h>
#else
#import "MTIUnaryImageRenderingFilter.h"
#endif

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface MTILiquifyFilter : MTIUnaryImageRenderingFilter

/// Specifies the center of the distortion in pixels.
@property (nonatomic) simd_float2 oldCenter;

/// Specifies the center of the distortion in pixels.
@property (nonatomic) simd_float2 center;


/// Specifies the radius of the distortion in pixels.
@property (nonatomic) float radius;

/// Specifies the pressure of the distortion, 0 being no-change.
@property (nonatomic) float pressure;

@end

NS_ASSUME_NONNULL_END

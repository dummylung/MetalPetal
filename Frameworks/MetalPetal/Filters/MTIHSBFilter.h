//
//  MTIHSBFilter.h
//  MetalPetal
//
//  Created by Yu Ao on 17/01/2018.
//

#import <simd/simd.h>
#if __has_include(<MetalPetal/MetalPetal.h>)
#import <MetalPetal/MTIUnaryImageRenderingFilter.h>
#else
#import "MTIUnaryImageRenderingFilter.h"
#endif

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface MTIHSBFilter : MTIUnaryImageRenderingFilter

@property (nonatomic) float hue;
@property (nonatomic) float saturation;
@property (nonatomic) float brightness;

@end

NS_ASSUME_NONNULL_END

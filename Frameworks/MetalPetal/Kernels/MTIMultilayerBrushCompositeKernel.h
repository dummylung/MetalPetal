//
//  MTIMultilayerBrushCompositeKernel.h
//  MetalPetal
//
//  Created by YuAo on 27/09/2017.
//

#import <Metal/Metal.h>
#if __has_include(<MetalPetal/MetalPetal.h>)
#import <MetalPetal/MTIKernel.h>
#import <MetalPetal/MTITextureDimensions.h>
#import <MetalPetal/MTIAlphaType.h>
#else
#import "MTIKernel.h"
#import "MTITextureDimensions.h"
#import "MTIAlphaType.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class MTIRenderPipeline, MTIFunctionDescriptor, MTIContext, MTIImage, MTIBrushLayer, MTIBlendFunctionDescriptors;

__attribute__((objc_subclassing_restricted))
@interface MTIMultilayerBrushCompositeKernel : NSObject <MTIKernel>

+ (MTIBlendFunctionDescriptors *)blendFunctionDescriptors;

- (MTIImage *)applyToBackgroundImage:(MTIImage *)image
 backgroundImageBeforeCurrentSession:(MTIImage *)backgroundImageBeforeCurrentSession
                              layers:(NSArray<MTIBrushLayer *> *)layers
                   rasterSampleCount:(NSUInteger)rasterSampleCount
                     outputAlphaType:(MTIAlphaType)outputAlphaType
             outputTextureDimensions:(MTITextureDimensions)outputTextureDimensions
                   outputPixelFormat:(MTLPixelFormat)outputPixelFormat;

@end

@class MTIRenderGraphNode;

FOUNDATION_EXPORT void MTIMultilayerCompositingRenderGraphNodeOptimize(MTIRenderGraphNode *node);

NS_ASSUME_NONNULL_END

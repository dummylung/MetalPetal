//
//  MTIContext+Rendering.h
//  Pods
//
//  Created by YuAo on 23/07/2017.
//
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#if __has_include(<MetalPetal/MetalPetal.h>)
#import <MetalPetal/MTIContext.h>
#import <MetalPetal/MTIAlphaType.h>
#else
#import "MTIContext.h"
#import "MTIAlphaType.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class MTIDrawableRenderingRequest, MTICIImageCreationOptions, MTIRenderTask;

@interface MTIContext (Rendering)

- (BOOL)renderImage:(MTIImage *)image toDrawableWithRequest:(MTIDrawableRenderingRequest *)request error:(NSError **)error NS_SWIFT_NAME(render(_:toDrawableWithRequest:));

- (nullable CIImage *)createCIImageFromImage:(MTIImage *)image error:(NSError **)error NS_SWIFT_NAME(makeCIImage(from:));

- (nullable CIImage *)createCIImageFromImage:(MTIImage *)image options:(MTICIImageCreationOptions *)options error:(NSError **)error NS_SWIFT_NAME(makeCIImage(from:options:));

- (BOOL)renderImage:(MTIImage *)image toCVPixelBuffer:(CVPixelBufferRef)pixelBuffer error:(NSError **)error NS_SWIFT_NAME(render(_:to:));

- (BOOL)renderImage:(MTIImage *)image toCVPixelBuffer:(CVPixelBufferRef)pixelBuffer sRGB:(BOOL)sRGB error:(NSError **)error NS_SWIFT_NAME(render(_:to:sRGB:));

- (nullable CGImageRef)createCGImageFromImage:(MTIImage *)image error:(NSError **)error CF_RETURNS_RETAINED NS_SWIFT_NAME(makeCGImage(from:));

// Deprecated, use `makeCGImage(from:colorSpace:)` instead.
- (nullable CGImageRef)createCGImageFromImage:(MTIImage *)image sRGB:(BOOL)sRGB error:(NSError **)error CF_RETURNS_RETAINED NS_SWIFT_NAME(makeCGImage(from:sRGB:));

- (nullable CGImageRef)createCGImageFromImage:(MTIImage *)image colorSpace:(nullable CGColorSpaceRef)colorSpace error:(NSError **)error CF_RETURNS_RETAINED NS_SWIFT_NAME(makeCGImage(from:colorSpace:));

- (nullable MTIRenderTask *)startTaskToRenderImage:(MTIImage *)image toCVPixelBuffer:(CVPixelBufferRef)pixelBuffer sRGB:(BOOL)sRGB error:(NSError **)error NS_SWIFT_NAME(startTask(toRender:to:sRGB:));

// Deprecated, use `startTask(toCreate:from:colorSpace:)` instead.
- (nullable MTIRenderTask *)startTaskToCreateCGImage:(CF_RETURNS_RETAINED __nullable CGImageRef * __nonnull)outImage fromImage:(MTIImage *)image sRGB:(BOOL)sRGB error:(NSError **)error NS_SWIFT_NAME(startTask(toCreate:from:sRGB:));

- (nullable MTIRenderTask *)startTaskToCreateCGImage:(CF_RETURNS_RETAINED __nullable CGImageRef * __nonnull)outImage fromImage:(MTIImage *)image colorSpace:(nullable CGColorSpaceRef)colorSpace error:(NSError **)error NS_SWIFT_NAME(startTask(toCreate:from:colorSpace:));

- (nullable MTIRenderTask *)startTaskToRenderImage:(MTIImage *)image toDrawableWithRequest:(MTIDrawableRenderingRequest *)request error:(NSError **)error NS_SWIFT_NAME(startTask(toRender:toDrawableWithRequest:));

// Deprecated, use `startTask(toCreate:from:colorSpace:completion:)` instead.
- (nullable MTIRenderTask *)startTaskToCreateCGImage:(CF_RETURNS_RETAINED __nullable CGImageRef * __nonnull)outImage fromImage:(MTIImage *)image sRGB:(BOOL)sRGB error:(NSError **)error completion:(nullable void (^)(MTIRenderTask *task))completion NS_SWIFT_NAME(startTask(toCreate:from:sRGB:completion:));

- (nullable MTIRenderTask *)startTaskToCreateCGImage:(CF_RETURNS_RETAINED __nullable CGImageRef * __nonnull)outImage fromImage:(MTIImage *)image colorSpace:(nullable CGColorSpaceRef)colorSpace error:(NSError **)error completion:(nullable void (^)(MTIRenderTask *task))completion NS_SWIFT_NAME(startTask(toCreate:from:colorSpace:completion:));

- (nullable MTIRenderTask *)startTaskToRenderImage:(MTIImage *)image toCVPixelBuffer:(CVPixelBufferRef)pixelBuffer sRGB:(BOOL)sRGB error:(NSError **)error completion:(nullable void (^)(MTIRenderTask *task))completion NS_SWIFT_NAME(startTask(toRender:to:sRGB:completion:));

/// The default destinationAlphaType is premultiplied.
- (nullable MTIRenderTask *)startTaskToRenderImage:(MTIImage *)image
                                   toCVPixelBuffer:(CVPixelBufferRef)pixelBuffer
                                              sRGB:(BOOL)sRGB
                              destinationAlphaType:(MTIAlphaType)destinationAlphaType
                                             error:(NSError **)error
                                        completion:(nullable void (^)(MTIRenderTask *task))completion NS_SWIFT_NAME(startTask(toRender:to:sRGB:destinationAlphaType:completion:));

- (nullable MTIRenderTask *)startTaskToRenderImage:(MTIImage *)image toDrawableWithRequest:(MTIDrawableRenderingRequest *)request error:(NSError **)error completion:(nullable void (^)(MTIRenderTask *task))completion NS_SWIFT_NAME(startTask(toRender:toDrawableWithRequest:completion:));

- (nullable MTIRenderTask *)startTaskToRenderImage:(MTIImage *)image
                                         toTexture:(id<MTLTexture>)texture
                              destinationAlphaType:(MTIAlphaType)destinationAlphaType
                                             error:(NSError **)error
                                        completion:(nullable void (^)(MTIRenderTask *task))completion NS_SWIFT_NAME(startTask(toRender:to:destinationAlphaType:completion:));

/// Render the image to nowhere.
- (nullable MTIRenderTask *)startTaskToRenderImage:(MTIImage *)image
                                             error:(NSError **)error
                                        completion:(nullable void (^)(MTIRenderTask *task))completion NS_SWIFT_NAME(startTask(toRender:completion:));

- (void)startTaskToPreloadImage:(MTIImage *)image NS_SWIFT_NAME(startTask(toPreload:));

@end

NS_ASSUME_NONNULL_END

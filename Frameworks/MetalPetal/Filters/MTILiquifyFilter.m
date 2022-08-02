//
//  MTILiquifyFilter.m
//  MetalPetal
//
//  Created by Yu Ao on 2019/2/14.
//

#import "MTILiquifyFilter.h"
#import "MTIFunctionDescriptor.h"
#import "MTIVector+SIMD.h"
//#import "MTIRenderPipelineKernel.h"
//#import "MTIRenderPassOutputDescriptor.h"
//#import "MTIVertex.h"
//#import "MTIUnaryImageRenderingFilter.h"
//#import "MTIImage.h"

@implementation MTILiquifyFilter
//@synthesize outputPixelFormat = _outputPixelFormat;
//@synthesize inputImage = _inputImage;


+ (MTIFunctionDescriptor *)fragmentFunctionDescriptor {
    return [[MTIFunctionDescriptor alloc] initWithName:@"liquify"];
}

- (NSDictionary<NSString *,id> *)parameters {
    return @{@"oldCenter": [MTIVector vectorWithFloat2:_oldCenter],
             @"center": [MTIVector vectorWithFloat2:_center],
             @"radius": @(_radius),
             @"pressure": @(_pressure)};
}

+ (MTIAlphaTypeHandlingRule *)alphaTypeHandlingRule {
    return MTIAlphaTypeHandlingRule.passthroughAlphaTypeHandlingRule;
}


//+ (MTIRenderPipelineKernel *)kernel {
//    static MTIRenderPipelineKernel *kernel;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        kernel = [[MTIRenderPipelineKernel alloc] initWithVertexFunctionDescriptor:[[MTIFunctionDescriptor alloc] initWithName:MTIFilterPassthroughVertexFunctionName]
//                                                        fragmentFunctionDescriptor:[[MTIFunctionDescriptor alloc] initWithName:@"liquify"]
//                                                                  vertexDescriptor:nil
//                                                              colorAttachmentCount:1
//                                                             alphaTypeHandlingRule:MTIAlphaTypeHandlingRule.passthroughAlphaTypeHandlingRule];
//    });
//    return kernel;
//}
//
//- (MTIImage *)outputImage {
//    if (!self.inputImage) {
//        return nil;
//    }
//
//    CGRect cropRegion = CGRectMake(0, 0, 1, 1);
//    CGRect cropRect = CGRectZero;
//
//    cropRect = CGRectMake(cropRegion.origin.x * self.inputImage.size.width,
//                          cropRegion.origin.y * self.inputImage.size.height,
//                          cropRegion.size.width * self.inputImage.size.width,
//                          cropRegion.size.height * self.inputImage.size.height);
//
//    CGRect rect = CGRectMake(-1, -1, 2, 2);
//    CGFloat l = CGRectGetMinX(rect);
//    CGFloat r = CGRectGetMaxX(rect);
//    CGFloat t = CGRectGetMinY(rect);
//    CGFloat b = CGRectGetMaxY(rect);
//
//    CGFloat minX = cropRect.origin.x/self.inputImage.size.width;
//    CGFloat minY = cropRect.origin.y/self.inputImage.size.height;
//    CGFloat maxX = CGRectGetMaxX(cropRect)/self.inputImage.size.width;
//    CGFloat maxY = CGRectGetMaxY(cropRect)/self.inputImage.size.height;
//
//    MTIVertices *geometry = [[MTIVertices alloc] initWithVertices:(MTIVertex []){
//        { .position = {l, t, 0, 1} , .textureCoordinate = { minX, maxY } },
//        { .position = {r, t, 0, 1} , .textureCoordinate = { maxX, maxY } },
//        { .position = {l, b, 0, 1} , .textureCoordinate = { minX, minY } },
//        { .position = {r, b, 0, 1} , .textureCoordinate = { maxX, minY } }
//    } count:4 primitiveType:MTLPrimitiveTypeTriangleStrip];
//
//
//    NSUInteger outputWidth = cropRect.size.width;
//    NSUInteger outputHeight = cropRect.size.height;
//
//    MTIRenderPassOutputDescriptor *outputDescriptor = [[MTIRenderPassOutputDescriptor alloc] initWithDimensions:(MTITextureDimensions){.width = outputWidth, .height = outputHeight, .depth = 1} pixelFormat:self.outputPixelFormat loadAction:MTLLoadActionClear storeAction:MTLStoreActionStore];
//
//    MTIRenderCommand *command = [[MTIRenderCommand alloc] initWithKernel:self.class.kernel geometry:geometry images:@[self.inputImage] parameters:self.parameters];
//    return [MTIRenderCommand imagesByPerformingRenderCommands:@[command]
//                                            outputDescriptors:@[outputDescriptor]].firstObject;
//}

//- (MTIImage *)outputImage {
//    if (!self.inputImage) {
//        return nil;
//    }
//        return myCustomKernel.apply(to: [inputImage],
//                                    parameters: [
//                                        "size": parameters.imageSize,
//                                        "center": parameters.center,
//                                        "radius": parameters.radius,
//                                        "direction": parameters.direction,
//                                        "strength": parameters.strength,
//                                        "density": parameters.density
//                                    ],
//                                    outputDescriptors: [
////                                        MTIRenderPassOutputDescriptor(dimensions: inputImage.dimensions, pixelFormat: outputPixelFormat)
//                                        MTIRenderPassOutputDescriptor(dimensions: inputImage.dimensions, pixelFormat: outputPixelFormat, loadAction: .clear)
//                                    ]

@end

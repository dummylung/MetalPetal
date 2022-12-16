//
//  MTIMultilayerBrushCompositingFilter.m
//  Pods
//
//  Created by YuAo on 27/09/2017.
//

#import "MTIMultilayerBrushCompositingFilter.h"
#import "MTIMultilayerBrushCompositeKernel.h"
#import "MTIBlendFilter.h"
#import "MTIImage.h"
#import "MTIRenderPipelineKernel.h"


@implementation MTIMultilayerBrushCompositingFilter

@synthesize outputPixelFormat = _outputPixelFormat;

+ (MTIMultilayerBrushCompositeKernel *)kernel {
    static MTIMultilayerBrushCompositeKernel *kernel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kernel = [[MTIMultilayerBrushCompositeKernel alloc] init];
    });
    return kernel;
}

- (instancetype)init {
    if (self = [super init]) {
        _rasterSampleCount = 1;
        _outputAlphaType = MTIAlphaTypeNonPremultiplied;
    }
    return self;
}

- (MTIImage *)outputImage {
    if (!_inputBackgroundImage) {
        return nil;
    }
    if (_layers.count == 0) {
        return _inputBackgroundImage;
    }
    
    return [self.class.kernel applyToBackgroundImage:_inputBackgroundImage
                 backgroundImageBeforeCurrentSession:_inputBackgroundImageBeforeCurrentSession
                                              layers:_layers
                                   rasterSampleCount:_rasterSampleCount
                                     outputAlphaType:_outputAlphaType
                             outputTextureDimensions:MTITextureDimensionsMake2DFromCGSize(_inputBackgroundImage.size)
                                   outputPixelFormat:_outputPixelFormat];
    
//    MTIRenderPipelineKernel *kernel = [MTIBlendFilter kernelWithBlendMode:MTIBlendModeNormal
//                                                        backdropAlphaType:_inputBackgroundImageBeforeCurrentSession.alphaType
//                                                          sourceAlphaType:image.alphaType
//                                                          outputAlphaType:_outputAlphaType];
//
//    return [kernel applyToInputImages:@[_inputBackgroundImageBeforeCurrentSession, image]
//                                      parameters:@{@"intensity": @(1)}
//                         outputTextureDimensions:MTITextureDimensionsMake2DFromCGSize(_inputBackgroundImage.size)
//                               outputPixelFormat:_outputPixelFormat];
}

@end

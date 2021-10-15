//
// This is an auto-generated source file.
//

#include <metal_stdlib>
#include <TargetConditionals.h>
#include "MTIShaderLib.h"
#include "MTIShaderFunctionConstants.h"

#ifndef TARGET_OS_SIMULATOR
    #error TARGET_OS_SIMULATOR not defined. Check <TargetConditionals.h>
#endif

using namespace metal;
using namespace metalpetal;

namespace metalpetal {

vertex MTIMultilayerCompositingLayerVertexOut multilayerCompositeVertexShader(
                                        const device MTIMultilayerCompositingLayerVertex * vertices [[ buffer(0) ]],
                                        constant float4x4 & transformMatrix [[ buffer(1) ]],
                                        constant float4x4 & orthographicMatrix [[ buffer(2) ]],
                                        uint vid [[ vertex_id ]]
                                        ) {
    MTIMultilayerCompositingLayerVertexOut outVertex;
    MTIMultilayerCompositingLayerVertex inVertex = vertices[vid];
    outVertex.position = inVertex.position * transformMatrix * orthographicMatrix;
    outVertex.textureCoordinate = inVertex.textureCoordinate;
    outVertex.positionInLayer = inVertex.positionInLayer;
    return outVertex;
}

#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR

struct Rect {
    float4 mid;
    float width;
    float height;
};

bool isInsideRect(float4 p, Rect r) {
    float hw = r.width * 0.5;
    float hh = r.height * 0.5;
    float2 ul = float2(r.mid.x - hw, r.mid.y - hh);
    float2 ur = float2(r.mid.x + hw, r.mid.y - hh);
    float2 bl = float2(r.mid.x - hw, r.mid.y + hh);
    float2 br = float2(r.mid.x + hw, r.mid.y + hh);
    if (p.x > ul.x && p.y > ul.y
        && p.x < ur.x && p.y > ur.y
        && p.x > bl.x && p.y < bl.y
        && p.x < br.x && p.y < br.y) {
        return true;
    }
    return false;
}

float2 transformPointCoord(float2 pointCoord, float a, float2 anchor) {
    float2 point20 = pointCoord - anchor;
    float x = point20.x * cos(a) - point20.y * sin(a);
    float y = point20.x * sin(a) + point20.y * cos(a);
    return float2(x, y) + anchor;
}

float4 blend(int mode, float4 Cb, float4 Cs) {
    float4 color = Cb;
    switch (mode) {
        case 0: color = normalBlend(Cb, Cs); break;
            
        case 1: color = darkenBlend(Cb, Cs); break;
        case 2: color = multiplyBlend(Cb, Cs); break;
        case 3: color = colorBurnBlend(Cb, Cs); break;
        case 4: color = linearBurnBlend(Cb, Cs); break;
        case 5: color = darkerColorBlend(Cb, Cs); break;
            
        case 6: color = lightenBlend(Cb, Cs); break;
        case 7: color = screenBlend(Cb, Cs); break;
        case 8: color = colorDodgeBlend(Cb, Cs); break;
        case 9: color = linearDodgeBlend(Cb, Cs); break;
        case 10: color = lighterColorBlend(Cb, Cs); break;
            
        case 11: color = overlayBlend(Cb, Cs); break;
        case 12: color = softLightBlend(Cb, Cs); break;
        case 13: color = hardLightBlend(Cb, Cs); break;
        case 14: color = vividLightBlend(Cb, Cs); break;
        case 15: color = linearLightBlend(Cb, Cs); break;
        case 16: color = pinLightBlend(Cb, Cs); break;
        case 17: color = hardMixBlend(Cb, Cs); break;
        
        case 18: color = addBlend(Cb, Cs); break;
        case 19: color = differenceBlend(Cb, Cs); break;
        case 20: color = exclusionBlend(Cb, Cs); break;
        case 21: color = subtractBlend(Cb, Cs); break;
        case 22: color = divideBlend(Cb, Cs); break;
        
        case 23: color = hueBlend(Cb, Cs); break;
        case 24: color = saturationBlend(Cb, Cs); break;
        case 25: color = colorBlend(Cb, Cs); break;
        case 26: color = luminosityBlend(Cb, Cs); break;
            
        default: break;
    }
    return color;
}

fragment float4 multilayerCompositeNormalBlend_programmableBlending(MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                                    float4 currentColor [[color(0)]],
                                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
//                                                                    constant MTIMultilayerCompositingLayerSessionVertexes & sessionVertexes [[ buffer(1) ]],
//                                                                    constant float4x4 & transformMatrix [[ buffer(2) ]],
//                                                                    constant float4x4 & orthographicMatrix [[ buffer(3) ]],
                                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                                    sampler colorSampler [[ sampler(0) ]],
                                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                                    sampler maskSampler [[ sampler(2) ]]
//                                                                    texture2d<float, access::sample> backgroundTexture [[ texture(3) ]],
//                                                                    sampler backgroundSampler [[ sampler(3) ]],
//                                                                    texture2d<float, access::sample> backgroundTextureBeforeCurrentSession [[ texture(4) ]],
//                                                                    sampler backgroundSamplerBeforeCurrentSession [[ sampler(4) ]]
                                                                    ) {
    
    float alpha = parameters.tintColor.a;
    
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    
//    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
//    float4 textureColor = colorTexture.sample(textureSampler, textureCoordinate);
    
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
//        currentColor = unpremultiply(currentColor);
    }
    
    textureColor = float4(1, 1, 1, textureColor.r);
                                                    
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
                                                    
    if (multilayer_composite_has_compositing_mask) {
//        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float scale = parameters.compositingMaskScale * 100 * 5;
        float2 location = float2(((int)vertexIn.position.x*100 % (int)(scale*100)/100.0) / scale, ((int)vertexIn.position.y*100 % (int)(scale*100)/100.0) / scale);
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        
//        float maskValue = maskColor[parameters.compositingMaskComponent];
        
        float3 textureColorHSL = rgb2hsl(textureColor.rgb);
        float lightness = textureColorHSL.b;
        
        float depth1Value = lightness * parameters.compositingMaskDepth1;
        float depth2Value = lightness * parameters.compositingMaskDepth2;
        
        maskColor = blend(parameters.compositingMaskBlendMode1, maskColor, float4(textureColor.rgb, parameters.compositingMaskDepth1Inverted ? 1-depth1Value : depth1Value));
        maskColor = blend(parameters.compositingMaskBlendMode2, maskColor, float4(textureColor.rgb, parameters.compositingMaskDepth2Inverted ? 1-depth2Value : depth2Value));
        textureColor.rgb = maskColor.rgb;
        
//        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    
    textureColor.a *= alpha * parameters.opacity;
    
//    float2 location = vertexIn.position.xy / parameters.canvasSize;
    
//    float4 backgroundColor = backgroundTexture.sample(backgroundSampler, location);
//    backgroundColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(backgroundColor) : backgroundColor;
    
    float4 finalColor = float4(0,0,0,0);
    
    switch (parameters.fillMode) {
        case 0: // normal
        {
//            float4 backgroundColorBeforeCurrentSession = backgroundTextureBeforeCurrentSession.sample(backgroundSamplerBeforeCurrentSession, location);
//            backgroundColorBeforeCurrentSession = unpremultiply(backgroundColorBeforeCurrentSession);
//
//            float4 colorOnCurrentSession = reverseNormalBlend(currentColor, backgroundColorBeforeCurrentSession);
//
//            float4 newColorToBeBlendToBackground = textureColor;
//            if (colorOnCurrentSession.a > textureColor.a) { // force not strong enough to make it "darker"
//                newColorToBeBlendToBackground.a = colorOnCurrentSession.a;
//            }
////            textureColor.a = max(sessionColor.a, textureColor.a);
            
//            finalColor = normalBlend(backgroundColorBeforeCurrentSession, newColorToBeBlendToBackground);
            
            if (textureColor.a > 0) {
                textureColor.a = min(1.0, textureColor.a + parameters.shapeCount * 0.02);
            }
            
            float4 newColorToBeBlendToBackground = textureColor;
            if (currentColor.a > textureColor.a) { // force not strong enough to make it "darker"
                newColorToBeBlendToBackground.a = currentColor.a;
            }
            finalColor = newColorToBeBlendToBackground;
            
//            int count = parameters.sessionVertexCount;

//            float4 overlay = float4(textureColor.rgb, 0);
//            for (int i = 0; i < count; i++) {
//                float4 m = sessionVertexes.vertexes[i].position;
//                float size = sessionVertexes.vertexes[i].size;
//                Rect rect = { .mid = m, .width = size, .height = size };
//                if (isInsideRect(vertexIn.position, rect) == false) {
//                    continue;
//                }
//                float2 ratio = float2(float(vertexIn.position.x - (m.x-size*0.5)) / size,
//                                      float(vertexIn.position.y - (m.y-size*0.5)) / size);
//                float2 text_coord = transformPointCoord(ratio, 0, float2(0.5));
//                float4 _color = colorTexture.sample(colorSampler, text_coord);
//
//                if (multilayer_composite_content_premultiplied) {
//                    _color = unpremultiply(_color);
//                }
//
//                overlay.a = min(alpha, overlay.a+_color.a);
//
//                if (overlay.a == alpha) {
//                    break;
//                }
//            }

//            sessionColor = normalBlend(sessionColor, overlay);
//            sessionColor.a = min(alpha, sessionColor.a);
            
//            textureColor = float4(textureColor.rgb, 0.5);
            
            
//            float4 blendColor = max(sessionColor.a, textureColor.a);
//            blendColor.a = min(alpha, blendColor.a);
            
//            if (sessionColor.a > 0) {
//                blendColor.a = min(sessionColor.a, blendColor.a);
//            }
            
//            if (textureColor.a <= 0.03) {
//                textureColor.a = 0;
//            }
            
//            float4 blendColor = normalBlend(sessionColor, textureColor);
//            blendColor.a = min(alpha, blendColor.a);
//
//            finalColor = normalBlend(backgroundColorBeforeCurrentSession, blendColor);
            
//            return normalBlend(currentColor,textureColor);
            
//            if (finalColor.a <= 0.01) {
//                finalColor.a = 0;
//            }
            
            break;
        }
        case 1: // substract
        {
            finalColor.rgb = currentColor.rgb;
            finalColor.a = currentColor.a * (1-textureColor.a*(1-alpha));

            if (finalColor.a <= 0.03) {
                finalColor.a = 0;
            }
            
            break;
        }
        default:
            break;
    }
    
//    finalColor.a = float(int(floor(finalColor.a * 100))) / 100;

//    if (finalColor.a >= 0.999) {
//        finalColor.a = 0.999;
//    }
//
//    if (finalColor.a == 0) {
//        finalColor.rgb = 1;
//    }

    return finalColor;
    
    
//    float2 location = vertexIn.position.xy / parameters.canvasSize;
//    float4 backgroundColor = backgroundTexture.sample(backgroundSampler, location);
//    backgroundColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(backgroundColor) : backgroundColor;
//    float4 blendColor = normalBlend(backgroundColor,textureColor);
////    float4 blendColor = textureColor;
//    blendColor.a = min(maxAlpha, blendColor.a);
//
//    return blendColor;
    
}

#endif

fragment float4 multilayerCompositeNormalBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return normalBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeDarkenBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return darkenBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeDarkenBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return darkenBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeMultiplyBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return multiplyBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeMultiplyBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return multiplyBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeColorBurnBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return colorBurnBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeColorBurnBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return colorBurnBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeLinearBurnBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return linearBurnBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeLinearBurnBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return linearBurnBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeDarkerColorBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return darkerColorBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeDarkerColorBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return darkerColorBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeLightenBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return lightenBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeLightenBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return lightenBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeScreenBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return screenBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeScreenBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return screenBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeColorDodgeBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return colorDodgeBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeColorDodgeBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return colorDodgeBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeAddBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return addBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeAddBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return addBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeLighterColorBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return lighterColorBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeLighterColorBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return lighterColorBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeOverlayBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return overlayBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeOverlayBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return overlayBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeSoftLightBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return softLightBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeSoftLightBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return softLightBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeHardLightBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return hardLightBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeHardLightBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return hardLightBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeVividLightBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return vividLightBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeVividLightBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return vividLightBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeLinearLightBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return linearLightBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeLinearLightBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return linearLightBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositePinLightBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return pinLightBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositePinLightBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return pinLightBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeHardMixBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return hardMixBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeHardMixBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return hardMixBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeDifferenceBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return differenceBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeDifferenceBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return differenceBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeExclusionBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return exclusionBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeExclusionBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return exclusionBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeSubtractBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return subtractBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeSubtractBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return subtractBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeDivideBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return divideBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeDivideBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return divideBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeHueBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return hueBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeHueBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return hueBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeSaturationBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return saturationBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeSaturationBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return saturationBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeColorBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return colorBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeColorBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return colorBlend(backgroundColor,textureColor);
}


#if __HAVE_COLOR_ARGUMENTS__ && !TARGET_OS_SIMULATOR
    
fragment float4 multilayerCompositeLuminosityBlend_programmableBlending(
                                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                                    float4 currentColor [[color(0)]],
                                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                                    sampler colorSampler [[ sampler(0) ]],
                                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(1) ]],
                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
                                                    sampler maskSampler [[ sampler(2) ]]
                                                ) {
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(currentColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);

    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return luminosityBlend(currentColor,textureColor);
}

#endif

fragment float4 multilayerCompositeLuminosityBlend(
                                    MTIMultilayerCompositingLayerVertexOut vertexIn [[ stage_in ]],
                                    texture2d<float, access::sample> backgroundTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> compositingMaskTexture [[ texture(2) ]],
                                    sampler compositingMaskSampler [[ sampler(2) ]],
                                    texture2d<float, access::sample> maskTexture [[ texture(3) ]],
                                    sampler maskSampler [[ sampler(3) ]],
                                    constant MTIMultilayerCompositingLayerShadingParameters & parameters [[buffer(0)]],
                                    texture2d<float, access::sample> colorTexture [[ texture(0) ]],
                                    sampler colorSampler [[ sampler(0) ]]
                                ) {
    constexpr sampler s(coord::normalized, address::clamp_to_zero, filter::linear);
    float2 location = vertexIn.position.xy / parameters.canvasSize;
    float4 backgroundColor = backgroundTexture.sample(s, location);
    float2 textureCoordinate = vertexIn.textureCoordinate;
    #if MTI_CUSTOM_BLEND_HAS_TEXTURE_COORDINATES_MODIFIER
    textureCoordinate = modify_source_texture_coordinates(backgroundColor, vertexIn.textureCoordinate, uint2(colorTexture.get_width(), colorTexture.get_height()));
    #endif
    float4 textureColor = colorTexture.sample(colorSampler, textureCoordinate);
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
    }
    if (multilayer_composite_has_mask) {
        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.maskComponent];
        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_compositing_mask) {
        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, location);
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        float maskValue = maskColor[parameters.compositingMaskComponent];
        textureColor.a *= parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
    }
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
        textureColor.a *= parameters.tintColor.a;
    }
    switch (multilayer_composite_corner_curve_type) {
        case 1:
            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        case 2:
            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
            break;
        default:
            break;
    }
    textureColor.a *= parameters.opacity;
    return luminosityBlend(backgroundColor,textureColor);
}


}

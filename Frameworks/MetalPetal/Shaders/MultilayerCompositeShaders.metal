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
    switch (mode) {
        case 0: return normalBlend(Cb, Cs);
            
        case 1: return darkenBlend(Cb, Cs);
        case 2: return multiplyBlend(Cb, Cs);
        case 3: return colorBurnBlend(Cb, Cs);
        case 4: return linearBurnBlend(Cb, Cs);
        case 5: return darkerColorBlend(Cb, Cs);
            
        case 6: return lightenBlend(Cb, Cs);
        case 7: return screenBlend(Cb, Cs);
        case 8: return colorDodgeBlend(Cb, Cs);
//        case 9: return linearDodgeBlend(Cb, Cs);
        case 9: return lighterColorBlend(Cb, Cs);
            
        case 10: return overlayBlend(Cb, Cs);
        case 11: return softLightBlend(Cb, Cs);
        case 12: return hardLightBlend(Cb, Cs);
        case 13: return vividLightBlend(Cb, Cs);
        case 14: return linearLightBlend(Cb, Cs);
        case 15: return pinLightBlend(Cb, Cs);
        case 16: return hardMixBlend(Cb, Cs);
        
        case 17: return addBlend(Cb, Cs);
        case 18: return differenceBlend(Cb, Cs);
        case 19: return exclusionBlend(Cb, Cs);
        case 20: return subtractBlend(Cb, Cs);
        case 21: return divideBlend(Cb, Cs);
        
        case 22: return hueBlend(Cb, Cs);
        case 23: return saturationBlend(Cb, Cs);
        case 24: return colorBlend(Cb, Cs);
        case 25: return luminosityBlend(Cb, Cs);
            
        default: break;
    }
    return Cb;
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
//                                                                    sampler compositingMaskSampler [[ sampler(1) ]],
                                                                    texture2d<float, access::sample> maskTexture [[ texture(2) ]],
//                                                                    sampler maskSampler [[ sampler(2) ]],
                                                                    texture2d<float, access::sample> materialMaskTexture [[ texture(3) ]]
//                                                                    sampler materialMaskSampler [[ sampler(3) ]]
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
    
    float2 shapePosition = textureCoordinate;
    
    if (parameters.shapeFlipX) {
        shapePosition = float2(1 - shapePosition.x, shapePosition.y);
    }
    if (parameters.shapeFlipY) {
        shapePosition = float2(shapePosition.x, 1 - shapePosition.y);
    }
    if (parameters.shapeRotation != 0) {
        shapePosition = transformPointCoord(float2(parameters.layerSize.x * shapePosition.x, parameters.layerSize.y * shapePosition.y),
                                            -parameters.shapeRotation,
                                            float2(parameters.layerSize.x*0.5, parameters.layerSize.y*0.5));
        shapePosition = float2(shapePosition.x / parameters.layerSize.x, shapePosition.y / parameters.layerSize.y);
    }
    float4 textureColor = colorTexture.sample(colorSampler, shapePosition);
    
//    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
//    float4 textureColor = colorTexture.sample(textureSampler, textureCoordinate);
    
    if (multilayer_composite_content_premultiplied) {
        textureColor = unpremultiply(textureColor);
//        currentColor = unpremultiply(currentColor);
    }
    
//    if (multilayer_composite_has_mask && textureColor.a > 0) {
//        constexpr sampler maskSampler(mag_filter::linear, min_filter::linear);
//        float4 maskColor = maskTexture.sample(maskSampler, vertexIn.positionInLayer);
//        maskColor = parameters.maskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
//        float maskValue = maskColor[parameters.maskComponent];
//        textureColor.a *= parameters.maskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
//    }
    
    bool isEmpty = textureColor[parameters.shapeComponent] <= 0.01;
    
    if (isEmpty) {
        discard_fragment();
    }
    
    if (multilayer_composite_has_compositing_mask && !isEmpty) {
        constexpr sampler compositingMaskSampler(mag_filter::linear, min_filter::linear);
//        float2 location = vertexIn.position.xy / parameters.canvasSize;
        float scale = parameters.compositingMaskScale;
        float zoom = parameters.compositingMaskZoom*0.2+1;

        float x = 0;
        float y = 0;

        switch (parameters.compositingMaskType) {
            case 0: // moving
            {
                // scale 0.2 is original size
//                float s = (scale-0.2)*5+1.0;
//                x = vertexIn.textureCoordinate.x / s;
//                y = vertexIn.textureCoordinate.y / s;
//                x = x - (int)x;
//                y = y - (int)y;

                float2 origin = float2(0,0);
                float2 offset = float2(0,0);
                if (parameters.compositingMaskOffsetJitter.x > 0 || parameters.compositingMaskOffsetJitter.y > 0) {
                    origin = float2(parameters.startPosition.x, parameters.startPosition.y);
                    offset = parameters.compositingMaskOffsetJitter * parameters.startLayerSize;
                }
                float2 layerPosition = float2(parameters.layerSize.x * vertexIn.textureCoordinate.x, parameters.layerSize.y * vertexIn.textureCoordinate.y);
                
                float dx = vertexIn.position.x - layerPosition.x + parameters.layerSize.x*0.5;
                float dy = vertexIn.position.y - layerPosition.y + parameters.layerSize.y*0.5;

                dx = dx * parameters.compositingMaskMovement + layerPosition.x - parameters.layerSize.x*0.5;
                dy = dy * parameters.compositingMaskMovement + layerPosition.y - parameters.layerSize.y*0.5;
                
                dx = dx - origin.x - offset.x;
                dy = dy - origin.y - offset.y;
                
                if (parameters.compositingMaskRotation != 0) {
                    float2 r = transformPointCoord(float2(dx,dy),
                                                   parameters.compositingMaskRotation * M_PI_F,
                                                   float2(parameters.startLayerSize.x*0.5, parameters.startLayerSize.y*0.5));
                    dx = r.x;
                    dy = r.y;
                }

                x = dx / (compositingMaskTexture.get_width() * scale * zoom);
                y = dy / (compositingMaskTexture.get_height() * scale * zoom);

                x = x - (int)x;
                y = y - (int)y;

                (x < 0) && (x = 1-(-x));
                (y < 0) && (y = 1-(-y));

                break;
            }
            case 1: // texturised
            {
                x = vertexIn.position.x / (compositingMaskTexture.get_width() * scale);
                y = vertexIn.position.y / (compositingMaskTexture.get_height() * scale);
                x = x - (int)x;
                y = y - (int)y;
                break;
            }
        }

        float4 maskColor = compositingMaskTexture.sample(compositingMaskSampler, float2(x, y));
        maskColor = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;

        float maskValue = maskColor[parameters.compositingMaskComponent];
        maskValue = parameters.compositingMaskUsesOneMinusValue ? (1.0 - maskValue) : maskValue;
        maskColor = float4(maskValue, maskValue, maskValue, maskColor.a);

        maskColor.a *= parameters.compositingMaskDepth;

        maskColor = blend(parameters.compositingMaskBlendMode, textureColor, maskColor);
        textureColor = maskColor;
    }
    
    float textureValue = textureColor[parameters.shapeComponent];
    textureValue = parameters.shapeUsesOneMinusValue ? (1.0 - textureValue) : textureValue;
    textureColor = float4(textureValue, textureValue, textureValue, textureColor.a);
    
    textureColor = float4(1, 1, 1, textureColor.r);
//    textureColor.r *= parameters.shapeUsesOneMinusValue ? (1.0 - textureValue) : textureValue;
//    textureColor = float4(1, 1, 1, textureColor.r);
    
    if (multilayer_composite_has_tint_color) {
        textureColor.rgb = parameters.tintColor.rgb;
    }
    
    if (multilayer_composite_has_material_mask && textureColor.a > 0 && !isEmpty) {
//        float scale = parameters.materialMaskScale;
//        float x = vertexIn.position.x / (materialMaskTexture.get_width() * scale);
//        float y = vertexIn.position.y / (materialMaskTexture.get_height() * scale);
//        x = x - (int)x;
//        y = y - (int)y;
        
        constexpr sampler materialMaskSampler(mag_filter::linear, min_filter::linear);
        float scale = parameters.materialMaskScale;
        float zoom = parameters.materialMaskZoom*0.2+1;

        float x = 0;
        float y = 0;
        
        switch (parameters.materialMaskType) {
            case 0: // moving
            {
                float2 origin = float2(0,0);
                float2 offset = float2(0,0);
                if (parameters.materialMaskOffsetJitter.x > 0 || parameters.materialMaskOffsetJitter.y > 0 ) {
                    origin = float2(parameters.startPosition.x, parameters.startPosition.y);
                    offset = parameters.materialMaskOffsetJitter * parameters.startLayerSize;
                }
                float2 layerPosition = float2(parameters.layerSize.x * vertexIn.textureCoordinate.x, parameters.layerSize.y * vertexIn.textureCoordinate.y);
                
                float dx = vertexIn.position.x - layerPosition.x + parameters.layerSize.x*0.5;
                float dy = vertexIn.position.y - layerPosition.y + parameters.layerSize.y*0.5;

                dx = dx * parameters.materialMaskMovement + layerPosition.x - parameters.layerSize.x*0.5;
                dy = dy * parameters.materialMaskMovement + layerPosition.y - parameters.layerSize.y*0.5;
                
                dx = dx - origin.x - offset.x;
                dy = dy - origin.y - offset.y;

                if (parameters.materialMaskRotation != 0) {
                    float2 r = transformPointCoord(float2(dx,dy),
                                                   parameters.materialMaskRotation * M_PI_F,
                                                   float2(parameters.startLayerSize.x*0.5, parameters.startLayerSize.y*0.5));
                    dx = r.x;
                    dy = r.y;
                }

                x = dx / (materialMaskTexture.get_width() * scale * zoom);
                y = dy / (materialMaskTexture.get_height() * scale * zoom);

                x = x - (int)x;
                y = y - (int)y;

                (x < 0) && (x = 1-(-x));
                (y < 0) && (y = 1-(-y));

                break;
            }
            case 1: // texturised
            {
                x = vertexIn.position.x / (materialMaskTexture.get_width() * scale);
                y = vertexIn.position.y / (materialMaskTexture.get_height() * scale);
                x = x - (int)x;
                y = y - (int)y;
                break;
            }
        }
        
        float4 maskColor = materialMaskTexture.sample(materialMaskSampler, float2(x, y));
        maskColor = parameters.materialMaskHasPremultipliedAlpha ? unpremultiply(maskColor) : maskColor;
        
        if (parameters.materialMaskUsesOneMinusValue) {
            maskColor = float4(1.0-maskColor.r,1.0-maskColor.g,1.0-maskColor.b,maskColor.a);
        }

        if (maskColor.a < 0.1) {
            
            textureColor.a *= 0; // solution for transparent image
            
        } else if (parameters.materialMaskDepth >= 0.01) {

            maskColor.a *= parameters.materialMaskDepth;

            maskColor = blend(parameters.materialMaskBlendMode, textureColor, maskColor);

            if (maskColor.a >= 0) {
                float3 textureColorHSL = rgb2hsl(textureColor.rgb);
                float lightness = textureColorHSL.b;

                float depth1Value = lightness * parameters.materialMaskDepth1;
                float depth2Value = lightness * parameters.materialMaskDepth2;

                float4 blendColor = maskColor;
                int blendMode1 = parameters.materialMaskBlendMode1;
                int blendMode2 = parameters.materialMaskBlendMode2;
                blendColor = blend(blendMode1, blendColor, float4(textureColor.rgb, parameters.materialMaskDepth1Inverted ? 1-depth1Value : depth1Value));
                blendColor = blend(blendMode2, blendColor, float4(textureColor.rgb, parameters.materialMaskDepth2Inverted ? 1-depth2Value : depth2Value));
                textureColor.rgb = blendColor.rgb;
            }
        }
        
    }
    
//    switch (multilayer_composite_corner_curve_type) {
//        case 1:
//            textureColor.a *= circularCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
//            break;
//        case 2:
//            textureColor.a *= continuousCornerMask(parameters.layerSize, vertexIn.positionInLayer, parameters.cornerRadius);
//            break;
//        default:
//            break;
//    }
    
    if (textureColor.a > 0) {
        textureColor.a *= alpha * parameters.opacity;
    }
    
    float4 finalColor = float4(0,0,0,0);
    
    switch (parameters.fillMode) {
        case 0: // normal
        {
            if (textureColor.a > 0.02 && parameters.shapeCount > 1) {
                textureColor.a = min(1.0, textureColor.a + (parameters.shapeCount-1) * 0.02);
            }
            
            switch (parameters.renderingMode) {
                case 0:
                    finalColor = currentColor.a > textureColor.a ? currentColor : textureColor;
                    break;
                case 1:
                    finalColor = blend(parameters.renderingBlendMode, currentColor, textureColor);
                    break;
            }
            
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

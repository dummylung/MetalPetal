//
//  MTIShader.h
//  Pods
//
//  Created by YuAo on 02/07/2017.
//
//

#ifndef MTIShader_h
#define MTIShader_h

#if __METAL_MACOS__ || __METAL_IOS__

#include <metal_stdlib>

using namespace metal;

#endif /* __METAL_MACOS__ || __METAL_IOS__ */

#import <simd/simd.h>

struct MTIVertex {
    vector_float4 position;
    vector_float2 textureCoordinate;
};
typedef struct MTIVertex MTIVertex;

struct MTIColorMatrix {
    matrix_float4x4 matrix;
    vector_float4 bias;
};
typedef struct MTIColorMatrix MTIColorMatrix;

struct MTICLAHELUTGeneratorInputParameters {
    uint histogramBins;
    uint clipLimit;
    uint totalPixelCountPerTile;
    uint numberOfLUTs;
};
typedef struct MTICLAHELUTGeneratorInputParameters MTICLAHELUTGeneratorInputParameters;

struct MTIMultilayerCompositingLayerShadingParameters {
    float opacity;
    bool contentHasPremultipliedAlpha;
    bool hasCompositingMask;
    int compositingMaskComponent;
    bool usesOneMinusMaskValue;
};
typedef struct MTIMultilayerCompositingLayerShadingParameters MTIMultilayerCompositingLayerShadingParameters;

#if __METAL_MACOS__ || __METAL_IOS__

namespace metalpetal {
    
    typedef ::MTIVertex VertexIn;
    
    typedef struct {
        float4 position [[ position ]];
        float2 textureCoordinate;
    } VertexOut;
    
    // GLSL mod func for metal
    template <typename T, typename _E = typename enable_if<is_same<float, typename make_scalar<T>::type>::value>::type>
    METAL_FUNC T mod(T x, T y) {
        return x - y * floor(x/y);
    }
    
    METAL_FUNC float4 unpremultiply(float4 s) {
        return float4(s.rgb/max(s.a,0.00001), s.a);
    }
    
    METAL_FUNC float4 premultiply(float4 s) {
        return float4(s.rgb * s.a, s.a);
    }
    
    METAL_FUNC float hue2rgb(float p, float q, float t){
        if(t < 0.0) {
            t += 1.0;
        }
        if(t > 1.0) {
            t -= 1.0;
        }
        if(t < 1.0/6.0) {
            return p + (q - p) * 6.0 * t;
        }
        if(t < 1.0/2.0) {
            return q;
        }
        if(t < 2.0/3.0) {
            return p + (q - p) * (2.0/3.0 - t) * 6.0;
        }
        return p;
    }
    
    METAL_FUNC float3 rgb2hsl(float3 inputColor) {
        float3 color = clamp(inputColor,float3(0.0),float3(1.0));
        
        //Compute min and max component values
        float MAX = max(color.r, max(color.g, color.b));
        float MIN = min(color.r, min(color.g, color.b));
        
        //Make sure MAX > MIN to avoid division by zero later
        MAX = max(MIN + 1e-6, MAX);
        
        //Compute luminosity
        float l = (MIN + MAX) / 2.0;
        
        //Compute saturation
        float s = (l < 0.5 ? (MAX - MIN) / (MIN + MAX) : (MAX - MIN) / (2.0 - MAX - MIN));
        
        //Compute hue
        float h = (MAX == color.r ? (color.g - color.b) / (MAX - MIN) : (MAX == color.g ? 2.0 + (color.b - color.r) / (MAX - MIN) : 4.0 + (color.r - color.g) / (MAX - MIN)));
        h /= 6.0;
        h = (h < 0.0 ? 1.0 + h : h);
        
        return float3(h, s, l);
    }
    
    METAL_FUNC float3 hsl2rgb(float3 inputColor) {
        float3 color = clamp(inputColor,float3(0.0),float3(1.0));
        
        float h = color.r;
        float s = color.g;
        float l = color.b;
        
        float r,g,b;
        if(s <= 0.0){
            r = g = b = l;
        }else{
            float q = l < 0.5 ? (l * (1.0 + s)) : (l + s - l * s);
            float p = 2.0 * l - q;
            r = hue2rgb(p, q, h + 1.0/3.0);
            g = hue2rgb(p, q, h);
            b = hue2rgb(p, q, h - 1.0/3.0);
        }
        return float3(r,g,b);
    }
    
    //source over blend
    METAL_FUNC float4 normalBlend(float4 Cb, float4 Cs) {
        float4 dst = premultiply(Cb);
        float4 src = premultiply(Cs);
        return unpremultiply(src + dst * (1.0 - src.a));
    }

    METAL_FUNC float4 blendBaseAlpha(float4 Cb, float4 Cs, float4 B) {
        float4 Cr = float4((1 - Cb.a) * Cs.rgb + Cb.a * clamp(B.rgb, float3(0), float3(1)), Cs.a);
        return normalBlend(Cb, Cr);
    }
    
    
    // multiply
    METAL_FUNC float4 multiplyBlend(float4 Cb, float4 Cs) {
        float4 B = clamp(float4(Cb.rgb * Cs.rgb, Cs.a), float4(0), float4(1));
        return blendBaseAlpha(Cb, Cs, B);
    }
    
    // overlay
    METAL_FUNC float overlayBlendSingleChannel(float b, float s ) {
        return b < 0.5f ? (2 * s * b) : (1 - 2 * (1 - b) * (1 - s));
    }
    
    METAL_FUNC float4 overlayBlend(float4 Cb, float4 Cs) {
        float4 B =  float4(overlayBlendSingleChannel(Cb.r, Cs.r), overlayBlendSingleChannel(Cb.g, Cs.g), overlayBlendSingleChannel(Cb.b, Cs.b), Cs.a);
        return blendBaseAlpha(Cb, Cs, B);
    }
    
    //hardLight
    METAL_FUNC float4 hardLightBlend(float4 Cb, float4 Cs) {
        return overlayBlend(Cs, Cb);
    }
    
     //  softLight
    METAL_FUNC float softLightBlendSingleChannelD(float b) {
        return b <= 0.25? (((16 * b - 12) * b + 4) * b): sqrt(b);
    }
    
    METAL_FUNC float softLightBlendSingleChannel(float b, float s) {
        return s < 0.5? (b - (1 - 2 * s) * b * (1 - b)) : (b + (2 * s - 1) * (softLightBlendSingleChannelD(b) - b));
    }
                         
    METAL_FUNC float4 softLightBlend(float4 Cb, float4 Cs) {
        float4 B = float4(softLightBlendSingleChannel(Cb.r, Cs.r), softLightBlendSingleChannel(Cb.g, Cs.g), softLightBlendSingleChannel(Cb.b, Cs.b), Cs.a);
        return blendBaseAlpha(Cb, Cs, B);
    }
    
    // screen
    METAL_FUNC float4 screenBlend(float4 Cb, float4 Cs) {
        float4 White = float4(1.0);
        float4 B = White - ((White - Cs) * (White - Cb));
        return blendBaseAlpha(Cb, Cs, B);
    }
    
    // darken
    METAL_FUNC float4 darkenBlend(float4 Cb, float4 Cs) {
        float4 B = float4(min(Cs.r, Cb.r), min(Cs.g, Cb.g), min(Cs.b, Cb.b), Cs.a);
        return blendBaseAlpha(Cb, Cs, B);
    }
    
    // lighten
    METAL_FUNC float4 lightenBlend(float4 Cb, float4 Cs) {
        float4 B = float4(max(Cs.r, Cb.r), max(Cs.g, Cb.g), max(Cs.b, Cb.b), Cs.a);
        return blendBaseAlpha(Cb, Cs, B);
    }
    
    // colorDodge
    METAL_FUNC float colorDodgeBlendSingleChannel(float b, float f) {
        if (b == 0) {
            return 0;
        } else if (f == 1) {
            return 1;
        } else {
            return min(1.0, b / (1 - f));
        }
    }
    METAL_FUNC float4 colorDodgeBlend(float4 Cb, float4 Cs) {
        float4 B = float4(colorDodgeBlendSingleChannel(Cb.r, Cs.r), colorDodgeBlendSingleChannel(Cb.g, Cs.g), colorDodgeBlendSingleChannel(Cb.b, Cs.b), Cs.a);
        return blendBaseAlpha(Cb, Cs, B);
    }

    // colorBurn
    METAL_FUNC float colorBurnBlendSingleChannel(float b, float f) {
        if (b == 1) {
            return 1;
        } else if (f == 0) {
            return 0;
        } else {
            return 1.0 - min(1.0, (1 - b) / f);
        }
    }
    METAL_FUNC float4 colorBurnBlend(float4 Cb, float4 Cs) {
        float4 B = float4(colorBurnBlendSingleChannel(Cb.r, Cs.r), colorBurnBlendSingleChannel(Cb.g, Cs.g), colorBurnBlendSingleChannel(Cb.b, Cs.b), Cs.a);
        return blendBaseAlpha(Cb, Cs, B);
    }
    
    // difference
    METAL_FUNC float4 differenceBlend(float4 Cb, float4 Cs) {
        float4 B = float4(abs(Cb.rgb - Cs.rgb), Cs.a);
        return blendBaseAlpha(Cb, Cs, B);
    }
    
    // exclusion
    METAL_FUNC float4 exclusionBlend(float4 Cb, float4 Cs) {
        float4 B = float4(Cb.rgb + Cs.rgb - 2 * Cb.rgb * Cs.rgb, Cs.a);
        return blendBaseAlpha(Cb, Cs, B);
    }
    
    //---
    // non-separable blend
    METAL_FUNC float lum(float4 C) {
        return 0.3 * C.r + 0.59 * C.g + 0.11 * C.b;
    }
    
    METAL_FUNC float4 clipColor(float4 C) {
        float l = lum(C);
        float  n = min(C.r, min(C.g, C.b));
        float x = max(C.r, max(C.g, C.b));
        if (n < 0) {
            return float4((l + ((C.rgb - l) * l) / (l - n)), C.a);
        }
        if (x > 1.) {
            return float4(l + (((C.rgb - l) * (1. - l)) / (x - l)), C.a);
        }
        return C;
    }
    
    METAL_FUNC float4 setLum(float4 C, float l) {
        float d = l - lum(C);
        return clipColor(float4(C.rgb + d, C.a ));
    }
    
    METAL_FUNC float sat(float4 C) {
        float n = min(C.r, min(C.g, C.b));
        float x = max(C.r, max(C.g, C.b));
        return x - n;
    }
    
    METAL_FUNC float mid(float cmin, float cmid, float cmax, float s) {
        return ((cmid - cmin) * s) / (cmax - cmin);
    }
    
    METAL_FUNC float4 setSat(float4 C, float s) {
        if (C.r > C.g) {
            if (C.r > C.b) {
                if (C.g > C.b) {
                    C.g = mid(C.b, C.g, C.r, s);
                    C.b = 0.0;
                } else {
                    C.b = mid(C.g, C.b, C.r, s);
                    C.g = 0.0;
                }
                C.r = s;
            } else {
                C.r = mid(C.g, C.r, C.b, s);
                C.b = s;
                C.r = 0.0;
            }
        } else if (C.r > C.b) {
            C.r = mid(C.b, C.r, C.g, s);
            C.g = s;
            C.b = 0.0;
        } else if (C.g > C.b) {
            C.b = mid(C.r, C.b, C.g, s);
            C.g = s;
            C.r = 0.0;
        } else if (C.b > C.g) {
            C.g = mid(C.r, C.g, C.b, s);
            C.b = s;
            C.r = 0.0;
        } else {
            C = float4(0.0);
        }
        return C;
    }
    
    // hue
    METAL_FUNC float4 hueBlend(float4 Cb, float4 Cs) {
        float4 B = setLum(setSat(Cs, sat(Cb)), lum(Cb));
        return blendBaseAlpha(Cb, Cs, B);
    }
    
    // saturation
    METAL_FUNC float4 saturationBlend(float4 Cb, float4 Cs) {
        float4 B = setLum(setSat(Cb, sat(Cs)), lum(Cb));
        return blendBaseAlpha(Cb, Cs, B);
    }
    
    // color
    METAL_FUNC float4 colorBlend(float4 Cb, float4 Cs) {
        float4 B = setLum(Cs, lum(Cb));
        return blendBaseAlpha(Cb, Cs, B);
    }
    
     // luminosity
    METAL_FUNC float4 luminosityBlend(float4 Cb, float4 Cs) {
        float4 B = setLum(Cb, lum(Cs));
        return blendBaseAlpha(Cb, Cs, B);
    }
    
    // Vibrance
    METAL_FUNC float4 adjustVibranceWhileKeepingSkinTones(float4 pixel0, float4 vvec) {
        float4 pixel = clamp(pixel0, 0.0001, 0.9999);
        float4 pdelta = pixel0 - pixel;
        float gray = (pixel.r + pixel.g + pixel.b) * 0.33333;
        float gi   = 1.0 / gray;
        float gii  = 1.0 / (1.0 - gray);
        float3 rgbsat = max((pixel.rgb - gray) * gii, (gray - pixel.rgb) * gi);
        float sat = max(max(rgbsat.r, rgbsat.g), rgbsat.b);
        float skin = min(pixel.r - pixel.g, pixel.g * 2.0 - pixel.b) * 4.0 * (1.0 - rgbsat.r) * gi;
        skin = 0.15 + clamp(skin, 0.0, 1.0) * 0.7;
        float boost = dot(vvec,float4(1.0, sat, sat*sat, sat*sat*sat)) * (1.0 - skin);
        pixel = clamp(pixel + (pixel - gray) * boost, 0.0, 1.0);
        pixel.a = pixel0.a;
        pixel.rgb += pdelta.rgb;
        return pixel;
    }
    
    METAL_FUNC float4 adjustVibrance(float4 colorInput, float vibrance, float3 grayColorTransform) {
        float luma = dot(grayColorTransform, colorInput.rgb); //calculate luma (grey)
        float max_color = max(colorInput.r, max(colorInput.g,colorInput.b)); //Find the strongest color
        float min_color = min(colorInput.r, min(colorInput.g,colorInput.b)); //Find the weakest color
        float color_saturation = max_color - min_color; //The difference between the two is the saturation
        float4 color = colorInput;
        color.rgb = mix(float3(luma), color.rgb, (1.0 + (vibrance * (1.0 - (sign(vibrance) * color_saturation))))); //extrapolate between luma and original by 1 + (1-saturation) - current
        //color.rgb = mix(vec3(luma), color.rgb, 1.0 + (1.0 - pow(color_saturation, 1.0 - (1.0 - vibrance))) ); //pow version
        return color; //return the result
        //return color_saturation.xxxx; //Visualize the saturation
    }
    
    METAL_FUNC float4 adjustSaturation(float4 textureColor, float saturation, float3 grayColorTransform) {
        /*
        float4 pixel = clamp(textureColor, 0.0001, 0.9999);
        float4 pdelta = textureColor - pixel;
        float gray = (pixel.r + pixel.g + pixel.b) * 0.33333;
        float gi   = 1.0 / gray;
        float gii  = 1.0 / (1.0 - gray);
        float3 rgbsat = max((pixel.rgb - gray) * gii, (gray - pixel.rgb) * gi);
        float sat = max(max(rgbsat.r, rgbsat.g), rgbsat.b);
        float skin = min(pixel.r - pixel.g, pixel.g * 2.0 - pixel.b) * 4.0 * (1.0 - rgbsat.r) * gi;
        skin = 0.15 + clamp(skin, 0.0, 1.0) * 0.7;
        float boost = ((sat * (sat - 1.0) + 1.0) * saturation) * (1.0-skin);
        pixel = clamp(pixel + (pixel - gray) * boost, 0.0, 1.0);
        pixel.a = textureColor.a;
        pixel.rgb += pdelta.rgb;
        return pixel;
        */
        float luma = dot(grayColorTransform, textureColor.rgb); //calculate luma (grey)
        return float4(mix(float3(luma), textureColor.rgb, saturation + 1.0), textureColor.a);
    }
}

#endif /* __METAL_MACOS__ || __METAL_IOS__ */

#endif /* MTIShader_h */

//
//  Halftone.metal
//  MetalPetal
//
//  Created by Yu Ao on 18/01/2018.
//

#include "MTIShaderLib.h"

using namespace metal;
using namespace metalpetal;

namespace metalpetal {
    namespace liquify {
        
        float2 convert_to_metal_coordinates(float2 pixelPoint, float2 viewSize) {
            float2 inverseViewSize = 1 / viewSize;
            float clipX = (2.0f * pixelPoint.x * inverseViewSize.x) - 1.0f;
            float clipY = (2.0f * -pixelPoint.y * inverseViewSize.y) + 1.0f;
            return float2(clipX, clipY);
        }

        float2 convert_to_pixel_coordinates(float2 clipPoint, float2 viewSize) {
            float xPixel = (viewSize.x * (clipPoint.x + 1.0f)) * 0.5f;
            float yPixel = (viewSize.y * (1.0f - clipPoint.y)) * 0.5f;
            return float2(xPixel, yPixel);
        }
        
    //    float2 convert_to_metal_coordinates(float2 pixelPoint, float2 viewSize) {
    ////        return pixelPoint;
    //        float clipX = pixelPoint.x / viewSize.x;
    //        float clipY = pixelPoint.y / viewSize.y;
    //        return float2(clipX, clipY);
    //    }
    //
    //    float2 convert_to_pixel_coordinates(float2 clipPoint, float2 viewSize) {
    ////        return clipPoint;
    //        float xPixel = clipPoint.x * viewSize.x;
    //        float yPixel = clipPoint.y * viewSize.y;
    //        return float2(xPixel, yPixel);
    //    }

        vertex VertexOut forwardWarp(
                const device VertexIn * vertices [[ buffer(0) ]],
                uint vid [[ vertex_id ]],
                constant float2 & size [[ buffer(1) ]],
                constant float2 & center [[ buffer(2) ]],
                constant float & radius [[ buffer(3) ]],
                constant float & direction [[ buffer(4) ]],
                constant float & strength [[ buffer(5) ]],
                constant float & density [[ buffer(6) ]]
            ) {
                VertexOut outVertex;
                VertexIn inVertex = vertices[vid];
                
                outVertex.position = inVertex.position;
                outVertex.textureCoordinate = inVertex.textureCoordinate;
                
                float2 position = convert_to_pixel_coordinates(float2(inVertex.position.x, inVertex.position.y),size);
                float distanceToCenter = distance(position, center);
    //
                if (distanceToCenter < radius) {
                    float2 targetOffset = float2(cos(direction), sin(direction)) * strength;

                    float distanceFactor = distanceToCenter/radius;

                    targetOffset = targetOffset * (1 - density * distanceFactor);
                    float newX = position.x + targetOffset.x;
                    float newY = position.y + targetOffset.y;
    //
                    float2 newPosition = convert_to_metal_coordinates(float2(newX, newY), size);
                    outVertex.position.x = newPosition.x;
                    outVertex.position.y = newPosition.y;

                } else {
                    outVertex.position = inVertex.position;
                }
            
    //            float2 newPosition = convert_to_metal_coordinates(float2(position.x+radius, position.y), size);
    //            outVertex.position = inVertex.position;
    //            outVertex.position.x = newPosition.x;
    //            outVertex.position.y = newPosition.y;
            
                return outVertex;
        }
        
    //    float lineDist(float2 p, float2 start, float2 end, float width)
    //    {
    //        float2 dir = start - end;
    //        float lngth = length(dir);
    //        dir /= lngth;
    //        float2 proj = max(0.0, min(lngth, dot((start - p), dir))) * dir;
    //        return length( (start - p) - proj ) - (width / 2.0);
    //    }
    //
    //    METAL_FUNC float3 rgb2yuv(float3 color) {
    //        float y =  0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
    //        float u = -0.147 * color.r - 0.289 * color.g + 0.436 * color.b;
    //        float v =  0.615 * color.r - 0.515 * color.g - 0.100 * color.b;
    //        return float3(y, u, v);
    //    }
    //
    //    METAL_FUNC float3 yuv2rgb(float3 color) {
    //        float y = color.r; float u = color.g; float v = color.b;
    //        float r = y + 1.14 * v;
    //        float g = y - 0.39 * u - 0.58 * v;
    //        float b = y + 2.03 * u;
    //        return float3(r, g, b);
    //    }
    //
    //    // from http://www.java-gaming.org/index.php?topic=35123.0
    //    float4 cubic(float v){
    //        float4 n = float4(1.0, 2.0, 3.0, 4.0) - v;
    //        float4 s = n * n * n;
    //        float x = s.x;
    //        float y = s.y - 4.0 * s.x;
    //        float z = s.z - 4.0 * s.y + 6.0 * s.x;
    //        float w = 6.0 - x - y - z;
    //        return float4(x, y, z, w) * (1.0/6.0);
    //    }
    //    float4 cubic(float v)
    //    {
    //        float4 n = float4(1.0, 2.0, 3.0, 4.0) - v;
    //        float4 s = n * n * n;
    //        float x = s.x;
    //        float y = s.y - 4.0 * s.x;
    //        float z = s.z - 4.0 * s.y + 6.0 * s.x;
    //        float w = 6.0 - x - y - z;
    //        return float4(x, y, z, w);
    //    }

    //    float4 textureBicubic(texture2d<float, access::sample> sourceTexture, sampler sampler, float2 texCoords){
    //        float2 texSize = float2(sourceTexture.get_width(), sourceTexture.get_height());
    //        float2 invTexSize = 1.0 / texSize;
    //
    //        texCoords = texCoords * texSize - 0.5;
    //
    //        float2 fxy = fract(texCoords);
    //        texCoords -= fxy;
    //
    //        float4 xcubic = cubic(fxy.x);
    //        float4 ycubic = cubic(fxy.y);
    //
    //        float4 c = texCoords.xxyy + float2(-0.5, +1.5).xyxy;
    //
    //        float4 s = float4(xcubic.xz + xcubic.yw, ycubic.xz + ycubic.yw);
    //        float4 offset = c + float4(xcubic.yw, ycubic.yw) / s;
    //
    //        offset *= invTexSize.xxyy;
    //
    //        float4 sample0 = sourceTexture.sample(sampler, offset.xz);
    //        float4 sample1 = sourceTexture.sample(sampler, offset.yz);
    //        float4 sample2 = sourceTexture.sample(sampler, offset.xw);
    //        float4 sample3 = sourceTexture.sample(sampler, offset.yw);
    //
    //        float sx = s.x / (s.x + s.y);
    //        float sy = s.z / (s.z + s.w);
    //
    //        return mix(
    //                   mix(sample3, sample2, sx),
    //                   mix(sample1, sample0, sx),
    //                   sy
    //                   );
    //    }
         
        //=======================================================================================
        float4 CubicLagrange1(float4 A, float4 B, float4 C, float4 D, float4 E, float4 F, float t) {
            float c_x0 = -2.0;
            float c_x1 = -1.0;
            float c_x2 =  0.0;
            float c_x3 =  1.0;
            float c_x4 =  2.0;
            float c_x5 =  3.0;
            return
                A *
                (
                    (t - c_x1) / (c_x0 - c_x1) *
                    (t - c_x2) / (c_x0 - c_x2) *
                    (t - c_x3) / (c_x0 - c_x3) *
                    (t - c_x4) / (c_x0 - c_x4) *
                    (t - c_x5) / (c_x0 - c_x5)
                ) +
                B *
                (
                    (t - c_x0) / (c_x1 - c_x0) *
                    (t - c_x2) / (c_x1 - c_x2) *
                    (t - c_x3) / (c_x1 - c_x3) *
                    (t - c_x4) / (c_x1 - c_x4) *
                    (t - c_x5) / (c_x1 - c_x5)
                ) +
                C *
                (
                    (t - c_x0) / (c_x2 - c_x0) *
                    (t - c_x1) / (c_x2 - c_x1) *
                    (t - c_x3) / (c_x2 - c_x3) *
                    (t - c_x4) / (c_x2 - c_x4) *
                    (t - c_x5) / (c_x2 - c_x5)
                ) +
                D *
                (
                    (t - c_x0) / (c_x3 - c_x0) *
                    (t - c_x1) / (c_x3 - c_x1) *
                    (t - c_x2) / (c_x3 - c_x2) *
                    (t - c_x4) / (c_x3 - c_x4) *
                    (t - c_x5) / (c_x3 - c_x5)
                ) +
                E *
                (
                    (t - c_x0) / (c_x4 - c_x0) *
                    (t - c_x1) / (c_x4 - c_x1) *
                    (t - c_x2) / (c_x4 - c_x2) *
                    (t - c_x3) / (c_x4 - c_x3) *
                    (t - c_x5) / (c_x4 - c_x5)
                ) +
                F *
                (
                    (t - c_x0) / (c_x5 - c_x0) *
                    (t - c_x1) / (c_x5 - c_x1) *
                    (t - c_x2) / (c_x5 - c_x2) *
                    (t - c_x3) / (c_x5 - c_x3) *
                    (t - c_x4) / (c_x5 - c_x4)
                );
        }

        //=======================================================================================
        float4 bicubicLagrangeTextureSample1(float2 point, float2 textureSize, texture2d<float, access::sample> sourceTexture, sampler textureSampler) {
            float2 pixel = point * textureSize + 0.5;

            float2 frac = fract(pixel);
            pixel = floor(pixel) - 0.5;

            float4 C00 = sourceTexture.sample(textureSampler, (pixel + float2(-2.0, -2.0)) / textureSize);
            float4 C10 = sourceTexture.sample(textureSampler, (pixel + float2(-1.0, -2.0)) / textureSize);
            float4 C20 = sourceTexture.sample(textureSampler, (pixel + float2( 0.0, -2.0)) / textureSize);
            float4 C30 = sourceTexture.sample(textureSampler, (pixel + float2( 1.0, -2.0)) / textureSize);
            float4 C40 = sourceTexture.sample(textureSampler, (pixel + float2( 2.0, -2.0)) / textureSize);
            float4 C50 = sourceTexture.sample(textureSampler, (pixel + float2( 3.0, -2.0)) / textureSize);
            
            float4 C01 = sourceTexture.sample(textureSampler, (pixel + float2(-2.0, -1.0)) / textureSize);
            float4 C11 = sourceTexture.sample(textureSampler, (pixel + float2(-1.0, -1.0)) / textureSize);
            float4 C21 = sourceTexture.sample(textureSampler, (pixel + float2( 0.0, -1.0)) / textureSize);
            float4 C31 = sourceTexture.sample(textureSampler, (pixel + float2( 2.0, -1.0)) / textureSize);
            float4 C41 = sourceTexture.sample(textureSampler, (pixel + float2( 2.0, -1.0)) / textureSize);
            float4 C51 = sourceTexture.sample(textureSampler, (pixel + float2( 3.0, -1.0)) / textureSize);

            float4 C02 = sourceTexture.sample(textureSampler, (pixel + float2(-2.0, 0.0)) / textureSize);
            float4 C12 = sourceTexture.sample(textureSampler, (pixel + float2(-1.0, 0.0)) / textureSize);
            float4 C22 = sourceTexture.sample(textureSampler, (pixel + float2( 0.0, 0.0)) / textureSize);
            float4 C32 = sourceTexture.sample(textureSampler, (pixel + float2( 1.0, 0.0)) / textureSize);
            float4 C42 = sourceTexture.sample(textureSampler, (pixel + float2( 2.0, 0.0)) / textureSize);
            float4 C52 = sourceTexture.sample(textureSampler, (pixel + float2( 3.0, 0.0)) / textureSize);

            float4 C03 = sourceTexture.sample(textureSampler, (pixel + float2(-2.0, 1.0)) / textureSize);
            float4 C13 = sourceTexture.sample(textureSampler, (pixel + float2(-1.0, 1.0)) / textureSize);
            float4 C23 = sourceTexture.sample(textureSampler, (pixel + float2( 0.0, 1.0)) / textureSize);
            float4 C33 = sourceTexture.sample(textureSampler, (pixel + float2( 1.0, 1.0)) / textureSize);
            float4 C43 = sourceTexture.sample(textureSampler, (pixel + float2( 2.0, 1.0)) / textureSize);
            float4 C53 = sourceTexture.sample(textureSampler, (pixel + float2( 3.0, 1.0)) / textureSize);

            float4 C04 = sourceTexture.sample(textureSampler, (pixel + float2(-2.0, 2.0)) / textureSize);
            float4 C14 = sourceTexture.sample(textureSampler, (pixel + float2(-1.0, 2.0)) / textureSize);
            float4 C24 = sourceTexture.sample(textureSampler, (pixel + float2( 0.0, 2.0)) / textureSize);
            float4 C34 = sourceTexture.sample(textureSampler, (pixel + float2( 1.0, 2.0)) / textureSize);
            float4 C44 = sourceTexture.sample(textureSampler, (pixel + float2( 2.0, 2.0)) / textureSize);
            float4 C54 = sourceTexture.sample(textureSampler, (pixel + float2( 3.0, 2.0)) / textureSize);
            
            float4 C05 = sourceTexture.sample(textureSampler, (pixel + float2(-2.0, 3.0)) / textureSize);
            float4 C15 = sourceTexture.sample(textureSampler, (pixel + float2(-1.0, 3.0)) / textureSize);
            float4 C25 = sourceTexture.sample(textureSampler, (pixel + float2( 0.0, 3.0)) / textureSize);
            float4 C35 = sourceTexture.sample(textureSampler, (pixel + float2( 1.0, 3.0)) / textureSize);
            float4 C45 = sourceTexture.sample(textureSampler, (pixel + float2( 2.0, 3.0)) / textureSize);
            float4 C55 = sourceTexture.sample(textureSampler, (pixel + float2( 3.0, 3.0)) / textureSize);
            
            float4 CP0X = CubicLagrange1(C00, C10, C20, C30, C40, C50, frac.x);
            float4 CP1X = CubicLagrange1(C01, C11, C21, C31, C41, C51, frac.x);
            float4 CP2X = CubicLagrange1(C02, C12, C22, C32, C42, C52, frac.x);
            float4 CP3X = CubicLagrange1(C03, C13, C23, C33, C43, C53, frac.x);
            float4 CP4X = CubicLagrange1(C04, C14, C24, C34, C44, C54, frac.x);
            float4 CP5X = CubicLagrange1(C05, C15, C25, C35, C45, C55, frac.x);

            return CubicLagrange1(CP0X, CP1X, CP2X, CP3X, CP4X, CP5X, frac.y);
        }
        
        
        //=======================================================================================
        float4 CubicLagrange (float4 A, float4 B, float4 C, float4 D, float t) {
            float c_x0 = -1.0;
            float c_x1 =  0.0;
            float c_x2 =  1.0;
            float c_x3 =  2.0;
            return
                A *
                (
                    (t - c_x1) / (c_x0 - c_x1) *
                    (t - c_x2) / (c_x0 - c_x2) *
                    (t - c_x3) / (c_x0 - c_x3)
                ) +
                B *
                (
                    (t - c_x0) / (c_x1 - c_x0) *
                    (t - c_x2) / (c_x1 - c_x2) *
                    (t - c_x3) / (c_x1 - c_x3)
                ) +
                C *
                (
                    (t - c_x0) / (c_x2 - c_x0) *
                    (t - c_x1) / (c_x2 - c_x1) *
                    (t - c_x3) / (c_x2 - c_x3)
                ) +
                D *
                (
                    (t - c_x0) / (c_x3 - c_x0) *
                    (t - c_x1) / (c_x3 - c_x1) *
                    (t - c_x2) / (c_x3 - c_x2)
                );
        }

        //=======================================================================================
        float4 bicubicLagrangeTextureSample(float2 point, float2 textureSize, texture2d<float, access::sample> sourceTexture, sampler textureSampler) {
            float2 pixel = point * textureSize + 0.5;

            float2 frac = fract(pixel);
            pixel = floor(pixel) - 0.5;

            float4 C00 = sourceTexture.sample(textureSampler, (pixel + float2(-1.0, -1.0)) / textureSize);
            float4 C10 = sourceTexture.sample(textureSampler, (pixel + float2( 0.0, -1.0)) / textureSize);
            float4 C20 = sourceTexture.sample(textureSampler, (pixel + float2( 1.0, -1.0)) / textureSize);
            float4 C30 = sourceTexture.sample(textureSampler, (pixel + float2( 2.0, -1.0)) / textureSize);

            float4 C01 = sourceTexture.sample(textureSampler, (pixel + float2(-1.0, 0.0)) / textureSize);
            float4 C11 = sourceTexture.sample(textureSampler, (pixel + float2( 0.0, 0.0)) / textureSize);
            float4 C21 = sourceTexture.sample(textureSampler, (pixel + float2( 1.0, 0.0)) / textureSize);
            float4 C31 = sourceTexture.sample(textureSampler, (pixel + float2( 2.0, 0.0)) / textureSize);

            float4 C02 = sourceTexture.sample(textureSampler, (pixel + float2(-1.0, 1.0)) / textureSize);
            float4 C12 = sourceTexture.sample(textureSampler, (pixel + float2( 0.0, 1.0)) / textureSize);
            float4 C22 = sourceTexture.sample(textureSampler, (pixel + float2( 1.0, 1.0)) / textureSize);
            float4 C32 = sourceTexture.sample(textureSampler, (pixel + float2( 2.0, 1.0)) / textureSize);

            float4 C03 = sourceTexture.sample(textureSampler, (pixel + float2(-1.0, 2.0)) / textureSize);
            float4 C13 = sourceTexture.sample(textureSampler, (pixel + float2( 0.0, 2.0)) / textureSize);
            float4 C23 = sourceTexture.sample(textureSampler, (pixel + float2( 1.0, 2.0)) / textureSize);
            float4 C33 = sourceTexture.sample(textureSampler, (pixel + float2( 2.0, 2.0)) / textureSize);
            
            float4 CP0X = CubicLagrange(C00, C10, C20, C30, frac.x);
            float4 CP1X = CubicLagrange(C01, C11, C21, C31, frac.x);
            float4 CP2X = CubicLagrange(C02, C12, C22, C32, frac.x);
            float4 CP3X = CubicLagrange(C03, C13, C23, C33, frac.x);

            return CubicLagrange(CP0X, CP1X, CP2X, CP3X, frac.y);
        }
        
        //=======================================================================================
        float4 CubicHermite1 (float4 A, float4 B, float4 C, float4 D, float t) {
            float t2 = t*t;
            float t3 = t*t*t;
            float4 a = -A/2.0   + (3.0*B)/2.0   - (3.0*C)/2.0   + D/2.0;
            float4 b = A        - (5.0*B)/2.0   + 2.0*C         - D/2.0;
            float4 c = -A/2.0                   + C/2.0;
            float4 d =          B;
            return a*t3 + b*t2 + c*t + d;
        }

        //=======================================================================================
        float4 bicubicHermiteTextureSample1(float2 point, float2 textureSize, texture2d<float, access::sample> sourceTexture, sampler textureSampler) {
            float2 pixel = point * textureSize + 0.5;

            float2 frac = fract(pixel);
            pixel = floor(pixel) - 0.5;
            
            float4 C00 = sourceTexture.sample(textureSampler, (pixel + float2(-1.0, -1.0)) / textureSize);
            float4 C10 = sourceTexture.sample(textureSampler, (pixel + float2( 0.0, -1.0)) / textureSize);
            float4 C20 = sourceTexture.sample(textureSampler, (pixel + float2( 1.0, -1.0)) / textureSize);
            float4 C30 = sourceTexture.sample(textureSampler, (pixel + float2( 2.0, -1.0)) / textureSize);

            float4 C01 = sourceTexture.sample(textureSampler, (pixel + float2(-1.0, 0.0)) / textureSize);
            float4 C11 = sourceTexture.sample(textureSampler, (pixel + float2( 0.0, 0.0)) / textureSize);
            float4 C21 = sourceTexture.sample(textureSampler, (pixel + float2( 1.0, 0.0)) / textureSize);
            float4 C31 = sourceTexture.sample(textureSampler, (pixel + float2( 2.0, 0.0)) / textureSize);

            float4 C02 = sourceTexture.sample(textureSampler, (pixel + float2(-1.0, 1.0)) / textureSize);
            float4 C12 = sourceTexture.sample(textureSampler, (pixel + float2( 0.0, 1.0)) / textureSize);
            float4 C22 = sourceTexture.sample(textureSampler, (pixel + float2( 1.0, 1.0)) / textureSize);
            float4 C32 = sourceTexture.sample(textureSampler, (pixel + float2( 2.0, 1.0)) / textureSize);

            float4 C03 = sourceTexture.sample(textureSampler, (pixel + float2(-1.0, 2.0)) / textureSize);
            float4 C13 = sourceTexture.sample(textureSampler, (pixel + float2( 0.0, 2.0)) / textureSize);
            float4 C23 = sourceTexture.sample(textureSampler, (pixel + float2( 1.0, 2.0)) / textureSize);
            float4 C33 = sourceTexture.sample(textureSampler, (pixel + float2( 2.0, 2.0)) / textureSize);

            float4 CP0X = CubicHermite1(C00, C10, C20, C30, frac.x);
            float4 CP1X = CubicHermite1(C01, C11, C21, C31, frac.x);
            float4 CP2X = CubicHermite1(C02, C12, C22, C32, frac.x);
            float4 CP3X = CubicHermite1(C03, C13, C23, C33, frac.x);

            return CubicHermite1(CP0X, CP1X, CP2X, CP3X, frac.y);
        }

        //=======================================================================================
        float4 CubicHermite (float4 A, float4 B, float4 C, float4 D, float t) {
            float t2 = t*t;
            float t3 = t*t*t;
            float4 a = -A/2.0 + (3.0*B)/2.0 - (3.0*C)/2.0 + D/2.0;
            float4 b = A - (5.0*B)/2.0 + 2.0*C - D / 2.0;
            float4 c = -A/2.0 + C/2.0;
            float4 d = B;
            return a*t3 + b*t2 + c*t + d;
        }

        //=======================================================================================
        float4 bicubicHermiteTextureSample(float2 point, float2 c_textureSize, texture2d<float, access::sample> sourceTexture, sampler textureSampler) {
            float2 pixel = point * c_textureSize + 0.5;

            float2 frac = fract(pixel);
            pixel = (floor(pixel) - float2(0.5)) / c_textureSize;

            float4 C00 = sourceTexture.sample(textureSampler, pixel + float2(-1.0, -1.0) / c_textureSize);
            float4 C10 = sourceTexture.sample(textureSampler, pixel + float2( 0.0, -1.0) / c_textureSize);
            float4 C20 = sourceTexture.sample(textureSampler, pixel + float2( 1.0, -1.0) / c_textureSize);
            float4 C30 = sourceTexture.sample(textureSampler, pixel + float2( 2.0, -1.0) / c_textureSize);

            float4 C01 = sourceTexture.sample(textureSampler, pixel + float2(-1.0, 0.0) / c_textureSize);
            float4 C11 = sourceTexture.sample(textureSampler, pixel + float2( 0.0, 0.0) / c_textureSize);
            float4 C21 = sourceTexture.sample(textureSampler, pixel + float2( 1.0, 0.0) / c_textureSize);
            float4 C31 = sourceTexture.sample(textureSampler, pixel + float2( 2.0, 0.0) / c_textureSize);

            float4 C02 = sourceTexture.sample(textureSampler, pixel + float2(-1.0, 1.0) / c_textureSize);
            float4 C12 = sourceTexture.sample(textureSampler, pixel + float2( 0.0, 1.0) / c_textureSize);
            float4 C22 = sourceTexture.sample(textureSampler, pixel + float2( 1.0, 1.0) / c_textureSize);
            float4 C32 = sourceTexture.sample(textureSampler, pixel + float2( 2.0, 1.0) / c_textureSize);

            float4 C03 = sourceTexture.sample(textureSampler, pixel + float2(-1.0, 2.0) / c_textureSize);
            float4 C13 = sourceTexture.sample(textureSampler, pixel + float2( 0.0, 2.0) / c_textureSize);
            float4 C23 = sourceTexture.sample(textureSampler, pixel + float2( 1.0, 2.0) / c_textureSize);
            float4 C33 = sourceTexture.sample(textureSampler, pixel + float2( 2.0, 2.0) / c_textureSize);

            float4 CP0X = CubicHermite(C00, C10, C20, C30, frac.x);
            float4 CP1X = CubicHermite(C01, C11, C21, C31, frac.x);
            float4 CP2X = CubicHermite(C02, C12, C22, C32, frac.x);
            float4 CP3X = CubicHermite(C03, C13, C23, C33, frac.x);

            return CubicHermite(CP0X, CP1X, CP2X, CP3X, frac.y);
        }
        
        //=======================================================================================
        float4 bilinearTextureSample(float2 point, float2 textureSize, texture2d<float, access::sample> sourceTexture, sampler textureSampler) {
            float2 pixel = point * textureSize + 0.5;

            float2 frac = fract(pixel);
            pixel = floor(pixel) - 0.5;

            float4 C00 = sourceTexture.sample(textureSampler, (pixel + float2(0.0, 0.0)) / textureSize);
            float4 C10 = sourceTexture.sample(textureSampler, (pixel + float2(1.0, 0.0)) / textureSize);
            float4 C01 = sourceTexture.sample(textureSampler, (pixel + float2(0.0, 1.0)) / textureSize);
            float4 C11 = sourceTexture.sample(textureSampler, (pixel + float2(1.0, 1.0)) / textureSize);

            float4 x1 = mix(C00, C10, frac.x);
            float4 x2 = mix(C01, C11, frac.x);
            return mix(x1, x2, frac.y);
        }
        
        //=======================================================================================
        float4 bilinearTextureSample1(float2 targetPoint, float2 textureSize, texture2d<float, access::sample> sourceTexture, sampler textureSampler) {
            float2 pixel = targetPoint * textureSize;
            
            float2 frac = fract(pixel);
    //        pixel = floor(pixel) + 0.5;
            
            float2 P00 = (pixel + float2(-1.0, -1.0));
            float2 P10 = (pixel + float2( 0.0, -1.0));
            float2 P20 = (pixel + float2( 1.0, -1.0));
            float2 P01 = (pixel + float2(-1.0,  0.0));
            float2 P11 = (pixel + float2( 0.0,  0.0));
            float2 P21 = (pixel + float2( 1.0,  0.0));
            float2 P02 = (pixel + float2(-1.0,  1.0));
            float2 P12 = (pixel + float2( 0.0,  1.0));
            float2 P22 = (pixel + float2( 1.0,  1.0));

            float4 C00 = sourceTexture.sample(textureSampler, P00 / textureSize);
            float4 C10 = sourceTexture.sample(textureSampler, P10 / textureSize);
            float4 C20 = sourceTexture.sample(textureSampler, P20 / textureSize);
            float4 C01 = sourceTexture.sample(textureSampler, P01 / textureSize);
            float4 C11 = sourceTexture.sample(textureSampler, P11 / textureSize);
            float4 C21 = sourceTexture.sample(textureSampler, P21 / textureSize);
            float4 C02 = sourceTexture.sample(textureSampler, P02 / textureSize);
            float4 C12 = sourceTexture.sample(textureSampler, P12 / textureSize);
            float4 C22 = sourceTexture.sample(textureSampler, P22 / textureSize);
            
            float D00 = distance(pixel, P00);
            float D10 = distance(pixel, P10);
            float D20 = distance(pixel, P20);
            float D01 = distance(pixel, P01);
            float D11 = distance(pixel, P11);
            float D21 = distance(pixel, P21);
            float D02 = distance(pixel, P02);
            float D12 = distance(pixel, P12);
            float D22 = distance(pixel, P22);
            
            if (frac.x < 0.5 && frac.y < 0.5) {
                float t = D00 + D10 + D01 + D11;
                float t3 = t * 4 - t;
                return C00 * (t - D00) / t3
                     + C10 * (t - D10) / t3
                     + C01 * (t - D01) / t3
                     + C11 * (t - D11) / t3;
            } else if (frac.x > 0.5 && frac.y < 0.5) {
                float t = D10 + D20 + D11 + D21;
                float t3 = t * 4 - t;
                return C10 * (t - D10) / t3
                     + C20 * (t - D20) / t3
                     + C11 * (t - D11) / t3
                     + C21 * (t - D21) / t3;
            } else if (frac.x < 0.5 && frac.y > 0.5) {
                float t = D01 + D11 + D02 + D12;
                float t3 = t * 4 - t;
                return C01 * (t - D01) / t3
                     + C11 * (t - D11) / t3
                     + C02 * (t - D02) / t3
                     + C12 * (t - D12) / t3;
            } else if (frac.x > 0.5 && frac.y > 0.5) {
                float t = D11 + D21 + D12 + D22;
                float t3 = t * 4 - t;
                return C11 * (t - D11) / t3
                     + C21 * (t - D21) / t3
                     + C12 * (t - D12) / t3
                     + C22 * (t - D22) / t3;
            } else {
                return C11;
            }
        }
        
        fragment float4 liquify(VertexOut vertexIn [[stage_in]],
                                        texture2d<float, access::sample> sourceTexture [[texture(0)]],
                                        sampler sourceSampler [[sampler(0)]],
                                        constant float2 & oldCenter [[ buffer(0) ]],
                                        constant float2 & center [[ buffer(1) ]],
                                        constant float & radius [[ buffer(2) ]],
                                        constant float & pressure [[ buffer(3) ]]) {
            
    //        constexpr sampler textureSampler(mag_filter::bicubic, min_filter::bicubic);
    //        constexpr sampler textureSamplerNearest(mag_filter::nearest, min_filter::nearest);
    //        constexpr sampler textureSampler(coord::pixel, address::clamp_to_edge, filter::bicubic);
    //        constexpr sampler textureSamplerNearest(coord::pixel, address::clamp_to_zero, filter::nearest);
    //        constexpr sampler textureSampler(coord::pixel, address::clamp_to_zero, filter::bicubic);
            constexpr sampler textureSampler(coord::normalized, address::clamp_to_zero, filter::nearest);
            
            float2 textureSize = float2(sourceTexture.get_width(), sourceTexture.get_height());
            float2 currentNormalizedCoordinate = vertexIn.textureCoordinate;
            
            float2 currentPixelCoordinate = vertexIn.position.xy;
            float dist = distance(currentPixelCoordinate, oldCenter);
    //        float dist = lineDist(vertexIn.textureCoordinate * textureSize, oldCenter, center, .0);
            
            if (dist > radius) {
                return sourceTexture.sample(textureSampler, currentNormalizedCoordinate);
    //            return sourceTexture.sample(textureSampler, texturePixelCoordinate);
            }
            
    //        float2 diff = (center - oldCenter) * (1-dist/radius)*(1-dist/radius) * pressure;
            
    ////        float a = 1;
    //        float b = 1;
    //        float c = 0;
    ////        float d = 0;
    //        float r = (1-dist/radius);
    //        float x = r * 10 * 2 - 10;
    //
    ////        float y = (a / (1 + exp(-b * (x+c))) + d);
    //        float y = 1.0 / (1.0 + exp(-b * (x+c)));
    ////        float y = 1.0 / (1.0 + exp(-x));
            
            
            float y = (1-dist/radius);
            y = smoothstep(0, 1, y);
            
    //        float r = dist;
    //        float interpolationFactor = r / radius;
    //        float _constant = 1.0;
    //        r = interpolationFactor * r + (1.0 - interpolationFactor) * _constant * sqrt(r);
    //        float y = (1-r/radius) * (1-r/radius);

    //        float2 diff = (center - oldCenter) * (1-dist/radius) * pressure;
            float2 diff = (center - oldCenter) * y * pressure;
            float2 targetPixelCoordinate = currentPixelCoordinate - diff;
            
    //        oldPixelCoordinate = floor(oldPixelCoordinate) + 0.5;

            float interval = 2;
            float limit = 2;
            float ratio[2];
            
            ratio[0] = 1.0;
            ratio[1] = 0.0;
    //        ratio[2] = 0.06;
    //        ratio[3] = 0.04;
    //        ratio[2] = 0.1;
    //
    //        int i = 0;
    //        while (i)
    //        for (int i = 0; i < interval; i++) {
    //            if (i == limit) {
    //                break;
    //            }
    ////            finalColor += sourceTexture.sample(textureSampler, oldPixelCoordinate + diff * (float(i) / interval));
    //            finalColor += sourceTexture.sample(textureSampler, targetPixelCoordinate + diff * (float(i) / interval)) * ratio[i];
    //        }
    ////        finalColor /= interval;
    //        return finalColor;

            
    //        float2 textureCoordinate = oldPixelCoordinate;
            float2 targetNormalizedCoordinate = targetPixelCoordinate / textureSize;
            
            constexpr sampler linearSampler(coord::normalized, address::clamp_to_zero, filter::linear);
            constexpr sampler bicubicSampler(coord::normalized, address::clamp_to_zero, filter::bicubic);
            constexpr sampler nearestSampler(coord::normalized, address::clamp_to_zero, filter::nearest);
    //
            float4 currentTextureColor = sourceTexture.sample(nearestSampler, currentNormalizedCoordinate);
            float4 targetTextureColor = sourceTexture.sample(bicubicSampler, targetNormalizedCoordinate);
            
    //        float4 textureColor = mix(targetTextureColor, currentTextureColor, 1-y);
            
    //        float4 targetTextureColor = sourceTexture.sample(textureSampler, textureCoordinate);
    //        float4 targetTextureColor = textureBicubic(sourceTexture, textureSampler, textureCoordinate);
    //        float4 targetTextureColor = bilinearTextureSample1(targetNormalizedCoordinate, textureSize, sourceTexture, bicubicSampler);
    //        float4 targetTextureColor = bicubicHermiteTextureSample1(targetNormalizedCoordinate, textureSize, sourceTexture, nearestSampler);
    //        float4 targetTextureColor = bicubicLagrangeTextureSample(targetNormalizedCoordinate, textureSize, sourceTexture, nearestSampler);
            
            float4 textureColor = targetTextureColor;
    //        float4 textureColor = currentTextureColor * 0.05 + targetTextureColor * 0.95; //  mix(targetTextureColor, currentTextureColor, (1-y)*0.99+0.01)
            
    //        textureColor = unpremultiply(textureColor);
    //        return premultiply(textureColor);
    //        return float4(sRGBToLinear(textureColor.rgb), textureColor.a);
            
    //        textureCoordinate = float2((floor(textureCoordinate.x*textureSize.x)+(vertexIn.textureCoordinate.x*textureSize.x-floor(vertexIn.textureCoordinate.x*textureSize.x)))/textureSize.x,
    //                                   (floor(textureCoordinate.y*textureSize.y)+(vertexIn.textureCoordinate.y*textureSize.y-floor(vertexIn.textureCoordinate.y*textureSize.y)))/textureSize.y);
            
    //        textureCoordinate = float2(floor(textureCoordinate.x*textureSize.x)/textureSize.x,
    //                                   floor(textureCoordinate.x*textureSize.y)/textureSize.y);
            
    //        return sourceTexture.sample(sourceSampler, textureCoordinate);
            
    //        if (dist > radius - 3) {
    //            float4 textureColor = sourceTexture.sample(textureSampler2, textureCoordinate);
    //            return float4(1,0,1,textureColor.a);
    //        } else {
            
    //        float4 textureColor = sourceTexture.sample(sourceSampler, textureCoordinate);
            
    //        float4 textureColor = sourceTexture.sample(textureSampler, textureCoordinate);
    //
    //        float scale = 0.5;
    //        float threshold = 0.0;
    //
    //        float4 blurColor = sourceTexture.sample(textureSamplerBlur, textureCoordinate);
    //        float3 textureYUV = rgb2yuv(textureColor.rgb);
    //        float3 blurYUV = rgb2yuv(blurColor.rgb);
    //        if (abs(textureYUV.r - blurYUV.r) < threshold) {
    //            return textureColor;
    //        }
    //        float sharpenY = textureYUV.r*(1+scale) - scale*blurYUV.r;
    //        float3 temp = yuv2rgb(float3(sharpenY, textureYUV.gb));
    //        return float4(temp, textureColor.a);
            
            
    //        float _Intensity = 0.05;

    //        float4 c0 = sourceTexture.sample(textureSampler, textureCoordinate + float2(-1,-1)) * 0;
    //        float4 c1 = sourceTexture.sample(textureSampler, textureCoordinate + float2( 0,-1)) * -1;
    //        float4 c2 = sourceTexture.sample(textureSampler, textureCoordinate + float2(+1,-1)) * 0;
    //
    //        float4 c3 = sourceTexture.sample(textureSampler, textureCoordinate + float2(-1, 0)) * -1;
    //        float4 c4 = sourceTexture.sample(textureSampler, textureCoordinate + float2( 0, 0)) * 5;
    //        float4 c5 = sourceTexture.sample(textureSampler, textureCoordinate + float2(+1, 0)) * -1;
    //
    //        float4 c6 = sourceTexture.sample(textureSampler, textureCoordinate + float2(-1,+1)) * 0;
    //        float4 c7 = sourceTexture.sample(textureSampler, textureCoordinate + float2( 0,+1)) * -1;
    //        float4 c8 = sourceTexture.sample(textureSampler, textureCoordinate + float2(+1,+1)) * 0;
    //
    //        float4 a = c0 + c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8;
    //
    //        return float4(clamp(a.r,0.0,1.0), clamp(a.g,0.0,1.0), clamp(a.b,0.0,1.0), clamp(a.a,0.0,1.0));
            
    //        float4 a = c4 - (c0 + c1 + c2 + c3 - 8 * c4 + c5 + c6 + c7 + c8) * _Intensity;
    //        return float4(textureColor.rgb, a.a);
            
    //        float4 textureColorNestest = sourceTexture.sample(textureSamplerNearest, textureCoordinate);
    //        return float4(textureColor.r,textureColor.g,textureColor.b,textureColorNestest.a);
            
    //        int level = 0;
    //        int oneSideCount = (level*2)+1;
    //        int totalCount = oneSideCount * oneSideCount;
    //        float4 c = textureColor;
    ////            if (c.a == 0) {
    ////                c.rgb = 1;
    ////            }
    //        int rgbCount = 1;
    //        int aCount = 1;
    //
    //        for (int i = 0; i < totalCount; i++) {
    //            float2 p = float2(i % oneSideCount - level, i / oneSideCount - level);
    //            if (p.x == 0 && p.y == 0) {
    //                continue;
    //            }
    //            float2 location = float2(vertexIn.position.x+p.x, vertexIn.position.y+p.y);
    //            float2 centerlocation = vertexIn.position.xy;
    //            float d = distance(location, centerlocation);
    //            if (d > level) {
    //                continue;
    //            }
    //            float factor = 1.0;
    ////                if (d < distance(location, parameters.lastPosition)) {
    //////                    factor = 0.5;
    ////                    continue;
    ////                }
    //            float4 color = sourceTexture.sample(textureSampler, location);
    //            if (color.a == 0) {
    ////                    color.rgb = 1;
    ////                    c.a = c.a + color.a;
    //                aCount = aCount + factor;
    //            } else {
    //                c.rgb = c.rgb + color.rgb;
    //                rgbCount = rgbCount + factor;
    //                c.a = c.a + color.a;
    //                aCount = aCount + factor;
    //            }
    ////                color = parameters.compositingMaskHasPremultipliedAlpha ? unpremultiply(color) : color;
    //        }
    //        c.rgb = c.rgb / rgbCount;
    //        c.a = c.a / aCount;
    ////            finalColor = c.a * textureColor.a + currentColor * (1-textureColor.a);
    ////            c.a = c.a * textureColor.a;
    //        textureColor = c;
            
    //        textureColor = unpremultiply(textureColor);
    //            return float4(1,0,1,textureColor.a);
    //        }
            
            return textureColor;
        }
        
        
        
    }
}


//
//  MTIMultilayerCompositingFilter.swift
//  Atelier
//
//  Created by Lung on 24/1/2026.
//  Copyright © 2026 command b. All rights reserved.
//

import CoreGraphics
import Metal

#if SWIFT_PACKAGE
import MetalPetalObjectiveC.Core
#endif

/// A filter that allows you to compose multiple `MTILayer` objects onto a background image.
/// A `MTIMultilayerCompositingFilter` object skips the actual rendering when its `layers.count` is zero.
public final class MTIMultilayerCompositingFilter: NSObject, MTIFilter {

    // MARK: - Properties

    public var inputBackgroundImage: MTIImage?

    public var layers: [MTILayer] = []

    public var rasterSampleCount: UInt = 1
    
    /// Array of NSValue wrapping CGRects
    public var scissorRects: [NSValue]? = nil

    /// Specifies the alpha type of output image. If `.alphaIsOne` is assigned, the alpha channel of the output image will be set to 1.
    /// The default value for this property is `.nonPremultiplied`.
    public var outputAlphaType: MTIAlphaType = .nonPremultiplied
    
    public var outputPixelFormat: MTLPixelFormat = .unspecified

    // MARK: - Kernel

    private static let kernel = MTIMultilayerCompositeKernel()

    // MARK: - Initialization

    public override init() {
        super.init()
    }

    // MARK: - MTIFilter Protocol
    
    private func newLayer(from layer: MTILayer,
                          position: CGPoint,
                          rotation: Float,
                          contentFlipOptions: MTILayer.FlipOptions? = nil) -> MTILayer {
        return MTILayer(refId: layer.refId,
                        content: layer.content,
                        contentRegion: layer.contentRegion,
                        contentFlipOptions: contentFlipOptions ?? layer.contentFlipOptions,
                        mask: layer.mask,
                        compositingMask: layer.compositingMask,
                        layoutUnit: layer.layoutUnit,
                        position: position,
                        size: layer.size,
                        rotation: rotation,
                        opacity: layer.opacity,
                        cornerRadius: layer.cornerRadius,
                        cornerCurve: layer.cornerCurve,
                        tintColor: layer.tintColor,
                        blendMode: layer.blendMode,
                        isHidden: layer.isHidden,
                        scissorRects: layer.scissorRects,
                        pattern: layer.pattern)
    }
    
    public var outputImage: MTIImage? {
        guard let inputBackgroundImage = inputBackgroundImage else {
            return nil
        }

        if layers.isEmpty {
            return inputBackgroundImage
        }

        let canvasSize = inputBackgroundImage.size
        var displaySize = canvasSize
        
        var processedLayers: [MTILayer] = []
        
        for layer in layers {
            guard let pattern = layer.pattern else {
                processedLayers.append(layer)
                continue
            }
            
            if pattern.cropRect != .null {
                displaySize = pattern.cropRect.size
            }
            
            let displayWidth = CGFloat(displaySize.width)
            let displayHeight = CGFloat(displaySize.height)
            let canvasWidth = CGFloat(canvasSize.width)
            let canvasHeight = CGFloat(canvasSize.height)
            
            // 1. Stable Grid Calculation
            // Using floor ensures the grid indices don't "flicker" at the edges
            let colOffset = Int(floor(layer.position.x / displayWidth))
            let rowOffset = Int(floor(layer.position.y / displayHeight))
            
            // Anchor is the position of the (0,0) tile relative to the canvas
            let anchorX = layer.position.x - CGFloat(colOffset) * displayWidth
            let anchorY = layer.position.y - CGFloat(rowOffset) * displayHeight
            
            // 2. Iterate through neighbors
            // Range -3...3 handles patterns with large offsets (like half-drop) safely
            let range = -3...3
            
            for xGrid in range {
                for yGrid in range {
                    let absoluteCol = colOffset + xGrid
                    let absoluteRow = rowOffset + yGrid
                    
                    var candidateX = anchorX + (CGFloat(xGrid) * displayWidth)
                    var candidateY = anchorY + (CGFloat(yGrid) * displayHeight)
                    
                    // 3. Apply Pattern Offsets (Half-Drop / Half-Brick)
                    switch pattern.type {
                    case .seamedHalfDrop, .seamedHalfDropFlip:
                        if abs(absoluteCol) % 2 == 1 {
                            candidateY += displayHeight / 2.0
                        }
                    case .seamedHalfBrick, .seamedHalfBrickFlip:
                        if abs(absoluteRow) % 2 == 1 {
                            candidateX += displayWidth / 2.0
                        }
                    default:
                        break
                    }

                    // 4. Get Transform Logic
                    let transform = pattern.transformHandler?(Int32(absoluteCol), Int32(absoluteRow), 0)
                    let flipX = transform?.flipX ?? false
                    let angle = transform?.angle.radianToPositiveRange() ?? 0
                    
                    // 5. Geometric Transformation of the Center Point
                    var finalX = candidateX
                    var finalY = candidateY
                    var effectiveHalfW = displayWidth / 2.0
                    var effectiveHalfH = displayHeight / 2.0
                    
                    // Normalize angle to check for 90/270 degree swaps
                    let isQuarterRotated = abs(angle.truncatingRemainder(dividingBy: .pi) - (.pi / 2.0)) < 0.01
                    
                    if isQuarterRotated {
                        // Swap dimensions for intersection check
                        effectiveHalfW = displayHeight / 2.0
                        effectiveHalfH = displayWidth / 2.0
                    }

                    // Apply coordinate transformations based on angle around the center of the CANVAS
                    let centerX = canvasWidth / 2.0
                    let centerY = canvasHeight / 2.0
                    
                    // Translate to canvas origin
                    var tempX = finalX - centerX
                    var tempY = finalY - centerY
                    
                    if abs(angle - (.pi * 0.5)) < 0.01 { // 90 degrees
                        let oldX = tempX
                        tempX = tempY
                        tempY = -oldX
                    } else if abs(angle - .pi) < 0.01 { // 180 degrees
                        tempX = -tempX
                        tempY = -tempY
                    } else if abs(angle - (.pi * 1.5)) < 0.01 { // 270 degrees
                        let oldX = tempX
                        tempX = -tempY
                        tempY = oldX
                    }
                    
                    // Translate back
                    finalX = tempX + centerX
                    finalY = tempY + centerY
                    
                    // Apply Flip transformation to position relative to canvas
                    if flipX {
                        finalX = canvasWidth - finalX
                    }

                    // 6. Intersection Check using EFFECTIVE dimensions against CANVAS bounds
                    let layerMinX = finalX - effectiveHalfW
                    let layerMaxX = finalX + effectiveHalfW
                    let layerMinY = finalY - effectiveHalfH
                    let layerMaxY = finalY + effectiveHalfH
                    
                    // Fix: Check against canvasWidth and canvasHeight instead of displayWidth/displayHeight
                    if layerMinX < canvasWidth && layerMaxX > 0 && layerMinY < canvasHeight && layerMaxY > 0 {
                        var contentFlipOptions = layer.contentFlipOptions
                        if flipX {
                            // Toggle horizontal flip
                            if contentFlipOptions.contains(.flipHorizontally) {
                                contentFlipOptions.remove(.flipHorizontally)
                            } else {
                                contentFlipOptions.insert(.flipHorizontally)
                            }
                        }
                        
                        let newInstance = newLayer(
                            from: layer,
                            position: CGPoint(x: finalX, y: finalY),
                            rotation: layer.rotation - Float(angle),
                            contentFlipOptions: contentFlipOptions
                        )
                        processedLayers.append(newInstance)
                    }
                }
            }
        }
        
        let hasPatternType = layers.contains(where: { $0.pattern != nil })
        
        return MTIMultilayerCompositingFilter.kernel.apply(
            toBackgroundImage: inputBackgroundImage,
            layers: processedLayers,
            rasterSampleCount: UInt(rasterSampleCount),
            scissorRects: hasPatternType ? [] : (scissorRects ?? []),
            outputAlphaType: outputAlphaType,
            outputTextureDimensions: MTITextureDimensions(cgSize: canvasSize),
            outputPixelFormat: outputPixelFormat
        )
    }

}

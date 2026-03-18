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

let pi_60 = CGFloat.pi / 3
let pi_120 = CGFloat.pi / 1.5

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
        let canvasWidth = CGFloat(canvasSize.width)
        let canvasHeight = CGFloat(canvasSize.height)
        
        var processedLayers: [MTILayer] = []
        
        for layer in layers {
            guard let pattern = layer.pattern else {
                processedLayers.append(layer)
                continue
            }
            
            let cropRect = pattern.cropRect != .null ? pattern.cropRect : CGRect(origin: .zero, size: canvasSize)
            
            let tileSize = cropRect.size
            let tileWidth = CGFloat(tileSize.width)
            let tileHeight = CGFloat(tileSize.height)
            let tileWidthHalf = CGFloat(tileSize.width) * 0.5
            let tileHeightHalf = CGFloat(tileSize.width) * 0.5
            let tileCenter = CGPoint(x: tileWidthHalf, y: tileHeightHalf)
            
            let adjustedLayerPosition = layer.position - cropRect.origin
            
            // 1. Stable Grid Calculation
            let gridIndex = pattern.gridIndexHandler(adjustedLayerPosition, tileSize)
            
            // Anchor is the position of the (0,0) tile relative to the canvas
            let anchorX = layer.position.x - CGFloat(gridIndex.col) * tileWidth
            let anchorY = layer.position.y - CGFloat(gridIndex.row) * tileHeight
            
            // 2. Dynamically calculate the required grid range to cover the whole canvas
            // By calculating min/max relative to the anchor, we ensure the canvas is always covered
            // even if the anchor drifts significantly due to non-standard row heights.
            let minXGrid = Int(floor(-anchorX / tileWidth)) - 2
            let maxXGrid = Int(ceil((canvasWidth - anchorX) / tileWidth)) + 2
            let minYGrid = Int(floor(-anchorY / tileHeight)) - 2
            let maxYGrid = Int(ceil((canvasHeight - anchorY) / tileHeight)) + 2
            
            // Determine how many sub-tiles exist per grid cell.
            let subTilesCount: Int
            switch pattern.type {
            case .seamedBowtie, .seamedButterfly, .seamlessCrossMirror:
                subTilesCount = 2
            case .seamedCurrent, .seamedFishScale, .seamedFallenLeaves, .seamlessPyramidMirror:
                subTilesCount = 2
            default:
                subTilesCount = 1
            }

            func getUnitPosition() -> CGPoint {
                switch pattern.type {
                case .seamlessPyramidMirror:
                    var x = Int(adjustedLayerPosition.x+tileWidthHalf)
                    var y = Int(adjustedLayerPosition.y+tileHeight)
                    
                    let widthUnits: Int = 3
                    let heightUnits: Int = 2
                    
                    if x.mod(x: Int(tileWidth)*widthUnits) > Int(tileWidth) * (widthUnits-1) {
                        x -= Int(tileWidth * (CGFloat(widthUnits) * 0.5))
                        y -= Int(tileHeight * (CGFloat(heightUnits) * 0.5))
                    }
                    
                    x = x.mod(x: Int(tileWidth)*widthUnits)
                    y = y.mod(x: Int(tileHeight)*heightUnits)
                    
                    return CGPoint(x: x, y: y)
                default:
                    // TODO for other types if needed
                    return adjustedLayerPosition
                }
            }
            let unitPosition = getUnitPosition()
            
            // Temporary array to hold generated layers and their grid distance
            var currentPatternLayers: [(layer: MTILayer, gridDistance: Int)] = []
            
            for xGrid in minXGrid...maxXGrid {
                for yGrid in minYGrid...maxYGrid {
                    let absoluteCol = gridIndex.col + xGrid
                    let absoluteRow = gridIndex.row + yGrid
                    
                    var candidateX = anchorX + (CGFloat(xGrid) * tileWidth)
                    var candidateY = anchorY + (CGFloat(yGrid) * tileHeight)
                    
                    // 3. Apply Pattern Offsets (Half-Drop / Half-Brick)
                    switch pattern.type {
                    case .seamedHalfDrop, .seamedHalfDropFlip:
                        if abs(absoluteCol) % 2 == 1 {
                            candidateY += tileHeight * 0.5
                        }
                    case .seamedHalfBrick, .seamedHalfBrickFlip:
                        if abs(absoluteRow) % 2 == 1 {
                            candidateX += tileWidth * 0.5
                        }

                    case .seamlessPyramidMirror:
                        if abs(absoluteRow) % 2 == 1 {
                            candidateX += tileWidth * 1.5
                        }
                    default:
                        break
                    }

                    // 4. Iterate over sub-tiles (0 and 1 for triangular, just 0 for others)
                    for subIndex in 0..<subTilesCount {
                        
                        // Pass the subIndex to the transform handler
                        let transform = pattern.transformHandler(absoluteCol, absoluteRow, subIndex)
                        let flipX = transform.flipX
                        var angle = transform.angle.radianToPositiveRange()
                        
                        var finalX = candidateX
                        var finalY = candidateY
                        
                        switch pattern.type {
                        case .seamlessPyramidMirror:
                            
//                            let centerX = canvasWidth / 2.0
//                            let centerY = canvasHeight / 2.0
//                            
//                            // Translate to canvas origin
//                            var tempX = finalX - centerX
//                            var tempY = finalY - centerY
//                            
//                            // Apply general rotation
//                            if angle > 0.001 {
//                                let cosA = CGFloat(cos(Double(angle)))
//                                let sinA = CGFloat(sin(Double(angle)))
//                                let oldX = tempX
//                                tempX = oldX * cosA - tempY * sinA
//                                tempY = oldX * sinA + tempY * cosA
//                            }
//                            
//                            // Translate back
//                            finalX = tempX + centerX
//                            finalY = tempY + centerY
//                            
//                            // Apply Flip transformation to position relative to canvas
                            
                            break
                            
                        default:
                            // 5. Geometric Transformation of the Center Point
                            
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
                        }
                        
                        switch pattern.type {
                        case .seamedBowtie, .seamlessCrossMirror:
                            let isEvenCol = absoluteCol % 2 == 0
                            let isEvenRow = absoluteRow % 2 == 0
                            
                            let shouldRotate = (subIndex == 0 && !isEvenCol && !isEvenRow) ||
                                               (subIndex != 0 && isEvenCol && isEvenRow)
                            
                            if shouldRotate {
                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(.pi, anchor: tileCenter)
                                finalX = pt.x
                                finalY = pt.y
                            }
                    
                        case .seamedCurrent, .seamedFishScale, .seamedFallenLeaves:
                            let isEvenRow = absoluteRow % 2 == 0
                            let shouldShiftX = (subIndex == 0 && !isEvenRow) || (subIndex != 0 && isEvenRow)
                            if shouldShiftX {
                                finalX += tileWidthHalf
                            }
                        case .seamlessPyramidMirror:
                            
                            angle = 0
                            
                            let unitIndex = (gridIndex.col - gridIndex.row).mod(x: 3)
                            if flipX {
                                finalX = canvasWidth - finalX
                            }
                            let center = CGPoint(x: tileWidth*0.5, y: (canvasHeight-tileHeight)*0.5)
                            
                            let A = CGPoint(x: tileWidthHalf, y: 0)
                            let B = A + CGPoint(x: tileWidth, y: 0)
                            let C = CGPoint(x: 0, y: tileHeight)
                            let D = C + CGPoint(x: tileWidth, y: 0)
                            let E = D + CGPoint(x: tileWidth, y: 0)
                            let F = CGPoint(x: tileWidthHalf, y: tileHeight*2)
                            let G = F + CGPoint(x: tileWidth, y: 0)
                            
                            let unit = CGRect(origin: .zero, size: CGSize(width: tileWidth*2, height: tileHeight*2))
                            
                            let ul = unitPosition.distance(to: CGPoint(x: unit.minX, y: unit.minY))
                            let bl = unitPosition.distance(to: CGPoint(x: unit.minX, y: unit.maxY))
                            let ur = unitPosition.distance(to: CGPoint(x: unit.maxX, y: unit.minY))
                            let br = unitPosition.distance(to: CGPoint(x: unit.maxX, y: unit.maxY))
                            
                            let ab = unitPosition.distance(to: (A+B)/2)
                            let ac = unitPosition.distance(to: (A+C)/2)
                            let ad = unitPosition.distance(to: (A+D)/2)
                            let bd = unitPosition.distance(to: (B+D)/2)
                            let be = unitPosition.distance(to: (B+E)/2)
                            let cd = unitPosition.distance(to: (C+D)/2)
                            let de = unitPosition.distance(to: (D+E)/2)
                            let cf = unitPosition.distance(to: (C+F)/2)
                            let df = unitPosition.distance(to: (D+F)/2)
                            let dg = unitPosition.distance(to: (D+G)/2)
                            let eg = unitPosition.distance(to: (E+G)/2)
                            let fg = unitPosition.distance(to: (F+G)/2)
                            
                            switch subIndex {
                            case 0:
                                switch gridIndex.sub {
                                case 0: // ok
                                    switch unitIndex {
                                    case 0:
                                        let pt = CGPoint(x: finalX, y: finalY).rotatedBy(0, anchor: center)
                                        finalX = pt.x
                                        finalY = pt.y
                                        angle = 0
                                    case 1:
                                        let pt = CGPoint(x: finalX, y: finalY).rotatedBy(-pi_120, anchor: center)
                                        finalX = pt.x
                                        finalY = pt.y
                                        angle = pi_120
                                    case 2:
                                        let pt = CGPoint(x: finalX, y: finalY).rotatedBy(pi_120, anchor: center)
                                        finalX = pt.x
                                        finalY = pt.y
                                        angle = -pi_120
                                    default:
                                        break
                                    }
                                case 1:
                                    switch unitIndex {
                                    case 0:
                                        if unitPosition.y <= tileHeight {
                                            let min = min(ac, ul)
                                            if min == ac { // ac ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(-pi_120, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = pi_120
                                            } else { // ul ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(pi_120, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = -pi_120
                                            }
                                        } else {
                                            let min = min(de, min(dg, eg))
                                            if min == de { // de
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(pi_120, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = -pi_120
                                            } else if min == dg { // dg
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(0, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = 0
                                            } else { // eg ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(-pi_120, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = pi_120
                                            }
                                        }
                                    case 1:
                                        if unitPosition.y <= tileHeight {
                                            let min = min(ab, min(ad, bd))
                                            if min == ab {
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(0, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = 0
                                            } else if min == ad { // ad ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(-pi_120, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = pi_120
                                            } else { // bd ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(pi_120, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = -pi_120
                                            }
                                        } else {
                                            continue
                                        }
                                    case 2:
                                        if unitPosition.y <= tileHeight {
                                            let min = min(be, ur)
                                            if min == be { // be ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(pi_120, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = -pi_120
                                            } else { // ur ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(-pi_120, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = pi_120
                                            }
                                        } else {
                                            let min = min(cd, min(cf, df))
                                            if min == cd { // cd ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(-pi_120, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = pi_120
                                            } else if min == cf { // cf ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(pi_120, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = -pi_120
                                            } else { // df ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(0, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = 0
                                            }
                                        }
                                    default:
                                        break
                                    }
                                default:
                                    break
                                }
                                
                            case 1:
                                switch gridIndex.sub {
                                case 0:
                                    switch unitIndex {
                                    case 0:
                                        if unitPosition.y <= tileHeight {
                                            continue
                                        } else {
                                            let min = min(df, min(dg, fg))
                                            if min == fg { // fg ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(.pi, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = -.pi
                                            } else if min == df { // df ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(pi_60, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = -pi_60
                                            } else { // dg ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(-pi_60, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = pi_60
                                            }
                                        }
                                    case 1:
                                        if unitPosition.y <= tileHeight {
                                            let min = min(cd, min(ac, ad))
                                            if min == cd { // cd ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(pi_60, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = -pi_60
                                            } else if min == ac { // ac ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(-pi_60, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = pi_60
                                            } else { // ad ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(-.pi, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = .pi
                                            }
                                            
                                        } else {
                                            let min = min(eg, br)
                                            if min == eg { // eg ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(-pi_60, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = pi_60
                                            } else { // br ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(pi_60, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = -pi_60
                                            }
                                        }
                                    case 2:
                                        if unitPosition.y <= tileHeight {
                                            let min = min(bd, min(be, de))
                                            if min == de { // de ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(-pi_60, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = pi_60
                                            } else if min == bd { // bd ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(-.pi, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = .pi
                                            } else { // be ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(pi_60, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = -pi_60
                                            }
                                        } else {
                                            let min = min(cf, bl)
                                            if min == cf { // cf ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(pi_60, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = -pi_60
                                            } else { // bl ok
                                                let pt = CGPoint(x: finalX, y: finalY).rotatedBy(-pi_60, anchor: center)
                                                finalX = pt.x
                                                finalY = pt.y
                                                angle = pi_60
                                            }
                                        }
                                    default:
                                        break
                                    }
                                case 1: // ok
                                    switch unitIndex {
                                    case 0:
                                        let pt = CGPoint(x: finalX, y: finalY).rotatedBy(-pi_60, anchor: center)
                                        finalX = pt.x
                                        finalY = pt.y
                                        angle = pi_60
                                    case 1:
                                        let pt = CGPoint(x: finalX, y: finalY).rotatedBy(-.pi, anchor: center)
                                        finalX = pt.x
                                        finalY = pt.y
                                        angle = .pi
                                    case 2:
                                        let pt = CGPoint(x: finalX, y: finalY).rotatedBy(pi_60, anchor: center)
                                        finalX = pt.x
                                        finalY = pt.y
                                        angle = -pi_60
                                    default:
                                        break
                                    }
                                default:
                                    break
                                }
                                break
                            default:
                                break
                            }

                        default:
                            break
                        }
                         
                        
                        // 6. Intersection Check using ACTUAL layer size (Safe Radius for rotation)
                        let safeRadius = hypot(layer.size.width, layer.size.height) / 2.0
                        
                        let layerMinX = finalX - safeRadius
                        let layerMaxX = finalX + safeRadius
                        let layerMinY = finalY - safeRadius
                        let layerMaxY = finalY + safeRadius
                        
                        if layerMinX < canvasWidth && layerMaxX > 0 && layerMinY < canvasHeight && layerMaxY > 0 {
                            var contentFlipOptions = layer.contentFlipOptions
                            if flipX {
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
                            
                            // Calculate distance based on the logical grid offset.
                            let gridDistance = Int(layer.position.distance(to: newInstance.position))
                            
                            currentPatternLayers.append((layer: newInstance, gridDistance: gridDistance))
                        }
                    }
                }
            }
            
            // Sort layers so that the ones furthest away in the grid are drawn first (bottom),
            // and the one at (0,0) is drawn last (top).
            currentPatternLayers.sort { $0.gridDistance > $1.gridDistance }
            
            // Append the sorted layers to the final processing array
            processedLayers.append(contentsOf: currentPatternLayers.map { $0.layer })
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

//
//  ForwardWarp.swift
//  Atelier
//
//  Created by Lung on 25/7/2022.
//  Copyright © 2022 command b. All rights reserved.
//

import Foundation

struct ForwardWarpParameters {
    var imageSize: SIMD2<Float> = .zero
    var center: SIMD2<Float> = .zero
    var radius: Float = 0
    var direction: Float = 0
    var strength: Float = 0
    var density: Float = 0
}

class MTIForwardWarpFilter: MTIUnaryFilter {
    
    var parameters: ForwardWarpParameters = ForwardWarpParameters()
    
    var outputPixelFormat: MTLPixelFormat = .unspecified
    
//    var myCustomKernal: MTIRenderPipelineKernel = MTIRenderPipelineKernel(
//        vertexFunctionDescriptor: MTIFunctionDescriptor(name: "forwardWarp", libraryURL: MTIDefaultLibraryURLForBundle(Bundle.main)),
//        fragmentFunctionDescriptor: MTIFunctionDescriptor(name: MTIFilterPassthroughFragmentFunctionName)
//    )
    var myCustomKernel: MTIRenderPipelineKernel = MTIRenderPipelineKernel(
        vertexFunctionDescriptor: MTIFunctionDescriptor(name: "forwardWarp", libraryURL: MTIDefaultLibraryURLForBundle(Bundle.main)),
        fragmentFunctionDescriptor: MTIFunctionDescriptor(name: MTIFilterPassthroughFragmentFunctionName),
        vertexDescriptor: nil,
        colorAttachmentCount: 1,
        alphaTypeHandlingRule: .passthrough)
    
    var inputImage: MTIImage?
    
    var mesh: GridMesh?
    
    var outputImage: MTIImage? {
        guard let inputImage = inputImage else { return nil }
//        print(parameters.radius, parameters.imageSize.x, parameters.imageSize.y, parameters.center.x, parameters.center.y)
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
//        ).first
        
        if mesh == nil {
            mesh = GridMesh(width: Int(inputImage.dimensions.width), height: Int(inputImage.dimensions.height), cellSize: 4) { position in
//            let distanceToCenter = distance(parameters.center, position)
//            // Find the target position for the warp.
////            print(distanceToCenter)
//            if (distanceToCenter < parameters.radius) {
//                //direction and strength
//                var targetOffset = SIMD2<Float>(cos(parameters.direction), sin(parameters.direction)) * parameters.strength
//                //density
//                let distanceFactor = distanceToCenter/parameters.radius
//                targetOffset = targetOffset * (1 - parameters.density * distanceFactor)
//                return (position + targetOffset)
//            } else {
                return position
//            }
            }
        }
//        let renderCommand = MTIRenderCommand(kernel: .passthrough, geometry: mesh.geometry, images: [inputImage], parameters: [:])
        let renderCommand = MTIRenderCommand(kernel: myCustomKernel, geometry: mesh!.geometry, images: [inputImage], parameters: [
            "size": parameters.imageSize,
            "center": parameters.center,
            "radius": parameters.radius,
            "direction": parameters.direction,
            "strength": parameters.strength,
            "density": parameters.density
        ])
        return MTIRenderCommand.images(byPerforming: [renderCommand], outputDescriptors: [
//            MTIRenderPassOutputDescriptor(dimensions: inputImage.dimensions, pixelFormat: outputPixelFormat)
            MTIRenderPassOutputDescriptor(dimensions: inputImage.dimensions, pixelFormat: outputPixelFormat, loadAction: .clear)
        ]).first
        
    }

    
}

struct GridMesh {
    let geometry: MTIGeometry
    init(width: Int, height: Int, cellSize: Int, positionModifier: (SIMD2<Float>) -> SIMD2<Float>) {
        let size = SIMD2<Float>(Float(width), Float(height))
        let hMeshCount = (width + cellSize - 1) / cellSize
        let vMeshCount = (height + cellSize - 1) / cellSize
        // Create vertices
        var vertices = [MTIVertex]()
        for r in 0...vMeshCount {
            for c in 0...hMeshCount {
                let currentPosition = SIMD2<Float>(Float(c * cellSize), Float(r * cellSize))
                let targetPosition: SIMD2<Float> = positionModifier(currentPosition)/size
                vertices.append(MTIVertex(position: SIMD4<Float>(x: (targetPosition.x - 0.5) * 2, y: ((1 - targetPosition.y) - 0.5) * 2, z: 0, w: 1),
                                          textureCoordinate: currentPosition/size))
            }
        }
        // Create indices
        var indices: [UInt32] = []
        for r in 1...vMeshCount {
            for c in 1...hMeshCount {
                let i = r * (hMeshCount + 1) + c
                let t = (r - 1) * (hMeshCount + 1) + c
                let tl = (r - 1) * (hMeshCount + 1) + c - 1
                let l = i - 1
                let t1: [UInt32] = [UInt32(i), UInt32(t), UInt32(tl)]
                let t2: [UInt32] = [UInt32(i), UInt32(l), UInt32(tl)]
                indices.append(contentsOf: t1)
                indices.append(contentsOf: t2)
            }
        }
        geometry = MTIVertices(vertexBuffer: MTIDataBuffer(mtiVertices: vertices)!,
                               vertexCount: UInt(vertices.count),
                               indexBuffer: MTIDataBuffer(uint32Indexes: indices)!,
                               indexCount: UInt(indices.count),
                               primitiveType: .triangle)
    }
}

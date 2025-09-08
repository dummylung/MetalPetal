//
//  MTIMultilayerBrushCompositingFilter.swift
//  MetalPetal
//
//  Created by Yu Ao on 2019/12/4.
//

import Foundation
import CoreGraphics
import Metal

#if SWIFT_PACKAGE
import MetalPetalObjectiveC.Core
#endif

public class MultilayerBrushCompositingFilter: MTIFilter {
    
    public struct Layer: Hashable, Equatable {
        
        public var content: MTIImage
        
        public var contentRegion: CGRect
        
        public var mask: MTIMask? = nil
        
        public var compositingMask: MTIMask? = nil
        
        public var materialMask: MTIMaterialMask? = nil
        
        public var clippingMask1: MTIMask? = nil
        
        public var clippingMask2: MTIMask? = nil
        
        public var layoutUnit: MTIBrushLayer.LayoutUnit
        
        public var position: CGPoint
        
        public var startPosition: CGPoint
        
        public var lastPosition: CGPoint
        
        public var size: CGSize
        
        public var startSize: CGSize
        
        public var rotation: Float = 0
        
        public var opacity: Float = 1
        
        public var cornerRadius: MTICornerRadius = MTICornerRadius(0)
        
        public var cornerCurve: MTICornerCurve = .circular
        
        public var tintColor: MTIColor = .clear
        
        public var blendMode: MTIBlendMode = .normal
        
        public var renderingMode: MTIBrushLayer.RenderingMode = .lightGlaze
        
        public var renderingBlendMode: MTIBlendMode = .normal
        
        public var fillMode: MTIBrushLayer.FillMode = .normal
        
        public var shape: MTIShape
        
        public var isAlphaLocked: Bool = false
        
        public init(content: MTIImage) {
            self.content = content
            self.contentRegion = content.extent
            self.layoutUnit = .pixel
            self.size = content.size
            self.startSize = size
            self.position = CGPoint(x: content.size.width/2, y: content.size.height/2)
            self.startPosition = CGPoint(x: content.size.width/2, y: content.size.height/2)
            self.lastPosition = CGPoint(x: content.size.width/2, y: content.size.height/2)
            self.shape = MTIShape()
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(content)
            hasher.combine(contentRegion.origin.x)
            hasher.combine(contentRegion.origin.y)
            hasher.combine(contentRegion.size.width)
            hasher.combine(contentRegion.size.height)
            hasher.combine(mask)
            hasher.combine(compositingMask)
            hasher.combine(materialMask)
            hasher.combine(clippingMask1)
            hasher.combine(clippingMask2)
            hasher.combine(layoutUnit)
            hasher.combine(position.x)
            hasher.combine(position.y)
            hasher.combine(startPosition.x)
            hasher.combine(startPosition.y)
            hasher.combine(lastPosition.x)
            hasher.combine(lastPosition.y)
            hasher.combine(size.width)
            hasher.combine(size.height)
            hasher.combine(startSize.width)
            hasher.combine(startSize.height)
            hasher.combine(rotation)
            hasher.combine(opacity)
            hasher.combine(cornerRadius)
            hasher.combine(cornerCurve)
            hasher.combine(tintColor)
            hasher.combine(blendMode)
            hasher.combine(renderingBlendMode)
            hasher.combine(fillMode)
            hasher.combine(shape)
            hasher.combine(isAlphaLocked)
        }
        
        private func mutating(_ block: (inout Layer) -> Void) -> Layer {
            var layer = self
            block(&layer)
            return layer
        }
        
        public static func content(_ image: MTIImage) -> Layer {
            Layer(content: image)
        }
        
        public static func content(_ image: MTIImage, modifier: (inout Layer) -> Void) -> Layer {
            Layer(content: image).mutating(modifier)
        }
        
        public func opacity(_ value: Float) -> Layer {
            self.mutating({ $0.opacity = value })
        }
        
        public func contentRegion(_ contentRegion: CGRect) -> Layer {
            self.mutating({ $0.contentRegion = contentRegion })
        }
        
        public func mask(_ mask: MTIMask?) -> Layer {
            self.mutating({ $0.mask = mask })
        }
        
        public func compositingMask(_ mask: MTIMask?) -> Layer {
            self.mutating({ $0.compositingMask = mask })
        }
        
        public func materialMask(_ mask: MTIMaterialMask?) -> Layer {
            self.mutating({ $0.materialMask = mask })
        }
        
        public func clippingMask1(_ mask: MTIMask?) -> Layer {
            self.mutating({ $0.clippingMask1 = mask })
        }
        
        public func clippingMask2(_ mask: MTIMask?) -> Layer {
            self.mutating({ $0.clippingMask2 = mask })
        }
        
        public func frame(_ rect: CGRect, layoutUnit: MTIBrushLayer.LayoutUnit) -> Layer {
            self.mutating({
                $0.size = rect.size
                $0.position = CGPoint(x: rect.midX, y: rect.midY)
                $0.layoutUnit = layoutUnit
            })
        }
        
        public func frame(center: CGPoint, size: CGSize, layoutUnit: MTIBrushLayer.LayoutUnit) -> Layer {
            self.mutating({
                $0.size = size
                $0.position = center
                $0.layoutUnit = layoutUnit
            })
        }
        
        public func rotation(_ rotation: Float) -> Layer {
            self.mutating({ $0.rotation = rotation })
        }
        
        public func tintColor(_ color: MTIColor?) -> Layer {
            self.mutating({ $0.tintColor = color ?? .clear })
        }
        
        public func blendMode(_ blendMode: MTIBlendMode) -> Layer {
            self.mutating({ $0.blendMode = blendMode })
        }
        
        public func isAlphaLocked(_ isAlphaLocked: Bool) -> Layer {
            self.mutating({ $0.isAlphaLocked = isAlphaLocked })
        }
        
        public func renderingBlendMode(_ renderingBlendMode: MTIBlendMode) -> Layer {
            self.mutating({ $0.renderingBlendMode = renderingBlendMode })
        }
        
        public func corner(radius: MTICornerRadius, curve: MTICornerCurve) -> Layer {
            self.mutating({
                $0.cornerRadius = radius
                $0.cornerCurve = curve
            })
        }
        
        public func cornerRadius(_ radius: MTICornerRadius) -> Layer {
            self.mutating({ $0.cornerRadius = radius })
        }
        
        public func cornerRadius(_ radius: Float) -> Layer {
            self.mutating({ $0.cornerRadius = MTICornerRadius(radius) })
        }
        
        public func cornerCurve(_ curve: MTICornerCurve) -> Layer {
            self.mutating({ $0.cornerCurve = curve })
        }
        
        public func fillMode(_ fillMode: MTIBrushLayer.FillMode) -> Layer {
            self.mutating({ $0.fillMode = fillMode })
        }
    }
    
    public var outputPixelFormat: MTLPixelFormat {
        get { internalFilter.outputPixelFormat }
        set { internalFilter.outputPixelFormat = newValue }
    }
    
    public var outputImage: MTIImage? {
        return internalFilter.outputImage
    }
    
    public var inputBackgroundImage: MTIImage? {
        get { internalFilter.inputBackgroundImage }
        set { internalFilter.inputBackgroundImage = newValue }
    }
    
    public var inputBackgroundImageBeforeCurrentSession: MTIImage? {
        get { internalFilter.inputBackgroundImageBeforeCurrentSession }
        set { internalFilter.inputBackgroundImageBeforeCurrentSession = newValue }
    }
    
    public var outputAlphaType: MTIAlphaType {
        get { internalFilter.outputAlphaType }
        set { internalFilter.outputAlphaType = newValue }
    }
    
    private var _layers: [Layer] = []
    
    public var layers: [Layer] {
        set {
            _layers = newValue
            internalFilter.layers = newValue.map({ $0.bridgeToObjectiveC() })
        }
        get {
            return _layers
        }
    }
    
    public var rasterSampleCount: Int {
        set { internalFilter.rasterSampleCount = UInt(newValue) }
        get { Int(internalFilter.rasterSampleCount) }
    }
    
    private var internalFilter = MTIMultilayerBrushCompositingFilter()
    
    public init() {
        
    }
}

extension MultilayerBrushCompositingFilter {
    @available(*, deprecated, message: "Use MultilayerBrushCompositingFilter.Layer(content:).frame(...).opacity(...)... instead.")
    public static func makeLayer(content: MTIImage, configurator: (_ layer: inout Layer) -> Void) -> Layer {
        var layer = Layer(content: content)
        configurator(&layer)
        return layer
    }
}

extension MultilayerBrushCompositingFilter.Layer {
    fileprivate func bridgeToObjectiveC() -> MTIBrushLayer {
        return MTIBrushLayer(content: self.content, contentRegion: self.contentRegion, mask: self.mask, compositingMask: self.compositingMask, materialMask: self.materialMask, clippingMask1: self.clippingMask1, clippingMask2: self.clippingMask2, layoutUnit: self.layoutUnit, position: self.position, startPosition: self.startPosition, lastPosition: self.lastPosition, size: self.size, start: self.startSize, rotation: self.rotation, opacity: self.opacity, cornerRadius: self.cornerRadius, cornerCurve: self.cornerCurve, tintColor: self.tintColor, blendMode: self.blendMode, renderingMode: self.renderingMode, renderingBlendMode: self.renderingBlendMode, fillMode: self.fillMode, shape: self.shape, isAlphaLocked: self.isAlphaLocked)
    }
}

extension MultilayerBrushCompositingFilter.Layer: CustomDebugStringConvertible, CustomStringConvertible {
    public var debugDescription: String {
        let mirror = Mirror(reflecting: self)
        let members: String = mirror.children.reduce("", { r, c in "\(r)\(c.label ?? "(null)") = \(c.value); " })
        return "<MultilayerBrushCompositingFilter.Layer> { \(members)}"
    }
    
    public var description: String {
        return self.debugDescription
    }
}

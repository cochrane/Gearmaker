//
//  Gear+Export2D.swift
//  Gearmaker
//
//  Created by Torsten Kammer on 13.11.22.
//  Copyright © 2022 Torsten Kammer. All rights reserved.
//

import Foundation
import CoreGraphics

extension Gear {
    
    @objc func writePDF(to url: URL) throws {
        let diameter = kopfkreisdurchmesser * 1.05
        var rect = CGRect(origin: CGPoint(), size: CGSize(width: diameter, height: diameter))
        
        guard let context = CGContext(url as CFURL, mediaBox: &rect, nil) else {
            throw NSError(domain: "Gearmaker", code: 0, userInfo: [ NSLocalizedDescriptionKey: "The PDF file could not be created." ])
        }
        
        context.beginPDFPage(nil)
        draw(in: context, size: rect.size)
        context.endPDFPage()
    }
    
    @objc func draw(in context: CGContext, size: CGSize) {
        let outlinePoints = outlinePoints(interval: pointInterval)
        
        // Prepare translation
        context.translateBy(x: size.width * 0.5, y: size.height * 0.5)
        
        // Scale
        let diameter = kopfkreisdurchmesser * 1.05
        context.scaleBy(x: size.width / diameter, y: size.height / diameter)
        
        // Draw gear
        context.beginPath()
        context.move(to: CGPoint(point: outlinePoints.first!))
        for point in outlinePoints {
            context.addLine(to: CGPoint(point: point))
        }
        context.closePath()
        
        context.setFillColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        context.setLineWidth(1.0)
        context.drawPath(using: .stroke)
    }
    
    @objc func writeSVG(to url: URL) throws {
        let diameter = kopfkreisdurchmesser
        let offset = diameter*0.5
        
        let svg = XMLElement(name: "svg", uri: "http://www.w3.org/2000/svg")
        svg.setAttributesWith([ "version": "1.1",
                                "width": "\(diameter)",
                                "height": "\(diameter)"])
        var pathText = ""
        let outline = outlinePoints(interval: pointInterval)
        
        let start = outline.first!
        pathText.append("M \(start.x + offset),\(start.y + offset) L")
        for point in outline {
            pathText.append(" \(point.x + offset),\(point.y + offset)")
        }
        pathText.append(" Z")
        
        let pathElement = XMLElement(name: "path", uri: "http://www.w3.org/2000/svg")
        pathElement.setAttributesWith([ "d": pathText, "fill": "#000000"])
        
        let mmPerInch = 25.4
        let dotsPerInch = 96.0
        let dotsPerMm = dotsPerInch / mmPerInch
        let gElement = XMLElement(name: "g", uri: "http://www.w3.org/2000/svg")
        gElement.setAttributesWith(["transform": "scale(\(dotsPerMm)]"])
        gElement.addChild(pathElement)
        
        svg.addNamespace(XMLNode.namespace(withName: "", stringValue: "http://www.w3.org/2000/svg") as! XMLNode)
        svg.addChild(gElement)
        
        let document = XMLDocument(rootElement: svg)
        document.characterEncoding = "utf-8"
        try document.xmlData.write(to: url, options: .atomic)
    }
}

extension CGPoint {
    init(point: SIMD2<Double>) {
        self.init(x: point.x, y: point.y)
    }
}

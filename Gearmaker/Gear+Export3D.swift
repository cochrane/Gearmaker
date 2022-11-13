//
//  Gear+Export3D.swift
//  Gearmaker
//
//  Created by Torsten Kammer on 13.11.22.
//  Copyright © 2022 Torsten Kammer. All rights reserved.
//

import Foundation

extension Gear {
    @objc func writeOBJ(to url: URL, triangulate: Bool) throws {
        var string = "# Created with Gearmaker"
        
        var modelData = self.modelData
        if triangulate {
            modelData = modelData.triangulated
        }
        
        let numberFormat = NumberFormatter()
        numberFormat.minimumFractionDigits = 6
        numberFormat.decimalSeparator = "."
        numberFormat.groupingSeparator = ""
        for point in modelData.points {
            string.append("v \(numberFormat.string(from: point.x as NSNumber)!) \(numberFormat.string(from: point.y as NSNumber)!) \(numberFormat.string(from: point.z as NSNumber)!)\n")
        }
        
        for polygon in modelData.polygons {
            string.append("f ")
            for index in polygon {
                string.append(" \(index + 1)")
            }
            string.append("\n")
        }
        
        try string.write(to: url, atomically: true, encoding: .ascii)
    }
    
    @objc func writeCollada(to url: URL, triangulate: Bool) throws {
        let root = XMLElement(name: "COLLADA")
        root.addNamespace(XMLNode.namespace(withName: "", stringValue: "http://www.collada.org/2005/11/COLLADASchema") as! XMLNode)
        root.setAttributesWith(["version": "1.4.1"])
        
        let asset = XMLElement(name: "asset")
        root.addChild(asset)
        
        let dateFormatter = ISO8601DateFormatter()
        let timeString = dateFormatter.string(from: Date())
        
        asset.addChild(XMLElement(name: "created", stringValue: timeString))
        asset.addChild(XMLElement(name: "modified", stringValue: timeString))
        
        let libraryGeometries = XMLElement(name: "library_geometries")
        root.addChild(libraryGeometries)
        
        let geometry = XMLElement(name: "geometry")
        libraryGeometries.addChild(geometry)
        geometry.setAttributesWith(["id": "gear"])
        
        let mesh = XMLElement(name: "mesh")
        geometry.addChild(mesh)
        
        let source = XMLElement(name: "mesh")
        mesh.addChild(source)
        source.setAttributesWith(["id": "s1"])
        
        let modelData = self.modelData
        
        // Vertices
        let numberFormat = NumberFormatter()
        numberFormat.minimumFractionDigits = 6
        numberFormat.decimalSeparator = "."
        numberFormat.groupingSeparator = ""
        var positionValues = ""
        for point in modelData.points {
            positionValues.append("\(numberFormat.string(from: point.x as NSNumber)!) \(numberFormat.string(from: point.y as NSNumber)!) \(numberFormat.string(from: point.z as NSNumber)!) ")
        }
        let floatArray = XMLElement(name: "float_array", stringValue: positionValues)
        source.addChild(floatArray)
        floatArray.setAttributesWith(["id": "f1", "count": "\(modelData.points.count * 3)"])
        
        let techniqueCommon = XMLElement(name:"technique_common")
        source.addChild(techniqueCommon)
        let accessor = XMLElement(name: "accessor")
        techniqueCommon.addChild(accessor)
        accessor.setAttributesWith(["count": "\(modelData.points.count)", "stride": "3", "source": "#f1"])
        for coord in ["X", "Y", "Z"] {
            let param = XMLElement(name: "param")
            accessor.addChild(param)
            param.setAttributesWith(["name": coord, "type": "float"])
        }
        
        let verticesElement = XMLElement(name: "vertices")
        verticesElement.setAttributesWith(["id": "v1"])
        mesh.addChild(verticesElement)
        let inputElement = XMLElement(name: "input")
        verticesElement.addChild(inputElement)
        inputElement.setAttributesWith(["semantic": "POSITION", "source": "#s1"])
        
        // Elements
        if triangulate {
            let triangulatedData = modelData.triangulated
            
            let triangles = XMLElement(name: "triangles")
            mesh.addChild(triangles)
            triangles.setAttributesWith(["count": "\(triangulatedData.polygons.count)"])
            
            let input = XMLElement(name: "input")
            triangles.addChild(input)
            input.setAttributesWith(["offset": "0", "semantic": "VERTEX", "source": "#v1"])
            
            let indices = triangulatedData.polygons.lazy.flatMap({ polygon in
                polygon.map { "\($0)" }
            }).joined(separator: " ")
            triangles.addChild(XMLElement(name: "p", stringValue: indices))
        } else {
            let polylist = XMLElement(name: "polylist")
            mesh.addChild(polylist)
            polylist.setAttributesWith(["count": "\(modelData.polygons.count)"])
            
            let input = XMLElement(name: "input")
            polylist.addChild(input)
            input.setAttributesWith(["offset": "0", "semantic": "VERTEX", "source": "#v1"])
            
            let countsString = modelData.polygons.lazy.map({ "\($0.count)" }).joined(separator: " ")
            let vcounts = XMLElement(name: "vcount", stringValue: countsString)
            polylist.addChild(vcounts)
            
            let indices = modelData.polygons.lazy.flatMap({ polygon in
                polygon.map { "\($0)" }
            }).joined(separator: " ")
            polylist.addChild(XMLElement(name: "p", stringValue: indices))
        }
        
        // Define a visual scene using the gear
        let libraryVisualScenes = XMLElement(name: "library_visual_scenes")
        root.addChild(libraryVisualScenes)
        let visualScene = XMLElement(name: "visual_scene")
        libraryVisualScenes.addChild(visualScene)
        visualScene.setAttributesWith(["id": "gearscene"])
        let node = XMLElement(name: "node")
        visualScene.addChild(node)
        let instanceGeometry = XMLElement(name: "instance_geometry")
        visualScene.addChild(instanceGeometry)
        instanceGeometry.setAttributesWith(["url": "#gear"])
        
        let scene = XMLElement(name: "scene")
        root.addChild(scene)
        let instanceVisualScene = XMLElement(name: "instance_visual_scene")
        scene.addChild(instanceVisualScene)
        instanceVisualScene.setAttributesWith(["url": "#gearscene"])
        
        // Finish
        let document = XMLDocument(rootElement: root)
        document.characterEncoding = "UTF-8"
        document.isStandalone = true
        
        try document.xmlData.write(to: url)
    }
}

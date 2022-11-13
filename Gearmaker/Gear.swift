//
//  Gear.swift
//  Gearmaker
//
//  Created by Torsten Kammer on 12.11.22.
//  Copyright © 2022 Torsten Kammer. All rights reserved.
//

import Foundation
import simd

@objc class Gear: NSObject, Codable {
    enum CodingKeys: String, CodingKey {
        case module = "modul"
        case teeth = "zaehne"
        case eingriffwinkel
        case kopfspielfaktor
        case pointInterval
        case thickness = "dicke"
    }
    
    @objc static func load(fromData data: Data) throws -> Gear {
        let decoder = PropertyListDecoder()
        return try decoder.decode(Gear.self, from: data)
    }
    
    @objc static func load(fromUrl url: URL) throws -> Gear {
        let data = try Data(contentsOf: url)
        return try load(fromData: data)
    }
    
    // Basic data
    
    @objc var module: Double = 0.0
    @objc var teeth: Int = 0
    @objc var kopfspielfaktor: Double = 0.0
    @objc var eingriffwinkel: Double = 0.0
    
    // Data for graphics
    @objc var pointInterval: Double = 0
    
    // Data for 3D
    @objc var thickness: Double = 0
    
    @objc var kopfhoehe: Double {
        return self.module
    }
    @objc var kopfspiel: Double {
        return module * kopfspielfaktor
    }
    @objc var fusshoehe: Double {
        return module + kopfspiel
    }
    @objc var teilkreisdurchmesser: Double {
        return Double(teeth) * module
    }
    @objc var fusskreisdurchmesser: Double {
        return teilkreisdurchmesser - 2 * fusshoehe
    }
    @objc var kopfkreisdurchmesser: Double {
        return teilkreisdurchmesser + 2 * kopfhoehe
    }
    @objc var grundkreisdurchmesser: Double {
        return teilkreisdurchmesser * cos(eingriffwinkel)
    }
    
    func toothFlankPoints(interval: Double) -> [SIMD2<Double>] {
        let gebogeneHoehe = (kopfkreisdurchmesser - grundkreisdurchmesser) * 0.5
        
        let pointsInInterval = Int(ceil(gebogeneHoehe / interval)) + 1 // +1 to get everything in the interval
        let actualInterval = gebogeneHoehe / ceil(gebogeneHoehe / interval)
        
        // First point at Fusskreis (outside the actual curve)
        var points: [SIMD2<Double>] = []
        points.reserveCapacity(pointsInInterval + 1)
        points.append(SIMD2(x: fusskreisdurchmesser * 0.5, y: 0))
        
        let curve = Involute(baseCircleRadius: grundkreisdurchmesser * 0.5)
        
        for i in 0 ..< pointsInInterval {
            let radius = grundkreisdurchmesser * 0.5 + Double(i)*actualInterval
            let angle = curve.angleForIntersectionWithCircle(radius: radius)
            points.append(curve.point(at: angle))
        }
        return points
    }
    
    private static func rotationMatrix(angle: Double) -> simd_double2x2 {
        return simd_double2x2(rows: [
            SIMD2<Double>(x: cos(angle), y: -sin(angle)),
            SIMD2<Double>(x: sin(angle), y: cos(angle)) ])
    }
    
    func outlinePoints(interval: Double) -> [SIMD2<Double>] {
        let toothFlank = toothFlankPoints(interval: interval)
        let reverseToothFlank = toothFlank.lazy.reversed().map {
            SIMD2<Double>(x: $0.x, y: -$0.y)
        }
        
        // Find out how much angle has to be added to the reverse side
        let curve = Involute(baseCircleRadius: grundkreisdurchmesser * 0.5)
        let angleToTeilkreis = curve.angleForIntersectionWithCircle(radius: teilkreisdurchmesser * 0.5)
        let intersectionPoint = curve.point(at: angleToTeilkreis)
        let additionalAngle = atan2(intersectionPoint.y, intersectionPoint.x)
        
        var points: [SIMD2<Double>] = []
        points.reserveCapacity(toothFlank.count * 2 * teeth)
        
        for tooth in 0 ..< teeth {
            
            let rotate = Gear.rotationMatrix(angle: (Double(tooth) / Double(teeth)) * 2 * Double.pi)
            for point in toothFlank {
                points.append(rotate * point)
            }
            
            let rotateReverseFlank = Gear.rotationMatrix(angle: ((Double(tooth) + 0.5) / Double(teeth)) * 2 * Double.pi + 2*additionalAngle)
            for point in reverseToothFlank {
                points.append(rotateReverseFlank * point)
            }
        }
        return points
    }
    
    struct ModelData {
        let points: [SIMD3<Double>]
        let polygons: [[Int]]
        
        var triangulated: ModelData {
            var newPolygons: [[Int]] = []
            for polygon in polygons {
                for i in 2..<polygon.count {
                    newPolygons.append( [ polygon[0], polygon[i-1], polygon[i-2] ])
                }
            }
            
            return ModelData(points: points, polygons: newPolygons)
        }
    }
    
    var modelData: ModelData {
        let outline = outlinePoints(interval: pointInterval)
        
        let halfWidth = thickness * 0.5
        var vertices: [SIMD3<Double>] = []
        vertices.reserveCapacity(outline.count*2 + 2)
        
        // Add vertices
        for point in outline.reversed() {
            vertices.append(SIMD3<Double>(x: point.x, y: halfWidth, z: point.y))
            vertices.append(SIMD3<Double>(x: point.x, y: -halfWidth, z: point.y))
        }
        // Add center vertices
        let centralTop = vertices.count
        vertices.append(SIMD3<Double>(x: 0, y: halfWidth, z: 0))
        let centralBottom = vertices.count
        vertices.append(SIMD3<Double>(x: 0, y: -halfWidth, z: 0))
        
        var polygons: [[Int]] = []
        
        // Add wall faces
        for i in 0..<outline.count {
            polygons.append([
                i*2,
                (i*2 + 1) % (outline.count*2),
                ((i+outline.count)*2 + 1) % (outline.count*2),
                (i+outline.count)*2,
            ])
        }
        
        // Add tooth faces
        let pointsPerTooth = outline.count / teeth
        for i in 0..<teeth {
            // Above
            polygons.append( (0 ..< pointsPerTooth).map {
                (i * pointsPerTooth + $0) * 2
            })
            // Below - reverse order
            polygons.append( stride(from: pointsPerTooth - 1, through: 0, by: -1).map {
                (i * pointsPerTooth + $0) * 2 + 1
            })
            
            // Central face above - tooth
            polygons.append([ i*pointsPerTooth*2, ((i+1) * pointsPerTooth - 1)*2, centralTop])
            // - gap to next tooth
            polygons.append([ ((i+1) * pointsPerTooth - 1)*2, ((i+1) * pointsPerTooth)*2, centralTop])
            
            // Central face below - tooth
            polygons.append([ ((i+1) * pointsPerTooth - 1)*2 + 1, i*pointsPerTooth*2 + 1,  centralTop])
            // - gap to next tooth
            polygons.append([ ((i+1) * pointsPerTooth)*2 + 1, ((i+1) * pointsPerTooth - 1)*2 + 1, centralTop])
        }
        
        return ModelData(points: vertices, polygons: polygons)
    }
}

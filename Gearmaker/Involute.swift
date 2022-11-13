//
//  Involute.swift
//  Gearmaker
//
//  Created by Torsten Kammer on 12.11.22.
//  Copyright © 2022 Torsten Kammer. All rights reserved.
//

import Foundation

struct Involute {
    
    let baseCircleRadius: Double
    
    func point(at angleInRad: Double) -> SIMD2<Double> {
        let s = angleInRad * baseCircleRadius
        
        let circumferencePoint = CGPoint(x: baseCircleRadius * cos(angleInRad), y: baseCircleRadius * sin(angleInRad))
        
        return SIMD2<Double>(x: circumferencePoint.x + s*sin(angleInRad), y: circumferencePoint.y - s*cos(angleInRad))
    }
    
    func angleForIntersectionWithCircle(radius outerRadius: Double) -> Double {
        let relativeRadius = outerRadius
        let ratio = relativeRadius / baseCircleRadius
        return sqrt(ratio * ratio - 1) // TODO WTF?
    }
    
    func tangent(at angleInRad: Double) -> SIMD2<Double> {
        return SIMD2<Double>(x: cos(angleInRad), y: sin(angleInRad))
    }
}

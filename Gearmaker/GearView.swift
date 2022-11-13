//
//  GearView.swift
//  Gearmaker
//
//  Created by Torsten Kammer on 13.11.22.
//  Copyright © 2022 Torsten Kammer. All rights reserved.
//

import Cocoa

class GearView: NSView {
    
    @objc var gear: Gear? = nil
    private var observations: [NSKeyValueObservation] = []
    private var outlinePoints: [SIMD2<Double>] = []
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        prepareObservations()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        prepareObservations()
    }
    
    private func prepareObservations() {
        observations.append(self.observe(\.gear?.module, changeHandler: { view, _ in
            view.updateGear()
        }))
        observations.append(self.observe(\.gear?.teeth, changeHandler: { view, _ in
            view.updateGear()
        }))
        observations.append(self.observe(\.gear?.eingriffwinkel, changeHandler: { view, _ in
            view.updateGear()
        }))
        observations.append(self.observe(\.gear?.kopfspielfaktor, changeHandler: { view, _ in
            view.updateGear()
        }))
    }
    
    override func draw(_ dirtyRect: NSRect) {
        // Clear background
        NSColor.white.set()
        NSBezierPath(rect: dirtyRect).fill()
        
        guard let gear = gear, !outlinePoints.isEmpty else {
            return
        }
        
        // Translate to draw from center
        let transform = NSAffineTransform()
        transform.translateX(by: bounds.midX, yBy: bounds.midY)
        
        // Draw teilkreis
        NSColor.red.set()
        let teilkreisradius = gear.teilkreisdurchmesser / 2
        let teilkreispath = NSBezierPath(ovalIn: NSRect(origin: CGPoint(x: -teilkreisradius, y: -teilkreisradius), size: CGSize(width: gear.teilkreisdurchmesser, height: gear.teilkreisdurchmesser)))
        transform.transform(teilkreispath).stroke()
        
        // Draw gear
        NSColor.black.set()
        let gearPath = NSBezierPath()
        gearPath.move(to: CGPoint(point: outlinePoints.first!))
        for point in outlinePoints {
            gearPath.line(to: CGPoint(point: point))
        }
        gearPath.close()
        transform.transform(gearPath).stroke()
    }
                         
    private func updateGear() {
        outlinePoints = gear?.outlinePoints(interval: 1.0) ?? []
        needsDisplay = true
    }
}

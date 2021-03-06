//
//  MapView.swift
//  Mountain Finder
//
//  Created by Matteo Bart on 6/7/20.
//  Copyright © 2020 Matteo Bart. All rights reserved.
//

import SwiftUI
import MapKit
import CoreLocation
struct MapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var selectedId: Int
    @Binding var showingDetail: Bool
    
    var locationManager = CLLocationManager()
    
    var circle: MKCircle {
        return MKCircle(center: centerCoordinate, radius: 193121)
    }
    var annotations: [MKPointAnnotation]
    func makeUIView(context: Context) -> MKMapView {
        locationManager.requestWhenInUseAuthorization()
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        let overlays = view.overlays
        view.removeOverlays(overlays)
        view.addOverlay(circle)
        //16.377 is just a constant I like
        let redDot = MKCircle(center: centerCoordinate, radius: view.region.span.longitudeDelta * 16.377)
        view.addOverlay(redDot)
        if annotations.count != view.annotations.count {
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
        }
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate = mapView.centerCoordinate
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let circleOverlay = overlay as? MKCircle else {return MKOverlayRenderer()}
            let circleRenderer = MKCircleRenderer(circle: circleOverlay)
            if circleOverlay.radius == 193121 { //big blue circle
                circleRenderer.strokeColor = .blue
                circleRenderer.fillColor = .blue
                circleRenderer.alpha = 0.2
            } else {
                circleRenderer.strokeColor = .red
                circleRenderer.fillColor = .red
                circleRenderer.alpha = 1
            }
            return circleRenderer
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation.title == "My Location" && !annotation.isKind(of: ClimbingPointAnnotation.self) {
                return nil //shows blue dot for user location
            }
            let identifier = "climbLoc"

            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                pinView.canShowCallout = true
                pinView.pinTintColor = UIColor.green
                pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                annotationView = pinView
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let placemark = view.annotation as? ClimbingPointAnnotation else { return }
            parent.selectedId = placemark.id
            parent.showingDetail = true
        }

    }
}

class ClimbingPointAnnotation: MKPointAnnotation {
    var id: Int
    init(_ id: Int) {
        self.id = id
    }
}

//
//  ClusteredMapView.swift
//  ShroomScout
//
//  A UIViewRepresentable wrapper for MKMapView with annotation clustering support.
//  Clusters nearby pins when zoomed out and displays a count badge.
//

import SwiftUI
import MapKit

// MARK: - Sighting Annotation

/// Custom annotation for individual mushroom sightings
class SightingAnnotation: NSObject, MKAnnotation {
    let sighting: MapSightingItem

    var coordinate: CLLocationCoordinate2D {
        sighting.coordinate
    }

    var title: String? {
        sighting.speciesName
    }

    init(sighting: MapSightingItem) {
        self.sighting = sighting
        super.init()
    }
}

// MARK: - Clustered Map View

struct ClusteredMapView: UIViewRepresentable {
    let sightings: [MapSightingItem]
    let selectedSighting: MapSightingItem?
    @Binding var region: MKCoordinateRegion

    var onSightingSelected: ((MapSightingItem) -> Void)?
    var onClusterSelected: (([MapSightingItem]) -> Void)?

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true

        // Register annotation views
        mapView.register(
            SightingAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        mapView.register(
            ClusterAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        )

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update annotations if sightings changed
        let currentAnnotations = mapView.annotations.compactMap { $0 as? SightingAnnotation }
        let currentIDs = Set(currentAnnotations.map { $0.sighting.id })
        let newIDs = Set(sightings.map { $0.id })

        // Remove annotations that are no longer in the list
        let toRemove = currentAnnotations.filter { !newIDs.contains($0.sighting.id) }
        mapView.removeAnnotations(toRemove)

        // Add new annotations
        let toAdd = sightings.filter { !currentIDs.contains($0.id) }
            .map { SightingAnnotation(sighting: $0) }
        mapView.addAnnotations(toAdd)

        // Update selected annotation
        if let selected = selectedSighting,
           let annotation = mapView.annotations.first(where: {
               ($0 as? SightingAnnotation)?.sighting.id == selected.id
           }) {
            mapView.selectAnnotation(annotation, animated: true)
        }

        // Only update camera if the region binding changed programmatically
        // (not from user panning, which syncs the binding via delegate)
        if let lastKnown = context.coordinator.lastKnownRegion {
            let latDiff = abs(lastKnown.center.latitude - region.center.latitude)
            let lonDiff = abs(lastKnown.center.longitude - region.center.longitude)

            // If binding region differs significantly from last known, it was a programmatic change
            if latDiff > 0.001 || lonDiff > 0.001 {
                context.coordinator.isUpdatingFromDelegate = true
                context.coordinator.lastKnownRegion = region
                mapView.setRegion(region, animated: true)
            }
        } else {
            // First time - set the initial region
            context.coordinator.isUpdatingFromDelegate = true
            context.coordinator.lastKnownRegion = region
            mapView.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: ClusteredMapView
        var lastKnownRegion: MKCoordinateRegion?
        var isUpdatingFromDelegate = false

        init(_ parent: ClusteredMapView) {
            self.parent = parent
        }

        // Update the binding when user moves the map
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            // Prevent feedback loop - don't update binding if we just set the region programmatically
            guard !isUpdatingFromDelegate else {
                isUpdatingFromDelegate = false
                return
            }

            // Sync the region back to the binding so it stays in sync with user's view
            DispatchQueue.main.async {
                self.parent.region = mapView.region
                self.lastKnownRegion = mapView.region
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Don't customize user location
            if annotation is MKUserLocation {
                return nil
            }

            // Handle cluster annotations
            if let cluster = annotation as? MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
                    for: annotation
                ) as? ClusterAnnotationView ?? ClusterAnnotationView(annotation: cluster, reuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)

                view.annotation = cluster
                view.updateCount(cluster.memberAnnotations.count)
                return view
            }

            // Handle sighting annotations
            if let sightingAnnotation = annotation as? SightingAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier,
                    for: annotation
                ) as? SightingAnnotationView ?? SightingAnnotationView(annotation: sightingAnnotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

                view.annotation = sightingAnnotation
                view.updateRarity(sightingAnnotation.sighting.rarity)
                view.updateName(sightingAnnotation.sighting.speciesName)
                view.clusteringIdentifier = "mushroom-cluster"
                return view
            }

            return nil
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let cluster = view.annotation as? MKClusterAnnotation {
                // Cluster selected - zoom in or show list
                let sightings = cluster.memberAnnotations.compactMap { ($0 as? SightingAnnotation)?.sighting }
                parent.onClusterSelected?(sightings)

                // Zoom to show all annotations in the cluster
                let region = regionForAnnotations(cluster.memberAnnotations)
                mapView.setRegion(region, animated: true)
            } else if let sightingAnnotation = view.annotation as? SightingAnnotation {
                parent.onSightingSelected?(sightingAnnotation.sighting)
            }
        }

        private func regionForAnnotations(_ annotations: [MKAnnotation]) -> MKCoordinateRegion {
            var minLat = 90.0
            var maxLat = -90.0
            var minLon = 180.0
            var maxLon = -180.0

            for annotation in annotations {
                minLat = min(minLat, annotation.coordinate.latitude)
                maxLat = max(maxLat, annotation.coordinate.latitude)
                minLon = min(minLon, annotation.coordinate.longitude)
                maxLon = max(maxLon, annotation.coordinate.longitude)
            }

            let center = CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            )

            let span = MKCoordinateSpan(
                latitudeDelta: (maxLat - minLat) * 1.5 + 0.01,
                longitudeDelta: (maxLon - minLon) * 1.5 + 0.01
            )

            return MKCoordinateRegion(center: center, span: span)
        }
    }
}

// MARK: - Sighting Annotation View

class SightingAnnotationView: MKAnnotationView {
    private let pinSize: CGFloat = 36
    private let labelHeight: CGFloat = 20
    private let labelWidth: CGFloat = 100
    private var circleView: UIView?
    private var nameLabel: UILabel?
    private var currentRarity: Rarity = .common
    private var currentName: String = ""

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        // Frame includes pin + label below
        frame = CGRect(x: 0, y: 0, width: labelWidth, height: pinSize + labelHeight + 4)
        // Center the pin on the coordinate, label hangs below
        centerOffset = CGPoint(x: 0, y: -(labelHeight + 4) / 2)
        canShowCallout = false

        createPinView()
    }

    private func createPinView() {
        circleView?.removeFromSuperview()
        nameLabel?.removeFromSuperview()

        // Circle with white stroke - centered horizontally
        let circleX = (labelWidth - pinSize) / 2
        let circle = UIView(frame: CGRect(x: circleX, y: 0, width: pinSize, height: pinSize))
        circle.backgroundColor = UIColor(AppColors.color(for: currentRarity))
        circle.layer.cornerRadius = pinSize / 2
        circle.layer.borderWidth = 2
        circle.layer.borderColor = UIColor.white.cgColor
        circle.layer.shadowColor = UIColor.black.cgColor
        circle.layer.shadowOpacity = 0.2
        circle.layer.shadowOffset = CGSize(width: 0, height: 2)
        circle.layer.shadowRadius = 4

        // Mushroom emoji
        let emojiLabel = UILabel()
        emojiLabel.text = "🍄"
        emojiLabel.font = .systemFont(ofSize: 16)
        emojiLabel.sizeToFit()
        emojiLabel.center = CGPoint(x: circle.bounds.midX, y: circle.bounds.midY)
        circle.addSubview(emojiLabel)

        addSubview(circle)
        circleView = circle

        // Name label below the pin
        let label = UILabel(frame: CGRect(x: 0, y: pinSize + 4, width: labelWidth, height: labelHeight))
        label.text = currentName
        label.font = UIFont(name: "Nunito-SemiBold", size: 11) ?? .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = UIColor(AppColors.textDark)
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        // Add subtle shadow for readability
        label.layer.shadowColor = UIColor.white.cgColor
        label.layer.shadowOffset = .zero
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.8

        addSubview(label)
        nameLabel = label
    }

    func updateRarity(_ rarity: Rarity) {
        if currentRarity != rarity {
            currentRarity = rarity
            circleView?.backgroundColor = UIColor(AppColors.color(for: currentRarity))
        }
    }

    func updateName(_ name: String) {
        if currentName != name {
            currentName = name
            nameLabel?.text = name
        }
    }
}

// MARK: - Cluster Annotation View

class ClusterAnnotationView: MKAnnotationView {
    private let clusterSize: CGFloat = 44
    private var countLabel: UILabel?
    private var circleView: UIView?

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        frame = CGRect(x: 0, y: 0, width: clusterSize, height: clusterSize)
        centerOffset = CGPoint(x: 0, y: -clusterSize / 2)
        canShowCallout = false

        // Circle background
        let circle = UIView(frame: bounds)
        circle.backgroundColor = UIColor(AppColors.coral)
        circle.layer.cornerRadius = clusterSize / 2
        circle.layer.borderWidth = 3
        circle.layer.borderColor = UIColor.white.cgColor
        circle.layer.shadowColor = UIColor.black.cgColor
        circle.layer.shadowOpacity = 0.25
        circle.layer.shadowOffset = CGSize(width: 0, height: 2)
        circle.layer.shadowRadius = 6
        addSubview(circle)
        circleView = circle

        // Count label
        let label = UILabel(frame: bounds)
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .bold)
        addSubview(label)
        countLabel = label
    }

    func updateCount(_ count: Int) {
        countLabel?.text = count > 99 ? "99+" : "\(count)"
    }
}

// MARK: - Preview

#Preview {
    ClusteredMapView(
        sightings: [
            MapSightingItem(
                id: UUID(),
                speciesID: "chanterelle",
                speciesName: "Golden Chanterelle",
                scientificName: "Cantharellus cibarius",
                locationName: "Discovery Park",
                coordinate: CLLocationCoordinate2D(latitude: 47.6615, longitude: -122.4176),
                dateSighted: Date(),
                rarity: .uncommon,
                photoFileName: "chanterelle",
                distance: "0.5 mi"
            ),
            MapSightingItem(
                id: UUID(),
                speciesID: "morel",
                speciesName: "Black Morel",
                scientificName: "Morchella elata",
                locationName: "Mt. Rainier",
                coordinate: CLLocationCoordinate2D(latitude: 47.6620, longitude: -122.4180),
                dateSighted: Date(),
                rarity: .rare,
                photoFileName: "morel",
                distance: "1.2 mi"
            )
        ],
        selectedSighting: nil,
        region: .constant(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 47.6615, longitude: -122.4176),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    )
}

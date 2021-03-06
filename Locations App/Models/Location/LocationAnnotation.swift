import Foundation
import Mapbox

final class LocationAnnotation: NSObject, MGLAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let color: UIColor
    let location: Location
    
    init(location: Location) {
        self.coordinate = location.coordinate
        self.title = location.name
        self.subtitle = "Visited \(location.visits.count) times"
        self.color = location.accent
        self.location = location
    }
}

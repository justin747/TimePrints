import Foundation
import CoreData
import UIKit

@objc(Visit)
public class Visit: NSManagedObject {
    class func count() -> Int {
        let fetchRequest: NSFetchRequest<Visit> = Visit.fetchRequest()
        
        do {
            let count = try CoreData.stack.context.count(for: fetchRequest)
            return count
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    class func newVisit() -> Visit {
        Visit(context: CoreData.stack.context)
    }

    class func create(arrivalDate: Date) -> Visit {
        let visit = newVisit()
        visit.arrivalDate = arrivalDate
        CoreData.stack.save()

        return visit
    }

    class func create(arrivalDate: Date, departureDate: Date) -> Visit {
        let visit = newVisit()
        visit.arrivalDate = arrivalDate
        visit.departureDate = departureDate
        CoreData.stack.save()
        
        return visit
    }

    class func fetch(with arrivalDate: Date) -> Visit? {
        let fetchRequest: NSFetchRequest<Visit> = Visit.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%@ == arrivalDate", arrivalDate as NSDate)
        let incompleteVisit = try! CoreData.stack.context.fetch(fetchRequest)
        return incompleteVisit.first
    }
}

extension Visit {
    func setLocationName(_ name: String) {
        self.location.setName(name)
    }

    func setNotes(_ notes: String) {
        self.notes = notes
        CoreData.stack.save()
    }

    func complete(with departureDate: Date) {
        self.departureDate = departureDate
        CoreData.stack.save()
    }

    @discardableResult
    func favorite() -> Bool {
        isFavorite.toggle()
        CoreData.stack.save()
        return isFavorite
    }

    func delete() -> Visit {
        let visit = self
        CoreData.stack.context.delete(self)
        return visit
    }
}

extension Visit {
    var duration: String {
        var duration = self.arrivalDate.timeOnlyWithPadding
        if let departureTime = departureDate?.timeOnlyWithPadding {
            duration += " ➝ " + departureTime
            if departureDate?.fullDayOfWeek != arrivalDate.fullDayOfWeek {
                duration += "  ➤"
            }
        }
        return duration
    }

    var tagName: String {
        self.location.tag.name
    }

    var tagColor: UIColor {
        self.location.tag.uiColor
    }
}

extension Visit {
    class var preview: Visit {
        let visit = newVisit()
        visit.location.latitude = 12.9716
        visit.location.longitude = 77.5946
        visit.arrivalDate = Date.random(range: 1000)
        visit.departureDate = Date().addingTimeInterval(.random(in: 100...2000))
        visit.location.address = "1 Infinite Loop, Cupertino, California"
        visit.notes = "Had a great time visiting my friend, who works here. The food is amazing and the pay seems great."
        visit.location.name = "Apple INC"
        visit.isFavorite = true
        visit.location.tag = Tag.create(name: "Visit", color: .berryRed)
        CoreData.stack.save()
        return visit
    }
    
    class var previewVisits: [Visit] {
        var visits = [Visit]()
        for _ in 0..<10 {
            let date = Date.random(range: 100)
            for _ in 0..<10 {
                let visit = preview
                visit.location.name = "Apple INC"
                visit.arrivalDate = date
                visits.append(visit)
            }
        }
        return visits
    }
    
    class var previewVisitDetails: [Visit] {
        var visits = [Visit]()
        let date = Date.random(range: 100)
        for _ in 0..<5 {
            let visit = preview
            visit.arrivalDate = date
            visits.append(visit)
        }
        return visits
    }
}

private extension Date {
    static func random(range: Int) -> Date {
        let interval = Date().timeIntervalSince1970
        let intervalRange = Double(86_400 * range)
        let random = Double(arc4random_uniform(UInt32(intervalRange)) + 1)
        let newInterval = interval + (random - (intervalRange / 2.0))
        return Date(timeIntervalSince1970: newInterval)
    }
}

//
//  HealthKitManager.swift
//  WaterMe
//
//  Created by Tommy Kovalchuk on 2024-07-17.
//

import Foundation
import HealthKit

extension Date {
    static var startOfToday: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

struct HealthKitResults {
    var units: HKUnit
    var consumption: HKQuantity
    var mostRecentWater: HKSample? = nil
    
    init(){
        self.units = HKUnit.literUnit(with: .milli)
        self.consumption = HKQuantity.init(unit: self.units, doubleValue: 0)

    }
}

class HealthKitManager : ObservableObject {
    let healthStore: HKHealthStore = HKHealthStore()
    @Published var results: HealthKitResults = HealthKitResults()
    
    init() {
        Task {
            if HKHealthStore.isHealthDataAvailable() {
                await requestAuthorization()
                await fetchTodayWater()
                fetchMostRecentWater()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(methodOfReceivedNotification(notification:)), name: NSNotification.Name.HKUserPreferencesDidChange, object: nil)

    }
    
    func requestAuthorization() async {
        let healthKitAccess: Set = [
            HKQuantityType(.dietaryWater)
        ];
        do {
            try await healthStore.requestAuthorization(toShare: healthKitAccess, read: healthKitAccess)
        } catch {
            fatalError("*** An unexpected error occurred while requesting authorization: \(error.localizedDescription) ***")
        }
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        Task {
            await fetchUserUnitPreference()
        }
    }
    
    var increment: Double {
        return UserDefaults.standard.double(forKey: "increment")
    }
    
    func fetchUserUnitPreference() async {
        healthStore.preferredUnits(for: [HKQuantityType(.dietaryWater)]) { result, error in
            DispatchQueue.main.async {
                if(result[HKQuantityType(.dietaryWater)] != nil){
                    self.results.units = result[HKQuantityType(.dietaryWater)]!
                    
                    if(UserDefaults.standard.object(forKey: "increment") == nil || UserDefaults.standard.double(forKey: "increment") <= 0) {
                        UserDefaults.standard.setValue(HKQuantity(unit: .literUnit(with: .milli), doubleValue: 500).doubleValue(for: self.results.units), forKey: "increment")
                    }
                }
            }
        }
    }
    
    func fetchTodayWater() async {
        let type = HKQuantityType(.dietaryWater)
        let datePredicate = HKQuery.predicateForSamples(withStart: .startOfToday, end: Date())
        let sourcePredicate = HKQuery.predicateForObjects(from: HKSource.default())
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, sourcePredicate])
                
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate) { _, result, error in
            if (error != nil) {
                debugPrint("*** fetchTodayWater() Error: \(error?.localizedDescription ?? "") ***")
            }
            
            DispatchQueue.main.async {
                if(result != nil){
                    self.results.consumption = result!.sumQuantity() ?? HKQuantity.init(unit: self.results.units, doubleValue: 0)
                }else {
                    self.results.consumption = HKQuantity.init(unit: self.results.units, doubleValue: 0)
                }
            }
        }
        healthStore.execute(query)
    }
    
    func fetchMostRecentWater() {
        let type = HKQuantityType(.dietaryWater)
        let datePredicate = HKQuery.predicateForSamples(withStart: .startOfToday, end: Date())
        let sourcePredicate = HKQuery.predicateForObjects(from: HKSource.default())
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, sourcePredicate])
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) {
            query, result, error in
            
            if (error != nil){
                debugPrint("*** fetchMostRecentWater() Error: \(error?.localizedDescription ?? "") ***")
            }
            
            DispatchQueue.main.async {
                self.results.mostRecentWater = result?.first ?? nil
            }
        }
        healthStore.execute(query)
    }
    
    func addTodayWater(customAmount: Double) async {
        let type = HKQuantityType(.dietaryWater)
        let qty = HKQuantity(unit: self.results.units, doubleValue: customAmount)
        let water: HKQuantitySample = HKQuantitySample(type: type, quantity: qty, start: Date(), end: Date())
        do {
            try await healthStore.save(water)
        } catch {
            fatalError("*** An unexpected error occurred while saving the water: \(error.localizedDescription) ***")
        }
    }
    
    func addTodayWater() async {
        let type = HKQuantityType(.dietaryWater)
        let qty = HKQuantity(unit: self.results.units, doubleValue: self.increment)
        let water: HKQuantitySample = HKQuantitySample(type: type, quantity: qty, start: Date(), end: Date())
        do {
            try await healthStore.save(water)
        } catch {
            fatalError("*** An unexpected error occurred while saving the water: \(error.localizedDescription) ***")
        }
    }
    
    func removeTodayWater() async {
        if(self.results.mostRecentWater == nil) {
            return
        }
        
        do {
            try await healthStore.delete(self.results.mostRecentWater!)
        } catch {
            fatalError("*** An unexpected error occurred while deleting the water: \(error.localizedDescription) ***")
        }
    }
}


extension HKUnit {
    func formatted() -> String {
        switch self.unitString {
        case "cup_imp":
            return "cups"
        case "cup_us":
            return "cups"
        case "fl_oz_imp":
            return "fl. oz."
        case "fl_oz_us":
            return "fl. oz."
        case "L":
            return "L"
        case "mL":
            return "mL"
        case "pt_imp":
            return "pints"
        case "pt_us":
            return "pints"
        default:
            return ""
        }
    }
}

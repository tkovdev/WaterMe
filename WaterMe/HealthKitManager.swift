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

class HealthKitManager : ObservableObject {
    let healthStore: HKHealthStore = HKHealthStore()
    @Published var consumption: [Date : Double] = [:]
    @Published var mostRecentWater: HKSample? = nil
    
    init() {
        let healthKitAccess: Set = [
            HKQuantityType(.dietaryWater)
        ];
        Task {
            do {
                if HKHealthStore.isHealthDataAvailable() {
                    try await healthStore.requestAuthorization(toShare: healthKitAccess, read: healthKitAccess)
                    await fetchTodayWater()
                    await fetchMostRecentWater()
                }
            } catch {
                
                fatalError("*** An unexpected error occurred while requesting authorization: \(error.localizedDescription) ***")
            }
        }
    }
    
    func fetchTodayWater() async {
        let type = HKQuantityType(.dietaryWater)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfToday, end: Date())

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate) { _, result, error in
            guard let qty = result, error == nil else {
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                self.consumption[.startOfToday] = qty.sumQuantity()?.doubleValue(for: .literUnit(with: .milli))
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
                return
            }
            guard let qty = result, error == nil else {
                return
            }
            guard let water = qty.first else {
                return
            }
            
            DispatchQueue.main.async {
                self.mostRecentWater = water
                print(self.mostRecentWater!)
            }
        }
        healthStore.execute(query)
    }
    
    func addTodayWater() async {
        let type = HKQuantityType(.dietaryWater)
        let qty = HKQuantity(unit: .literUnit(with: .milli), doubleValue: 500)
        let water: HKQuantitySample = HKQuantitySample(type: type, quantity: qty, start: Date(), end: Date())
        do {
            try await healthStore.save(water)
        } catch {
            fatalError("*** An unexpected error occurred while saving the water: \(error.localizedDescription) ***")
        }
    }
    
    func removeTodayWater() async {
        if(self.mostRecentWater == nil) {
            return
        }
        
        do {
            try await healthStore.delete(self.mostRecentWater!)
        } catch {
            fatalError("*** An unexpected error occurred while deleting the water: \(error.localizedDescription) ***")
        }
    }
}

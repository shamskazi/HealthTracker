import HealthKit
import Firebase

class HealthKitManager {
    let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(false)
            return
        }

        healthStore.requestAuthorization(toShare: nil, read: [sleepType]) { success, error in
            completion(success)
        }
    }

    func fetchSleepData(completion: @escaping (Date?, Date?) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil, nil)
            return
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, results, error in
            guard let sample = results?.first as? HKCategorySample else {
                completion(nil, nil)
                return
            }

            let startDate = sample.startDate
            let endDate = sample.endDate
            completion(startDate, endDate)
        }
        healthStore.execute(query)
    }

    func saveSleepDataToFirestore(startDate: Date, endDate: Date, userId: String) {
        let db = Firestore.firestore()
        db.collection("sleepData").addDocument(data: [
            "startDate": startDate,
            "endDate": endDate,
            "userId": userId
        ])
    }
}

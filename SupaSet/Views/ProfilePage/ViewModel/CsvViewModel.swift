//
//  CsvViewModel.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/28/25.
//

import SwiftUI
import SwiftCSV

enum FileFrom {
    case hevy, strong
}

struct ExerciseMapping: Identifiable, Hashable {
    let id = UUID()
    let exerciseId: String
    let name: String
}
struct HevyExerciseSet: Identifiable {
    let id = UUID()
    let set_index: Int
    let set_type: String
    let weight_kg: Double?
    let reps: Int?
    let distance_km: Double?
    let duration_seconds: Int?
    let rpe: Int?
}
struct HevyWorkoutExercise: Identifiable {
    let id = UUID()
    let exercise_title: String
    let superset_id: String?
    let exercise_notes: String?
    let hevyExerciseSets: [HevyExerciseSet]
}
struct HevyWorkout: Identifiable {
    let id = UUID()
    let start_time: Date
    let end_time: Date
    let title: String
    let description: String?
    let hevyWorkoutExercises: [HevyWorkoutExercise]
}
@Observable
final class CsvViewModel {
    var content: String = ""
    var fileFrom: FileFrom = .hevy
    var processing = false
    var hevyData: [HevyWorkout]?
    var exerciseMapping: [ExerciseMapping]?
    let hevyHeader = ["title", "start_time", "end_time", "description", "exercise_title", "superset_id", "exercise_notes", "set_index", "set_type", "weight_lbs", "reps", "distance_miles", "duration_seconds", "rpe"]
    
    let appDatabase: AppDatabase
    
    init(appDatabase: AppDatabase){
        self.appDatabase = appDatabase
    }
    func handleFileImport(for result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            readFile(url)
        case .failure(let error):
            // TODO:
            print(error)
        }
    }
    
    func readFile(_ url: URL) {
        guard url.startAccessingSecurityScopedResource() else {return}
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            self.content = content
            parseCSV(content: content)
        }catch {
            // TODO:
        }
        url.stopAccessingSecurityScopedResource()
    }
    
    private func parseCSV(content: String) {
        do {
            let data = try EnumeratedCSV(string: content, delimiter: .comma, loadColumns: false)
            if data.header == hevyHeader {
                fileFrom = .hevy
                let data = parseHevyRows(from: data.rows)
                hevyData = data.0
                exerciseMapping = data.1
            }
        } catch {
            print(error)
        }
    }
    
    private func parseHevyRows(from rows: [[String]]) -> ([HevyWorkout], [ExerciseMapping]) {
        var workouts: [HevyWorkout] = []
        var workoutDict: [String: [String]] = [:] // Key: workout identifier, Value: workout info
        var exerciseDict: [String: [[String]]] = [:] // Key: workout identifier, Value: exercise rows
        var newExerciseMapping: [String: String] = [:]
        // Group rows by workout
        for rowData in rows {
            guard rowData.count == hevyHeader.count else { continue }
            
            let workoutKey = "\(rowData[0])_\(rowData[1])_\(rowData[2])" // title_start_time_end_time
            
            // Store workout info (first occurrence)
            if workoutDict[workoutKey] == nil {
                workoutDict[workoutKey] = Array(rowData[0...3]) // title, start_time, end_time, description
            }
            
            // Group exercise data
            if exerciseDict[workoutKey] == nil {
                exerciseDict[workoutKey] = []
            }
            exerciseDict[workoutKey]?.append(rowData)
        }
        
        // Create HevyWorkout objects
        for (workoutKey, workoutInfo) in workoutDict {
            guard let exerciseRows = exerciseDict[workoutKey],
                  let startTime = parseDate(workoutInfo[1]),
                  let endTime = parseDate(workoutInfo[2]) else { continue }
            
            let title = workoutInfo[0]
            let description = workoutInfo[3].isEmpty ? nil : workoutInfo[3]
            
            // Group exercises by exercise_title and superset_id
            var exerciseGroups: [String: [[String]]] = [:]
            
            for row in exerciseRows {
                let exerciseTitle = row[4]
                let supersetId = row[5].isEmpty ? nil : row[5]
                let exerciseKey = "\(exerciseTitle)_\(supersetId ?? "nil")"
                
                if exerciseGroups[exerciseKey] == nil {
                    exerciseGroups[exerciseKey] = []
                }
                exerciseGroups[exerciseKey]?.append(row)
            }
            
            // Create HevyWorkoutExercise objects
            var workoutExercises: [HevyWorkoutExercise] = []
            
            for (_, exerciseRows) in exerciseGroups {
                guard let firstRow = exerciseRows.first else { continue }
                
                let exerciseTitle = firstRow[4]
                let supersetId = firstRow[5].isEmpty ? nil : firstRow[5]
                let exerciseNotes = firstRow[6].isEmpty ? nil : firstRow[6]
                let exerciseId = exerciseTitle.map{$0.isLetter ? $0.lowercased() : "-"}.reduce("") { $0 + String($1)}
                if newExerciseMapping[exerciseId] == nil {
                    newExerciseMapping[exerciseId] = exerciseTitle
                }
                // Create exercise sets
                var exerciseSets: [HevyExerciseSet] = []
                
                for row in exerciseRows {
                    let setIndex = Int(row[7]) ?? 0
                    let setType = row[8]
                    let weightLbs = Double(row[9])
                    let weightKg = weightLbs != nil ? weightLbs! * 0.453592 : nil // Convert lbs to kg
                    let reps = Int(row[10])
                    let distanceMiles = Double(row[11])
                    let distanceKm = distanceMiles != nil ? distanceMiles! * 1.60934 : nil // Convert miles to km
                    let durationSeconds = Int(row[12])
                    let rpe = Int(row[13])
                    
                    let exerciseSet = HevyExerciseSet(
                        set_index: setIndex,
                        set_type: setType,
                        weight_kg: weightKg,
                        reps: reps,
                        distance_km: distanceKm,
                        duration_seconds: durationSeconds,
                        rpe: rpe
                    )
                    
                    exerciseSets.append(exerciseSet)
                }
                
                // Sort sets by set_index
                exerciseSets.sort { $0.set_index < $1.set_index }
                
                let workoutExercise = HevyWorkoutExercise(
                    exercise_title: exerciseTitle,
                    superset_id: supersetId,
                    exercise_notes: exerciseNotes,
                    hevyExerciseSets: exerciseSets
                )
                
                workoutExercises.append(workoutExercise)
            }
            
            let workout = HevyWorkout(
                start_time: startTime,
                end_time: endTime,
                title: title,
                description: description,
                hevyWorkoutExercises: workoutExercises
            )
            
            workouts.append(workout)
        }
        
        // Sort workouts by start_time
        workouts.sort { $0.start_time < $1.start_time }
        
        return (workouts,newExerciseMapping.map{ExerciseMapping(exerciseId: $0.key, name: $0.value)})
    }

    // Helper function to parse date strings
    private func parseDate(_ dateString: String) -> Date? {
        let dateFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "d MMM yyyy, HH:mm"   // 27 Aug 2025, 19:28
            f.locale = Locale(identifier: "en_US_POSIX")
            f.timeZone = TimeZone(secondsFromGMT: 0)   // ← adjust if the CSV uses local time
            return f
        }()
        
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
        
        return nil
    }

}

//
//  NewTemplateSetsView.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/1/25.
//

import SwiftUI

struct EditTemplateSetsView: View {
    
    @Environment(\.appDatabase) private var appDatabase
    @Binding var templateSets: [TemplateExerciseSet]
    let padding: CGFloat
    let exerciseOrder: Int
    let spacing: CGFloat = 5
    var body: some View {
        ForEach(templateSets, id: \.order) { templateSet in
            let workingSetOrder = templateSets.filter({$0.setType == .working && $0.order < templateSet.order}).count
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        SetTypeIndicatorView(exerciseSetType: templateSet.setType, setOrder: workingSetOrder) { newType in
                            
                        }
                        HStack(spacing: spacing){
                            
                            WeightView(
                                weight: templateSet.weight ?? 0,
                                isDone: false,
                                fieldType: .weight(exerciseOrder, templateSet.order)
                            ){ newWeight in
                                if let index = templateSets.firstIndex(where: {$0 == templateSet}){
                                    templateSets[index].weight = newWeight
                                }
                            }
                            .frame(width: 100)
                            HStack {
                                Group {
                                    let repType = templateSet.repType
                                    switch repType {
                                    case .reps(let reps):
                                        TemplateRepsView(reps: reps, repType: repType, fieldType: .reps(exerciseOrder, templateSet.order)) { newReps in
                                            if let index = templateSets.firstIndex(where: {$0 == templateSet}){
                                                templateSets[index].repType = .reps(newReps)
                                            }
                                        }
                                    case .range(let lowerBound, let upperBound):
                                        TemplateRepsView(reps: lowerBound, repType: repType, fieldType: .reps(exerciseOrder, templateSet.order)) { newLowerBound in
                                            if let index = templateSets.firstIndex(where: {$0 == templateSet}){
                                                let upperUnwrapped = upperBound == nil ? newLowerBound : upperBound!
                                                templateSets[index].repType = .range(newLowerBound,upperUnwrapped)
                                            }
                                        }
                                        Text("-")
                                        TemplateRepsView(reps: upperBound, repType: repType, fieldType: .reps(exerciseOrder, templateSet.order, 1)) { newUpperBound in
                                            if let index = templateSets.firstIndex(where: {$0 == templateSet}){
                                                let lowerUnwrapped = lowerBound == nil ? newUpperBound : lowerBound!
                                                templateSets[index].repType = .range(lowerUnwrapped,newUpperBound)
                                            }
                                        }
                                    }
                                }
                                Menu {
                                    Button("Reps"){
                                        if let index = templateSets.firstIndex(where: {$0 == templateSet}){
                                            templateSets[index].repType = .reps(nil)
                                        }
                                    }
                                    Button("Range") {
                                        if let index = templateSets.firstIndex(where: {$0 == templateSet}){
                                            templateSets[index].repType = .range(nil, nil)
                                        }
                                    }
                                } label: {
                                    Image(systemName : templateSet.repType.description == "Reps" ? "textformat.123" : "arrow.left.and.right")
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                        .fontWeight(.bold)
                                }
                                .frame(width: 40, height: 40)
                                .contentTransition(.symbolEffect(.replace, options: .speed(2)))
                                .foregroundStyle(.primary)
                                .modify {
                                    if #available(iOS 26, *) {
                                        $0
                                            .glassEffect(.regular.interactive(), in: .circle)
                                    } else {
                                        $0
                                            .background(.regularMaterial, in: .circle)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(width: UIScreen.main.bounds.size.width - 40 - spacing - 2*padding - padding)
                    }
                    .frame(height: 50)
                    .padding(.horizontal, padding/2)
                    .ignoresSafeArea()
                    .background(.clear)
                }
            }
            .scrollDisabled(true)
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            .cornerRadius(12)
        }
        
    }
}

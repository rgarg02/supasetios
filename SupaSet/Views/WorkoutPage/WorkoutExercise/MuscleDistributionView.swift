//
//  MuscleDistributionView.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/21/25.
//

import SwiftUI

struct MuscleDistributionView: View {
    let activePrimaryMuscles: Set<MuscleGroup>
    let activeSecondaryMuscles: Set<MuscleGroup>
    @Binding var selectedMuscle: MuscleGroup?
    var body: some View {
        VStack(spacing: 0) {
            Text("Muscle Distribution")
                .font(.title2.bold())
                .foregroundStyle(.primary.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack(alignment: .top) {
                SceneKitContainer(selectedMuscle: $selectedMuscle, interactable: false, activePrimaryMuscles: activePrimaryMuscles, activeSecondaryMuscles: activeSecondaryMuscles)
                    .aspectRatio(contentMode: .fit)
                HStack(spacing: 12) {
                    VStack(alignment: .leading) {
                        HStack(spacing: 6) {
                            Circle()
                                .stroke(Color.red, lineWidth: 2)
                                .frame(width: 16, height: 16)
                            Text("Primary")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                        HStack(spacing: 6) {
                            Circle()
                                .stroke(Color.yellow, lineWidth: 2)
                                .frame(width: 16, height: 16)
                            Text("Secondary")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .modify({ view in
                        if #available(iOS 26, *) {
                            view
                                .background(.thinMaterial.opacity(0.8), in: .rect(cornerRadius: 12))
//                                .glassEffect(.regular, in: .rect(cornerRadius: 12))
                        }else {
                            view
                                .background(.thinMaterial.opacity(0.8), in: .rect(cornerRadius: 12))
                        }
                    })
                    
                    Spacer()
                }
                .background(.clear)
                .padding()
            }
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
    }
}
#Preview {
    @Previewable @State var selectedMuscle: MuscleGroup?
    MuscleDistributionView(activePrimaryMuscles: [.chest, .shoulders], activeSecondaryMuscles: [.triceps], selectedMuscle: $selectedMuscle)
}

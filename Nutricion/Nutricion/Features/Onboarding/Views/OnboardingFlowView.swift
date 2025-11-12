//
//  OnboardingFlowView.swift
//  Nutricion
//
//  Created by Uriel Cruz on 28/10/25.
//

import SwiftUI

struct OnboardingFlowView: View {
    @StateObject private var vm = OnboardingViewModel()
    @AppStorage("didOnboard") private var didOnboard: Bool = false

    var body: some View {
        NavigationStack {
            NameStepView(
                name: $vm.name
            )
            .navigationDestination(for: OnboardingRoute.self) { route in
                switch route {
                case .age:
                    AgeStepView(age: $vm.age)
                case .sex:
                    SexStepView(sex: $vm.sex)
                case .weight:
                    WeightStepView(weight: $vm.weight)
                case .height:
                    HeightStepView(height: $vm.height)
                case .summary:
                    SummaryStepView(
                        name: vm.name,
                        age: vm.age,
                        sex: vm.sex,
                        weight: vm.weight,
                        height: vm.height,
                        onFinish: {
                            // Guardar perfil y marcar que terminamos onboarding
                            vm.saveProfile()
                            didOnboard = true
                        }
                    )
                }
            }
            .onAppear {
                vm.loadIfAvailable()
            }
        }
    }
}

// Rutas internas del flujo
enum OnboardingRoute: Hashable {
    case age
    case sex
    case weight
    case height
    case summary
}

#Preview {
    OnboardingFlowView()
}


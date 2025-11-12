//
//  UserProfile.swift
//  Nutricion
//
//  Created by Uriel Cruz on 27/10/25.
//

import Foundation

struct UserProfile: Codable {
    var name: String = ""
    var age: Int = 0
    var sex: String = "Masculino" // Puede ser "Masculino" o "Femenino"
    var weight: Double = 0.0      // En kilogramos
    var height: Double = 0.0      // En centímetros

    // IMC (kg/m^2)
    var bmi: Double {
        let hMeters = height / 100
        guard hMeters > 0, weight > 0 else { return 0 }
        return weight / (hMeters * hMeters)
    }

    // Peso ideal por talla
    // Fórmula: Peso ideal = (Talla en cm − 100) × 0.9
    // Ejemplo: 130 cm → (130−100)×0.9 = 27 kg
    var idealWeight: Double {
        guard height > 0 else { return 0 }
        let raw = (height - 100) * 0.9
        // Redondear a 1 decimal para coincidir con la práctica clínica y ejemplos
        return max(0, (raw * 10).rounded() / 10)
    }

    // Peso ideal ajustado (para sobrepeso u obesidad)
    // Fórmula: Peso ideal ajustado = [(Peso actual − Peso ideal) × 0.25] + Peso ideal
    // Ejemplo: Peso actual 40 kg, peso ideal 30 kg → [(40−30)×0.25]+30 = 32.5 kg
    var adjustedIdealWeight: Double {
        let iw = idealWeight
        guard iw > 0, weight > 0 else { return iw }
        let raw = ((weight - iw) * 0.25) + iw
        // Redondear a 1 decimal según la tabla de ejemplo
        return (raw * 10).rounded() / 10
    }

    // Notas clínicas:
    // • En sobrepeso y obesidad usar el peso ideal ajustado.
    // • En desnutrición usar peso ideal por talla.
    // Esta propiedad sugiere el peso de referencia según el estado actual.
    // Si el peso actual es mayor al ideal → usa ajustado; si es menor → usa ideal.
    var recommendedWeight: Double {
        let iw = idealWeight
        guard iw > 0 else { return 0 }
        if weight > iw { return adjustedIdealWeight }
        return iw
    }

    // Diagnóstico nutricional por IMC
    var diagnosis: String {
        switch bmi {
        case ..<18.5: return "Desnutrición"
        case 18.5...24.9: return "Peso normal"
        case 25...29.9: return "Sobrepeso"
        default: return "Obesidad"
        }
    }

    /// Diagnóstico para cálculo calórico basado en la relación con el Peso Ideal (PI)
    /// Heurística pediátrica temporal para reproducir ejemplos de tabla sin percentiles LMS:
    /// ratio = peso_actual / PI
    ///   ratio < 0.90  → Desnutrición
    ///   0.90..<1.10   → Peso normal
    ///   1.10..<1.30   → Sobrepeso
    ///   >= 1.30       → Obesidad
    /// Nota: Sustituir por percentiles IMC-edad/sexo (LMS) cuando estén disponibles.
    var diagnosisForCalories: String {
        let pi = idealWeight
        guard pi > 0, weight > 0 else { return diagnosis } // fallback al actual si faltan datos
        let ratio = weight / pi
        switch ratio {
        case ..<0.90: return "Desnutrición"
        case 0.90..<1.10: return "Peso normal"
        case 1.10..<1.30: return "Sobrepeso"
        default: return "Obesidad"
        }
    }

    /// Diagnóstico PEDIÁTRICO a mostrar en UI (mapea a diagnosisForCalories).
    /// Cuando integres percentiles LMS, sustituye su implementación interna.
    var pediatricDiagnosis: String { diagnosisForCalories }

    // Rango de kcal/kg según diagnóstico
    var kcalPerKgRange: (min: Double, max: Double) {
        switch diagnosisForCalories {
        case "Desnutrición": return (100, 120)
        case "Peso normal":  return (85, 95)
        case "Sobrepeso":    return (60, 75)
        default:              return (40, 60) // Obesidad
        }
    }

    // Peso a usar para el cálculo de kcal
    var weightForCalories: Double {
        switch diagnosisForCalories {
        case "Desnutrición":
            return idealWeight
        case "Peso normal":
            return weight
        case "Sobrepeso":
            return idealWeight
        default: // Obesidad
            return adjustedIdealWeight
        }
    }

    // Kcal diarias recomendadas (fórmula práctica de la tabla)
    // Desnutrición: 110 kcal/kg con Peso Ideal
    // Peso normal: 90 kcal/kg con Peso Actual
    // Sobrepeso: 67.5 kcal/kg con Peso Ideal
    // Obesidad: 50 kcal/kg con Peso Ideal Ajustado
    var dailyCaloriesPractical: Int {
        // Usa el punto medio del rango para evitar valores "mágicos"
        let range = kcalPerKgRange
        let midpoint = (range.min + range.max) / 2.0
        let kcal = weightForCalories * midpoint
        return Int(kcal.rounded())
    }

    // Kcal diarias recomendadas (rango completo)
    var dailyCaloriesRange: (min: Int, max: Int) {
        let r = kcalPerKgRange
        let minKcal = Int((weightForCalories * r.min).rounded())
        let maxKcal = Int((weightForCalories * r.max).rounded())
        return (minKcal, maxKcal)
    }

    /// Descripción de la base de peso utilizada para el cálculo calórico (UI/depuración)
    var weightBaseDescription: String? {
        switch diagnosisForCalories {
        case "Desnutrición":
            return String(format: "PI=%.1f kg", idealWeight)
        case "Peso normal":
            return String(format: "Peso actual=%.1f kg", weight)
        case "Sobrepeso":
            return String(format: "PI=%.1f kg", idealWeight)
        default: // Obesidad
            return String(format: "PIA=%.1f kg", adjustedIdealWeight)
        }
    }
}

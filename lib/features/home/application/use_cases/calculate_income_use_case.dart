import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/income_calculation.dart';

/// Caso de uso para calcular ingresos potenciales.
/// Encapsula la lógica de negocio de la calculadora de ingresos.
class CalculateIncomeUseCase {
  /// Precio por defecto que cobra el usuario por bot.
  static const double defaultPricePerBot = 50;

  /// Costo de mantenimiento por defecto por bot (costo variable).
  static const double defaultMaintenanceCost = 20;

  /// Costo fijo mensual de la fábrica.
  static const double fixedFactoryCost = 90;

  /// Calcula todos los valores de ingresos de una vez.
  /// Valida los datos de entrada y retorna el cálculo completo.
  /// Ganancia neta = ingresos - costo variable (por bot) - costo fijo (fábrica).
  IncomeCalculation execute({
    required int botCount,
    double pricePerBot = defaultPricePerBot,
    double maintenanceCost = defaultMaintenanceCost,
  }) {
    // Validación de negocio
    if (botCount < 0) {
      throw ArgumentError('La cantidad de bots no puede ser negativa');
    }

    if (pricePerBot < 0) {
      throw ArgumentError('El precio por bot no puede ser negativo');
    }

    if (maintenanceCost < 0) {
      throw ArgumentError('El costo de mantenimiento no puede ser negativo');
    }

    final monthlyRevenue = _calculateMonthlyRevenue(
      botCount: botCount,
      pricePerBot: pricePerBot,
    );

    final monthlyVariableCost = botCount * maintenanceCost;
    final monthlyFixedCost = fixedFactoryCost;
    final monthlyCost = monthlyVariableCost + monthlyFixedCost;
    final monthlyProfit = monthlyRevenue - monthlyCost;
    final yearlyProfit = monthlyProfit * 12;

    return IncomeCalculation(
      botCount: botCount,
      pricePerBot: pricePerBot,
      maintenanceCost: maintenanceCost,
      monthlyRevenue: monthlyRevenue,
      monthlyVariableCost: monthlyVariableCost,
      monthlyFixedCost: monthlyFixedCost,
      monthlyCost: monthlyCost,
      monthlyProfit: monthlyProfit,
      yearlyProfit: yearlyProfit,
    );
  }

  /// Calcula los ingresos mensuales.
  double _calculateMonthlyRevenue({
    required int botCount,
    required double pricePerBot,
  }) {
    return botCount * pricePerBot;
  }
}

/// Provider del caso de uso de calcular ingresos.
final calculateIncomeUseCaseProvider = Provider<CalculateIncomeUseCase>((ref) {
  return CalculateIncomeUseCase();
});

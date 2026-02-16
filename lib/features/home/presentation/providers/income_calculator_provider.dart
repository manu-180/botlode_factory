import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/use_cases/calculate_income_use_case.dart';
import '../../domain/entities/income_calculation.dart';

/// Estado de la calculadora de ingresos.
class IncomeCalculatorState {
  final int botCount;
  final double pricePerBot;
  final double maintenanceCost;
  final IncomeCalculation calculation;

  const IncomeCalculatorState({
    required this.botCount,
    required this.pricePerBot,
    required this.maintenanceCost,
    required this.calculation,
  });

  IncomeCalculatorState copyWith({
    int? botCount,
    double? pricePerBot,
    double? maintenanceCost,
    IncomeCalculation? calculation,
  }) {
    return IncomeCalculatorState(
      botCount: botCount ?? this.botCount,
      pricePerBot: pricePerBot ?? this.pricePerBot,
      maintenanceCost: maintenanceCost ?? this.maintenanceCost,
      calculation: calculation ?? this.calculation,
    );
  }
}

/// Notifier para gestionar el estado de la calculadora de ingresos.
/// Solo gestiona estado de UI y delega toda la lógica de negocio al use case.
class IncomeCalculatorNotifier extends StateNotifier<IncomeCalculatorState> {
  final CalculateIncomeUseCase _calculateIncomeUseCase;

  IncomeCalculatorNotifier(this._calculateIncomeUseCase)
      : super(
          IncomeCalculatorState(
            botCount: 10,
            pricePerBot: CalculateIncomeUseCase.defaultPricePerBot,
            maintenanceCost: CalculateIncomeUseCase.defaultMaintenanceCost,
            calculation: _calculateIncomeUseCase.execute(botCount: 10),
          ),
        );

  /// Actualiza la cantidad de bots y recalcula.
  void updateBotCount(int count) {
    final calculation = _calculateIncomeUseCase.execute(
      botCount: count,
      pricePerBot: state.pricePerBot,
      maintenanceCost: state.maintenanceCost,
    );
    state = state.copyWith(
      botCount: count,
      calculation: calculation,
    );
  }

  /// Actualiza el precio por bot y recalcula.
  void updatePricePerBot(double price) {
    final calculation = _calculateIncomeUseCase.execute(
      botCount: state.botCount,
      pricePerBot: price,
      maintenanceCost: state.maintenanceCost,
    );
    state = state.copyWith(
      pricePerBot: price,
      calculation: calculation,
    );
  }

  /// Actualiza el costo de mantenimiento y recalcula.
  void updateMaintenanceCost(double cost) {
    final calculation = _calculateIncomeUseCase.execute(
      botCount: state.botCount,
      pricePerBot: state.pricePerBot,
      maintenanceCost: cost,
    );
    state = state.copyWith(
      maintenanceCost: cost,
      calculation: calculation,
    );
  }
}

/// Provider del notifier de la calculadora de ingresos.
final incomeCalculatorProvider =
    StateNotifierProvider<IncomeCalculatorNotifier, IncomeCalculatorState>((ref) {
  final useCase = ref.watch(calculateIncomeUseCaseProvider);
  return IncomeCalculatorNotifier(useCase);
});

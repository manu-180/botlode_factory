/// Entidad que representa el resultado de un cálculo de ingresos.
/// Esta es una entidad de dominio pura sin dependencias externas.
class IncomeCalculation {
  final int botCount;
  final double pricePerBot;
  final double maintenanceCost;
  final double monthlyRevenue;
  /// Costo variable: mantenimiento por bot (ej. \$20 x N bots).
  final double monthlyVariableCost;
  /// Costo fijo: mantenimiento de la fábrica (ej. \$90/mes).
  final double monthlyFixedCost;
  /// Costo total = variable + fijo.
  final double monthlyCost;
  final double monthlyProfit;
  final double yearlyProfit;

  const IncomeCalculation({
    required this.botCount,
    required this.pricePerBot,
    required this.maintenanceCost,
    required this.monthlyRevenue,
    required this.monthlyVariableCost,
    required this.monthlyFixedCost,
    required this.monthlyCost,
    required this.monthlyProfit,
    required this.yearlyProfit,
  });

  /// Crea una copia con valores actualizados.
  IncomeCalculation copyWith({
    int? botCount,
    double? pricePerBot,
    double? maintenanceCost,
    double? monthlyRevenue,
    double? monthlyVariableCost,
    double? monthlyFixedCost,
    double? monthlyCost,
    double? monthlyProfit,
    double? yearlyProfit,
  }) {
    return IncomeCalculation(
      botCount: botCount ?? this.botCount,
      pricePerBot: pricePerBot ?? this.pricePerBot,
      maintenanceCost: maintenanceCost ?? this.maintenanceCost,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      monthlyVariableCost: monthlyVariableCost ?? this.monthlyVariableCost,
      monthlyFixedCost: monthlyFixedCost ?? this.monthlyFixedCost,
      monthlyCost: monthlyCost ?? this.monthlyCost,
      monthlyProfit: monthlyProfit ?? this.monthlyProfit,
      yearlyProfit: yearlyProfit ?? this.yearlyProfit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IncomeCalculation &&
        other.botCount == botCount &&
        other.pricePerBot == pricePerBot &&
        other.maintenanceCost == maintenanceCost &&
        other.monthlyRevenue == monthlyRevenue &&
        other.monthlyVariableCost == monthlyVariableCost &&
        other.monthlyFixedCost == monthlyFixedCost &&
        other.monthlyCost == monthlyCost &&
        other.monthlyProfit == monthlyProfit &&
        other.yearlyProfit == yearlyProfit;
  }

  @override
  int get hashCode {
    return Object.hash(
      botCount,
      pricePerBot,
      maintenanceCost,
      monthlyRevenue,
      monthlyVariableCost,
      monthlyFixedCost,
      monthlyCost,
      monthlyProfit,
      yearlyProfit,
    );
  }
}

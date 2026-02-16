/// Servicio para cálculos de ingresos potenciales.
/// Encapsula la lógica de negocio de la calculadora de ingresos.
/// Nota: La UI usa [CalculateIncomeUseCase] y la entidad de dominio; este servicio se mantiene por compatibilidad.
class IncomeCalculatorService {
  static const double defaultPricePerBot = 50;
  static const double defaultMaintenanceCost = 20;
  static const double fixedFactoryCost = 90;

  double calculateMonthlyRevenue({
    required int botCount,
    double pricePerBot = defaultPricePerBot,
  }) {
    return botCount * pricePerBot;
  }

  double calculateMonthlyVariableCost({
    required int botCount,
    double maintenanceCost = defaultMaintenanceCost,
  }) {
    return botCount * maintenanceCost;
  }

  double calculateMonthlyCost({
    required int botCount,
    double maintenanceCost = defaultMaintenanceCost,
  }) {
    return calculateMonthlyVariableCost(botCount: botCount, maintenanceCost: maintenanceCost) + fixedFactoryCost;
  }

  double calculateMonthlyProfit({
    required int botCount,
    double pricePerBot = defaultPricePerBot,
    double maintenanceCost = defaultMaintenanceCost,
  }) {
    final revenue = calculateMonthlyRevenue(botCount: botCount, pricePerBot: pricePerBot);
    final cost = calculateMonthlyCost(botCount: botCount, maintenanceCost: maintenanceCost);
    return revenue - cost;
  }

  double calculateYearlyProfit({
    required int botCount,
    double pricePerBot = defaultPricePerBot,
    double maintenanceCost = defaultMaintenanceCost,
  }) {
    return calculateMonthlyProfit(
      botCount: botCount,
      pricePerBot: pricePerBot,
      maintenanceCost: maintenanceCost,
    ) * 12;
  }

  IncomeCalculation calculate({
    required int botCount,
    double pricePerBot = defaultPricePerBot,
    double maintenanceCost = defaultMaintenanceCost,
  }) {
    final monthlyRevenue = calculateMonthlyRevenue(botCount: botCount, pricePerBot: pricePerBot);
    final monthlyVariableCost = calculateMonthlyVariableCost(botCount: botCount, maintenanceCost: maintenanceCost);
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
}

/// Resultado de un cálculo de ingresos (copia local; la canónica está en domain/entities).
class IncomeCalculation {
  final int botCount;
  final double pricePerBot;
  final double maintenanceCost;
  final double monthlyRevenue;
  final double monthlyVariableCost;
  final double monthlyFixedCost;
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
}

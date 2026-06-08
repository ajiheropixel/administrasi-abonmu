class DashboardSummary {
  final double totalProduction;
  final double totalSales;
  final double totalExpenses;
  final double netProfit;
  final int totalTransactions;
  final double averageSale;

  const DashboardSummary({
    required this.totalProduction,
    required this.totalSales,
    required this.totalExpenses,
    required this.netProfit,
    required this.totalTransactions,
    required this.averageSale,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      DashboardSummary(
        totalProduction:
            double.tryParse(json['total_production'].toString()) ?? 0,
        totalSales: double.tryParse(json['total_sales'].toString()) ?? 0,
        totalExpenses: double.tryParse(json['total_expenses'].toString()) ?? 0,
        netProfit: double.tryParse(json['net_profit'].toString()) ?? 0,
        totalTransactions: json['total_transactions'] as int? ?? 0,
        averageSale: double.tryParse(json['average_sale'].toString()) ?? 0,
      );
}

class TopProduct {
  final String name;
  final double totalSold;

  const TopProduct({required this.name, required this.totalSold});

  factory TopProduct.fromJson(Map<String, dynamic> json) => TopProduct(
        name: json['name'] as String,
        totalSold: double.tryParse(json['total_sold'].toString()) ?? 0,
      );
}

class ChartPoint {
  final String date;
  final double total;

  const ChartPoint({required this.date, required this.total});

  factory ChartPoint.fromJson(Map<String, dynamic> json) => ChartPoint(
        date: json['date'] as String,
        total: double.tryParse(json['total'].toString()) ?? 0,
      );
}

class MonthlyComparison {
  final String month;
  final double production;
  final double sales;
  final double expenses;
  final double profit;

  const MonthlyComparison({
    required this.month,
    required this.production,
    required this.sales,
    required this.expenses,
    required this.profit,
  });

  factory MonthlyComparison.fromJson(Map<String, dynamic> json) =>
      MonthlyComparison(
        month: json['month'] as String,
        production: double.tryParse(json['production'].toString()) ?? 0,
        sales: double.tryParse(json['sales'].toString()) ?? 0,
        expenses: double.tryParse(json['expenses'].toString()) ?? 0,
        profit: double.tryParse(json['profit'].toString()) ?? 0,
      );
}




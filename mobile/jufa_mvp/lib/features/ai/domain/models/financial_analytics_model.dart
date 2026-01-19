class FinancialAnalytics {
  final String userId;
  final DateTime analysisDate;
  final SpendingAnalysis spendingAnalysis;
  final SavingsAnalysis savingsAnalysis;
  final BudgetAnalysis budgetAnalysis;
  final List<FinancialInsight> insights;
  final List<Recommendation> recommendations;
  final FraudAnalysis fraudAnalysis;
  final CreditScore creditScore;

  const FinancialAnalytics({
    required this.userId,
    required this.analysisDate,
    required this.spendingAnalysis,
    required this.savingsAnalysis,
    required this.budgetAnalysis,
    required this.insights,
    required this.recommendations,
    required this.fraudAnalysis,
    required this.creditScore,
  });

  factory FinancialAnalytics.fromJson(Map<String, dynamic> json) {
    return FinancialAnalytics(
      userId: json['user_id'] ?? '',
      analysisDate: DateTime.parse(json['analysis_date'] ?? DateTime.now().toIso8601String()),
      spendingAnalysis: SpendingAnalysis.fromJson(json['spending_analysis'] ?? {}),
      savingsAnalysis: SavingsAnalysis.fromJson(json['savings_analysis'] ?? {}),
      budgetAnalysis: BudgetAnalysis.fromJson(json['budget_analysis'] ?? {}),
      insights: List<FinancialInsight>.from(
        json['insights']?.map((x) => FinancialInsight.fromJson(x)) ?? [],
      ),
      recommendations: List<Recommendation>.from(
        json['recommendations']?.map((x) => Recommendation.fromJson(x)) ?? [],
      ),
      fraudAnalysis: FraudAnalysis.fromJson(json['fraud_analysis'] ?? {}),
      creditScore: CreditScore.fromJson(json['credit_score'] ?? {}),
    );
  }
}

class SpendingAnalysis {
  final double totalSpending;
  final double averageDaily;
  final double averageMonthly;
  final Map<String, CategorySpending> categories;
  final List<SpendingTrend> trends;
  final double changeFromLastMonth;
  final double changePercentage;

  const SpendingAnalysis({
    required this.totalSpending,
    required this.averageDaily,
    required this.averageMonthly,
    required this.categories,
    required this.trends,
    required this.changeFromLastMonth,
    required this.changePercentage,
  });

  factory SpendingAnalysis.fromJson(Map<String, dynamic> json) {
    return SpendingAnalysis(
      totalSpending: (json['total_spending'] ?? 0.0).toDouble(),
      averageDaily: (json['average_daily'] ?? 0.0).toDouble(),
      averageMonthly: (json['average_monthly'] ?? 0.0).toDouble(),
      categories: Map<String, CategorySpending>.from(
        json['categories']?.map((k, v) => MapEntry(k, CategorySpending.fromJson(v))) ?? {},
      ),
      trends: List<SpendingTrend>.from(
        json['trends']?.map((x) => SpendingTrend.fromJson(x)) ?? [],
      ),
      changeFromLastMonth: (json['change_from_last_month'] ?? 0.0).toDouble(),
      changePercentage: (json['change_percentage'] ?? 0.0).toDouble(),
    );
  }

  bool get isSpendingUp => changePercentage > 0;
  String get trendDescription {
    if (changePercentage > 10) return 'Forte hausse';
    if (changePercentage > 0) return 'Légère hausse';
    if (changePercentage < -10) return 'Forte baisse';
    if (changePercentage < 0) return 'Légère baisse';
    return 'Stable';
  }
}

class CategorySpending {
  final String category;
  final double amount;
  final double percentage;
  final int transactionCount;
  final double averageTransaction;
  final double changeFromLastMonth;
  final List<String> topMerchants;

  const CategorySpending({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
    required this.averageTransaction,
    required this.changeFromLastMonth,
    required this.topMerchants,
  });

  factory CategorySpending.fromJson(Map<String, dynamic> json) {
    return CategorySpending(
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      transactionCount: json['transaction_count'] ?? 0,
      averageTransaction: (json['average_transaction'] ?? 0.0).toDouble(),
      changeFromLastMonth: (json['change_from_last_month'] ?? 0.0).toDouble(),
      topMerchants: List<String>.from(json['top_merchants'] ?? []),
    );
  }

  String get formattedAmount => '${amount.toStringAsFixed(0)} FCFA';
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';
}

class SpendingTrend {
  final DateTime date;
  final double amount;
  final String period; // daily, weekly, monthly

  const SpendingTrend({
    required this.date,
    required this.amount,
    required this.period,
  });

  factory SpendingTrend.fromJson(Map<String, dynamic> json) {
    return SpendingTrend(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      amount: (json['amount'] ?? 0.0).toDouble(),
      period: json['period'] ?? 'daily',
    );
  }
}

class SavingsAnalysis {
  final double totalSavings;
  final double monthlySavingsRate;
  final double savingsGoalProgress;
  final List<SavingsGoal> activeGoals;
  final double projectedSavings;
  final List<SavingsOpportunity> opportunities;

  const SavingsAnalysis({
    required this.totalSavings,
    required this.monthlySavingsRate,
    required this.savingsGoalProgress,
    required this.activeGoals,
    required this.projectedSavings,
    required this.opportunities,
  });

  factory SavingsAnalysis.fromJson(Map<String, dynamic> json) {
    return SavingsAnalysis(
      totalSavings: (json['total_savings'] ?? 0.0).toDouble(),
      monthlySavingsRate: (json['monthly_savings_rate'] ?? 0.0).toDouble(),
      savingsGoalProgress: (json['savings_goal_progress'] ?? 0.0).toDouble(),
      activeGoals: List<SavingsGoal>.from(
        json['active_goals']?.map((x) => SavingsGoal.fromJson(x)) ?? [],
      ),
      projectedSavings: (json['projected_savings'] ?? 0.0).toDouble(),
      opportunities: List<SavingsOpportunity>.from(
        json['opportunities']?.map((x) => SavingsOpportunity.fromJson(x)) ?? [],
      ),
    );
  }

  String get savingsRateText => '${(monthlySavingsRate * 100).toStringAsFixed(1)}%';
  String get goalProgressText => '${(savingsGoalProgress * 100).toStringAsFixed(0)}%';
}

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String category;
  final double monthlyContribution;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.category,
    required this.monthlyContribution,
  });

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      targetAmount: (json['target_amount'] ?? 0.0).toDouble(),
      currentAmount: (json['current_amount'] ?? 0.0).toDouble(),
      targetDate: DateTime.parse(json['target_date'] ?? DateTime.now().toIso8601String()),
      category: json['category'] ?? '',
      monthlyContribution: (json['monthly_contribution'] ?? 0.0).toDouble(),
    );
  }

  double get progress => currentAmount / targetAmount;
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;
  double get remainingAmount => targetAmount - currentAmount;
}

class SavingsOpportunity {
  final String id;
  final String title;
  final String description;
  final double potentialSavings;
  final OpportunityType type;
  final OpportunityPriority priority;
  final List<String> actionSteps;

  const SavingsOpportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.potentialSavings,
    required this.type,
    required this.priority,
    required this.actionSteps,
  });

  factory SavingsOpportunity.fromJson(Map<String, dynamic> json) {
    return SavingsOpportunity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      potentialSavings: (json['potential_savings'] ?? 0.0).toDouble(),
      type: OpportunityType.values.firstWhere(
        (type) => type.value == json['type'],
        orElse: () => OpportunityType.spending,
      ),
      priority: OpportunityPriority.values.firstWhere(
        (priority) => priority.value == json['priority'],
        orElse: () => OpportunityPriority.medium,
      ),
      actionSteps: List<String>.from(json['action_steps'] ?? []),
    );
  }
}

enum OpportunityType {
  spending('spending', 'Réduction dépenses'),
  investment('investment', 'Investissement'),
  automation('automation', 'Automatisation'),
  optimization('optimization', 'Optimisation');

  const OpportunityType(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum OpportunityPriority {
  high('high', 'Haute', '🔴'),
  medium('medium', 'Moyenne', '🟡'),
  low('low', 'Faible', '🟢');

  const OpportunityPriority(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}

class BudgetAnalysis {
  final Map<String, BudgetCategory> categories;
  final double totalBudget;
  final double totalSpent;
  final double remainingBudget;
  final List<BudgetAlert> alerts;
  final BudgetPerformance performance;

  const BudgetAnalysis({
    required this.categories,
    required this.totalBudget,
    required this.totalSpent,
    required this.remainingBudget,
    required this.alerts,
    required this.performance,
  });

  factory BudgetAnalysis.fromJson(Map<String, dynamic> json) {
    return BudgetAnalysis(
      categories: Map<String, BudgetCategory>.from(
        json['categories']?.map((k, v) => MapEntry(k, BudgetCategory.fromJson(v))) ?? {},
      ),
      totalBudget: (json['total_budget'] ?? 0.0).toDouble(),
      totalSpent: (json['total_spent'] ?? 0.0).toDouble(),
      remainingBudget: (json['remaining_budget'] ?? 0.0).toDouble(),
      alerts: List<BudgetAlert>.from(
        json['alerts']?.map((x) => BudgetAlert.fromJson(x)) ?? [],
      ),
      performance: BudgetPerformance.fromJson(json['performance'] ?? {}),
    );
  }

  double get budgetUtilization => totalSpent / totalBudget;
  bool get isOverBudget => totalSpent > totalBudget;
}

class BudgetCategory {
  final String name;
  final double budgetAmount;
  final double spentAmount;
  final double remainingAmount;
  final double utilizationPercentage;
  final BudgetStatus status;

  const BudgetCategory({
    required this.name,
    required this.budgetAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.utilizationPercentage,
    required this.status,
  });

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      name: json['name'] ?? '',
      budgetAmount: (json['budget_amount'] ?? 0.0).toDouble(),
      spentAmount: (json['spent_amount'] ?? 0.0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0.0).toDouble(),
      utilizationPercentage: (json['utilization_percentage'] ?? 0.0).toDouble(),
      status: BudgetStatus.values.firstWhere(
        (status) => status.value == json['status'],
        orElse: () => BudgetStatus.onTrack,
      ),
    );
  }
}

enum BudgetStatus {
  onTrack('on_track', 'Sur la bonne voie', '🟢'),
  warning('warning', 'Attention', '🟡'),
  exceeded('exceeded', 'Dépassé', '🔴');

  const BudgetStatus(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}

class BudgetAlert {
  final String id;
  final String category;
  final AlertType type;
  final String message;
  final AlertSeverity severity;
  final DateTime createdAt;

  const BudgetAlert({
    required this.id,
    required this.category,
    required this.type,
    required this.message,
    required this.severity,
    required this.createdAt,
  });

  factory BudgetAlert.fromJson(Map<String, dynamic> json) {
    return BudgetAlert(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      type: AlertType.values.firstWhere(
        (type) => type.value == json['type'],
        orElse: () => AlertType.budgetExceeded,
      ),
      message: json['message'] ?? '',
      severity: AlertSeverity.values.firstWhere(
        (severity) => severity.value == json['severity'],
        orElse: () => AlertSeverity.medium,
      ),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum AlertType {
  budgetExceeded('budget_exceeded', 'Budget dépassé'),
  approachingLimit('approaching_limit', 'Limite approchée'),
  unusualSpending('unusual_spending', 'Dépense inhabituelle'),
  savingsGoalRisk('savings_goal_risk', 'Objectif d\'épargne en danger');

  const AlertType(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum AlertSeverity {
  low('low', 'Faible', '🟢'),
  medium('medium', 'Moyenne', '🟡'),
  high('high', 'Élevée', '🔴'),
  critical('critical', 'Critique', '🚨');

  const AlertSeverity(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}

class BudgetPerformance {
  final double accuracyScore;
  final int daysOnTrack;
  final int totalDays;
  final List<String> achievements;
  final List<String> improvements;

  const BudgetPerformance({
    required this.accuracyScore,
    required this.daysOnTrack,
    required this.totalDays,
    required this.achievements,
    required this.improvements,
  });

  factory BudgetPerformance.fromJson(Map<String, dynamic> json) {
    return BudgetPerformance(
      accuracyScore: (json['accuracy_score'] ?? 0.0).toDouble(),
      daysOnTrack: json['days_on_track'] ?? 0,
      totalDays: json['total_days'] ?? 0,
      achievements: List<String>.from(json['achievements'] ?? []),
      improvements: List<String>.from(json['improvements'] ?? []),
    );
  }

  double get trackingPercentage => daysOnTrack / totalDays;
  String get performanceGrade {
    if (accuracyScore >= 0.9) return 'A+';
    if (accuracyScore >= 0.8) return 'A';
    if (accuracyScore >= 0.7) return 'B';
    if (accuracyScore >= 0.6) return 'C';
    return 'D';
  }
}

class FinancialInsight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final InsightCategory category;
  final double impact;
  final DateTime generatedAt;
  final Map<String, dynamic> data;

  const FinancialInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.impact,
    required this.generatedAt,
    required this.data,
  });

  factory FinancialInsight.fromJson(Map<String, dynamic> json) {
    return FinancialInsight(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: InsightType.values.firstWhere(
        (type) => type.value == json['type'],
        orElse: () => InsightType.trend,
      ),
      category: InsightCategory.values.firstWhere(
        (category) => category.value == json['category'],
        orElse: () => InsightCategory.spending,
      ),
      impact: (json['impact'] ?? 0.0).toDouble(),
      generatedAt: DateTime.parse(json['generated_at'] ?? DateTime.now().toIso8601String()),
      data: json['data'] ?? {},
    );
  }
}

enum InsightType {
  trend('trend', 'Tendance'),
  anomaly('anomaly', 'Anomalie'),
  opportunity('opportunity', 'Opportunité'),
  warning('warning', 'Alerte'),
  achievement('achievement', 'Réussite');

  const InsightType(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum InsightCategory {
  spending('spending', 'Dépenses'),
  savings('savings', 'Épargne'),
  investment('investment', 'Investissement'),
  budget('budget', 'Budget'),
  security('security', 'Sécurité');

  const InsightCategory(this.value, this.displayName);
  final String value;
  final String displayName;
}

class Recommendation {
  final String id;
  final String title;
  final String description;
  final RecommendationType type;
  final RecommendationPriority priority;
  final double potentialBenefit;
  final List<String> actionSteps;
  final DateTime createdAt;
  final bool isImplemented;

  const Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.potentialBenefit,
    required this.actionSteps,
    required this.createdAt,
    required this.isImplemented,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: RecommendationType.values.firstWhere(
        (type) => type.value == json['type'],
        orElse: () => RecommendationType.savings,
      ),
      priority: RecommendationPriority.values.firstWhere(
        (priority) => priority.value == json['priority'],
        orElse: () => RecommendationPriority.medium,
      ),
      potentialBenefit: (json['potential_benefit'] ?? 0.0).toDouble(),
      actionSteps: List<String>.from(json['action_steps'] ?? []),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      isImplemented: json['is_implemented'] ?? false,
    );
  }
}

enum RecommendationType {
  savings('savings', 'Épargne'),
  investment('investment', 'Investissement'),
  budgetOptimization('budget_optimization', 'Optimisation budget'),
  debtReduction('debt_reduction', 'Réduction dette'),
  securityImprovement('security_improvement', 'Amélioration sécurité');

  const RecommendationType(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum RecommendationPriority {
  high('high', 'Haute', '🔴'),
  medium('medium', 'Moyenne', '🟡'),
  low('low', 'Faible', '🟢');

  const RecommendationPriority(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}

class FraudAnalysis {
  final FraudRiskLevel riskLevel;
  final double riskScore;
  final List<FraudAlert> alerts;
  final List<SuspiciousActivity> suspiciousActivities;
  final SecurityRecommendation securityRecommendation;

  const FraudAnalysis({
    required this.riskLevel,
    required this.riskScore,
    required this.alerts,
    required this.suspiciousActivities,
    required this.securityRecommendation,
  });

  factory FraudAnalysis.fromJson(Map<String, dynamic> json) {
    return FraudAnalysis(
      riskLevel: FraudRiskLevel.values.firstWhere(
        (level) => level.value == json['risk_level'],
        orElse: () => FraudRiskLevel.low,
      ),
      riskScore: (json['risk_score'] ?? 0.0).toDouble(),
      alerts: List<FraudAlert>.from(
        json['alerts']?.map((x) => FraudAlert.fromJson(x)) ?? [],
      ),
      suspiciousActivities: List<SuspiciousActivity>.from(
        json['suspicious_activities']?.map((x) => SuspiciousActivity.fromJson(x)) ?? [],
      ),
      securityRecommendation: SecurityRecommendation.fromJson(json['security_recommendation'] ?? {}),
    );
  }
}

enum FraudRiskLevel {
  low('low', 'Faible', '🟢'),
  medium('medium', 'Moyen', '🟡'),
  high('high', 'Élevé', '🔴'),
  critical('critical', 'Critique', '🚨');

  const FraudRiskLevel(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}

class FraudAlert {
  final String id;
  final String title;
  final String description;
  final FraudAlertType type;
  final DateTime detectedAt;
  final bool isResolved;

  const FraudAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.detectedAt,
    required this.isResolved,
  });

  factory FraudAlert.fromJson(Map<String, dynamic> json) {
    return FraudAlert(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: FraudAlertType.values.firstWhere(
        (type) => type.value == json['type'],
        orElse: () => FraudAlertType.unusualTransaction,
      ),
      detectedAt: DateTime.parse(json['detected_at'] ?? DateTime.now().toIso8601String()),
      isResolved: json['is_resolved'] ?? false,
    );
  }
}

enum FraudAlertType {
  unusualTransaction('unusual_transaction', 'Transaction inhabituelle'),
  suspiciousLocation('suspicious_location', 'Localisation suspecte'),
  multipleFailedAttempts('multiple_failed_attempts', 'Tentatives échouées multiples'),
  deviceChange('device_change', 'Changement d\'appareil'),
  timeAnomaly('time_anomaly', 'Anomalie temporelle');

  const FraudAlertType(this.value, this.displayName);
  final String value;
  final String displayName;
}

class SuspiciousActivity {
  final String id;
  final String description;
  final DateTime timestamp;
  final double riskScore;
  final Map<String, dynamic> details;

  const SuspiciousActivity({
    required this.id,
    required this.description,
    required this.timestamp,
    required this.riskScore,
    required this.details,
  });

  factory SuspiciousActivity.fromJson(Map<String, dynamic> json) {
    return SuspiciousActivity(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      riskScore: (json['risk_score'] ?? 0.0).toDouble(),
      details: json['details'] ?? {},
    );
  }
}

class SecurityRecommendation {
  final List<String> recommendations;
  final SecurityLevel currentLevel;
  final SecurityLevel recommendedLevel;
  final List<String> actionItems;

  const SecurityRecommendation({
    required this.recommendations,
    required this.currentLevel,
    required this.recommendedLevel,
    required this.actionItems,
  });

  factory SecurityRecommendation.fromJson(Map<String, dynamic> json) {
    return SecurityRecommendation(
      recommendations: List<String>.from(json['recommendations'] ?? []),
      currentLevel: SecurityLevel.values.firstWhere(
        (level) => level.value == json['current_level'],
        orElse: () => SecurityLevel.basic,
      ),
      recommendedLevel: SecurityLevel.values.firstWhere(
        (level) => level.value == json['recommended_level'],
        orElse: () => SecurityLevel.enhanced,
      ),
      actionItems: List<String>.from(json['action_items'] ?? []),
    );
  }
}

enum SecurityLevel {
  basic('basic', 'Basique'),
  enhanced('enhanced', 'Renforcée'),
  premium('premium', 'Premium');

  const SecurityLevel(this.value, this.displayName);
  final String value;
  final String displayName;
}

class CreditScore {
  final int score;
  final CreditRating rating;
  final List<CreditFactor> factors;
  final List<String> improvementTips;
  final DateTime lastUpdated;

  const CreditScore({
    required this.score,
    required this.rating,
    required this.factors,
    required this.improvementTips,
    required this.lastUpdated,
  });

  factory CreditScore.fromJson(Map<String, dynamic> json) {
    return CreditScore(
      score: json['score'] ?? 0,
      rating: CreditRating.values.firstWhere(
        (rating) => rating.value == json['rating'],
        orElse: () => CreditRating.fair,
      ),
      factors: List<CreditFactor>.from(
        json['factors']?.map((x) => CreditFactor.fromJson(x)) ?? [],
      ),
      improvementTips: List<String>.from(json['improvement_tips'] ?? []),
      lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum CreditRating {
  excellent('excellent', 'Excellent', '🌟'),
  veryGood('very_good', 'Très bon', '⭐'),
  good('good', 'Bon', '✨'),
  fair('fair', 'Correct', '⚡'),
  poor('poor', 'Faible', '⚠️');

  const CreditRating(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}

class CreditFactor {
  final String name;
  final double impact;
  final CreditFactorType type;
  final String description;

  const CreditFactor({
    required this.name,
    required this.impact,
    required this.type,
    required this.description,
  });

  factory CreditFactor.fromJson(Map<String, dynamic> json) {
    return CreditFactor(
      name: json['name'] ?? '',
      impact: (json['impact'] ?? 0.0).toDouble(),
      type: CreditFactorType.values.firstWhere(
        (type) => type.value == json['type'],
        orElse: () => CreditFactorType.neutral,
      ),
      description: json['description'] ?? '',
    );
  }
}

enum CreditFactorType {
  positive('positive', 'Positif', '✅'),
  negative('negative', 'Négatif', '❌'),
  neutral('neutral', 'Neutre', '➖');

  const CreditFactorType(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}

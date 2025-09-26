class AlgorithmConfig {
  AlgorithmConfig({
    required this.version,
    required this.updatedAt,
    required this.powerPlus,
    required this.categories,
    required this.dailyCaps,
  });

  final String version;
  final DateTime updatedAt;
  final PowerPlusConfig powerPlus;
  final Map<String, CategoryConfig> categories;
  final DailyCaps dailyCaps;

  CategoryConfig? category(String id) => categories[id];

  Map<String, dynamic> toJson() => {
        'version': version,
        'updatedAt': updatedAt.toIso8601String(),
        'powerPlus': powerPlus.toJson(),
        'categories': categories.map((key, value) => MapEntry(key, value.toJson())),
        'dailyCaps': dailyCaps.toJson(),
      };

  factory AlgorithmConfig.fromJson(Map<String, dynamic> json) {
    return AlgorithmConfig(
      version: json['version'] as String? ?? '0.0.0',
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      powerPlus: PowerPlusConfig.fromJson(json['powerPlus'] as Map<String, dynamic>? ?? const {}),
      categories: (json['categories'] as Map<String, dynamic>? ?? const {}).map(
        (key, value) => MapEntry(key, CategoryConfig.fromJson(value as Map<String, dynamic>? ?? const {})),
      ),
      dailyCaps: DailyCaps.fromJson(json['dailyCaps'] as Map<String, dynamic>? ?? const {}),
    );
  }
}

class PowerPlusConfig {
  PowerPlusConfig({
    required this.bonusMinutes,
    required this.requiredGoals,
    required this.goals,
  });

  final int bonusMinutes;
  final int requiredGoals;
  final Map<String, int> goals; // minutes per category threshold

  Map<String, dynamic> toJson() => {
        'bonusMinutes': bonusMinutes,
        'requiredGoals': requiredGoals,
        'goals': goals,
      };

  factory PowerPlusConfig.fromJson(Map<String, dynamic> json) {
    return PowerPlusConfig(
      bonusMinutes: (json['bonusMinutes'] as num?)?.toInt() ?? 30,
      requiredGoals: (json['requiredGoals'] as num?)?.toInt() ?? 3,
      goals: (json['goals'] as Map<String, dynamic>? ?? const {}).map(
        (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
      ),
    );
  }
}

class CategoryConfig {
  CategoryConfig({
    required this.label,
    required this.minutesPerHour,
    required this.maxMinutes,
    this.penalties,
  });

  final String label;
  final int minutesPerHour; // earned screen time per hour of activity
  final int maxMinutes; // permitted minutes logged per day for the habit
  final PenaltyConfig? penalties;

  Map<String, dynamic> toJson() => {
        'label': label,
        'minutesPerHour': minutesPerHour,
        'maxMinutes': maxMinutes,
        if (penalties != null) 'penalties': penalties!.toJson(),
      };

  factory CategoryConfig.fromJson(Map<String, dynamic> json) {
    return CategoryConfig(
      label: json['label'] as String? ?? 'Unknown',
      minutesPerHour: (json['minutesPerHour'] as num?)?.toInt() ?? 0,
      maxMinutes: (json['maxMinutes'] as num?)?.toInt() ?? 0,
      penalties: json['penalties'] != null
          ? PenaltyConfig.fromJson(json['penalties'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PenaltyConfig {
  PenaltyConfig({
    required this.underMinutes,
    required this.overMinutes,
    required this.penaltyMinutes,
  });

  final int underMinutes; // below this threshold, penalty applies
  final int overMinutes; // above this threshold, penalty applies
  final int penaltyMinutes; // penalty deduction in minutes

  Map<String, dynamic> toJson() => {
        'underMinutes': underMinutes,
        'overMinutes': overMinutes,
        'penaltyMinutes': penaltyMinutes,
      };

  factory PenaltyConfig.fromJson(Map<String, dynamic> json) {
    return PenaltyConfig(
      underMinutes: (json['underMinutes'] as num?)?.toInt() ?? 0,
      overMinutes: (json['overMinutes'] as num?)?.toInt() ?? 0,
      penaltyMinutes: (json['penaltyMinutes'] as num?)?.toInt() ?? 0,
    );
  }
}

class DailyCaps {
  DailyCaps({
    required this.baseMinutes,
    required this.powerPlusMinutes,
  });

  final int baseMinutes;
  final int powerPlusMinutes;

  Map<String, dynamic> toJson() => {
        'baseMinutes': baseMinutes,
        'powerPlusMinutes': powerPlusMinutes,
      };

  factory DailyCaps.fromJson(Map<String, dynamic> json) {
    return DailyCaps(
      baseMinutes: (json['baseMinutes'] as num?)?.toInt() ?? 120,
      powerPlusMinutes: (json['powerPlusMinutes'] as num?)?.toInt() ?? 150,
    );
  }
}

class AlgorithmValidationError implements Exception {
  AlgorithmValidationError(this.message);
  final String message;

  @override
  String toString() => 'AlgorithmValidationError: $message';
}

class AlgorithmConfigValidator {
  const AlgorithmConfigValidator();

  void validate(AlgorithmConfig config) {
    if (config.version.isEmpty) {
      throw AlgorithmValidationError('Algorithm version must not be empty.');
    }

    if (config.categories.isEmpty) {
      throw AlgorithmValidationError('Algorithm config must define at least one category.');
    }

    for (final entry in config.categories.entries) {
      final category = entry.value;
      if (category.minutesPerHour <= 0) {
        throw AlgorithmValidationError('Category "${entry.key}" must define positive minutesPerHour.');
      }
      if (category.maxMinutes <= 0) {
        throw AlgorithmValidationError('Category "${entry.key}" must define positive maxMinutes.');
      }
      final penalty = category.penalties;
      if (penalty != null) {
        if (penalty.penaltyMinutes <= 0) {
          throw AlgorithmValidationError(
            'Penalty for "${entry.key}" must define positive penaltyMinutes.',
          );
        }
      }
    }

    if (config.dailyCaps.baseMinutes <= 0) {
      throw AlgorithmValidationError('Daily cap must be positive.');
    }
    if (config.dailyCaps.powerPlusMinutes < config.dailyCaps.baseMinutes) {
      throw AlgorithmValidationError('POWER+ cap cannot be less than base cap.');
    }
  }
}

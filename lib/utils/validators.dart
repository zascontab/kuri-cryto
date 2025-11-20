/// Utilidades de validación para la aplicación
///
/// Este archivo contiene funciones de validación para campos de entrada,
/// precios, cantidades, rangos, y datos de trading.
///
/// Ejemplos de uso:
/// ```dart
/// final priceValidation = validatePrice(100.50);
/// if (!priceValidation.isValid) {
///   print(priceValidation.error); // "Price must be greater than 0"
/// }
///
/// final emailValidation = validateEmail('user@example.com');
/// if (emailValidation.isValid) {
///   print('Valid email!');
/// }
/// ```
library;

/// Resultado de una validación
class ValidationResult {
  /// Si la validación fue exitosa
  final bool isValid;

  /// Mensaje de error si la validación falló
  final String? error;

  const ValidationResult({
    required this.isValid,
    this.error,
  });

  /// Crea un resultado de validación exitoso
  factory ValidationResult.success() {
    return const ValidationResult(isValid: true);
  }

  /// Crea un resultado de validación fallido
  factory ValidationResult.failure(String error) {
    return ValidationResult(isValid: false, error: error);
  }

  @override
  String toString() {
    return isValid ? 'Valid' : 'Invalid: $error';
  }
}

// ============================================================================
// Validaciones de Precios y Cantidades
// ============================================================================

/// Valida que un precio sea mayor que 0
///
/// [price]: Precio a validar
/// [allowZero]: Si permite 0 como valor válido (por defecto false)
/// [minValue]: Valor mínimo permitido (opcional)
/// [maxValue]: Valor máximo permitido (opcional)
///
/// Ejemplo:
/// ```dart
/// validatePrice(100.50); // Valid
/// validatePrice(0); // Invalid: "Price must be greater than 0"
/// validatePrice(0, allowZero: true); // Valid
/// validatePrice(150, maxValue: 100); // Invalid: "Price must not exceed 100.00"
/// ```
ValidationResult validatePrice(
  double? price, {
  bool allowZero = false,
  double? minValue,
  double? maxValue,
}) {
  if (price == null) {
    return ValidationResult.failure('Price is required');
  }

  final effectiveMin = minValue ?? (allowZero ? 0.0 : 0.0);

  if (!allowZero && price <= 0) {
    return ValidationResult.failure('Price must be greater than 0');
  }

  if (allowZero && price < 0) {
    return ValidationResult.failure('Price cannot be negative');
  }

  if (minValue != null && price < minValue) {
    return ValidationResult.failure(
      'Price must be at least ${minValue.toStringAsFixed(2)}',
    );
  }

  if (maxValue != null && price > maxValue) {
    return ValidationResult.failure(
      'Price must not exceed ${maxValue.toStringAsFixed(2)}',
    );
  }

  return ValidationResult.success();
}

/// Valida que una cantidad sea mayor que 0
///
/// [amount]: Cantidad a validar
/// [minValue]: Valor mínimo permitido (por defecto 0)
/// [maxValue]: Valor máximo permitido (opcional)
/// [fieldName]: Nombre del campo para mensajes de error (por defecto 'Amount')
///
/// Ejemplo:
/// ```dart
/// validateAmount(10.5); // Valid
/// validateAmount(0); // Invalid: "Amount must be greater than 0"
/// validateAmount(5, minValue: 10); // Invalid: "Amount must be at least 10.00"
/// validateAmount(150, maxValue: 100); // Invalid: "Amount must not exceed 100.00"
/// ```
ValidationResult validateAmount(
  double? amount, {
  double minValue = 0.0,
  double? maxValue,
  String fieldName = 'Amount',
}) {
  if (amount == null) {
    return ValidationResult.failure('$fieldName is required');
  }

  if (amount <= minValue) {
    if (minValue == 0.0) {
      return ValidationResult.failure('$fieldName must be greater than 0');
    } else {
      return ValidationResult.failure(
        '$fieldName must be at least ${minValue.toStringAsFixed(2)}',
      );
    }
  }

  if (maxValue != null && amount > maxValue) {
    return ValidationResult.failure(
      '$fieldName must not exceed ${maxValue.toStringAsFixed(2)}',
    );
  }

  return ValidationResult.success();
}

/// Valida que una cantidad esté disponible (suficiente balance)
///
/// [requested]: Cantidad solicitada
/// [available]: Cantidad disponible
/// [fieldName]: Nombre del campo para mensajes de error (por defecto 'Amount')
///
/// Ejemplo:
/// ```dart
/// validateAvailableAmount(100, 500); // Valid
/// validateAvailableAmount(600, 500); // Invalid: "Insufficient balance. Available: 500.00"
/// ```
ValidationResult validateAvailableAmount(
  double? requested,
  double available, {
  String fieldName = 'Amount',
}) {
  if (requested == null) {
    return ValidationResult.failure('$fieldName is required');
  }

  if (requested <= 0) {
    return ValidationResult.failure('$fieldName must be greater than 0');
  }

  if (requested > available) {
    return ValidationResult.failure(
      'Insufficient balance. Available: ${available.toStringAsFixed(2)}',
    );
  }

  return ValidationResult.success();
}

// ============================================================================
// Validaciones de Porcentajes
// ============================================================================

/// Valida que un valor esté en el rango de porcentaje válido (0-100)
///
/// [value]: Valor a validar
/// [min]: Valor mínimo permitido (por defecto 0)
/// [max]: Valor máximo permitido (por defecto 100)
/// [fieldName]: Nombre del campo para mensajes de error (por defecto 'Percentage')
///
/// Ejemplo:
/// ```dart
/// validatePercentage(50); // Valid
/// validatePercentage(-10); // Invalid: "Percentage must be between 0 and 100"
/// validatePercentage(150); // Invalid: "Percentage must be between 0 and 100"
/// validatePercentage(5, min: 10); // Invalid: "Percentage must be between 10 and 100"
/// ```
ValidationResult validatePercentage(
  double? value, {
  double min = 0.0,
  double max = 100.0,
  String fieldName = 'Percentage',
}) {
  if (value == null) {
    return ValidationResult.failure('$fieldName is required');
  }

  if (value < min || value > max) {
    return ValidationResult.failure(
      '$fieldName must be between ${min.toStringAsFixed(0)} and ${max.toStringAsFixed(0)}',
    );
  }

  return ValidationResult.success();
}

// ============================================================================
// Validaciones de Trading
// ============================================================================

/// Valida un precio de Stop Loss
///
/// [stopLoss]: Precio de stop loss
/// [entryPrice]: Precio de entrada
/// [side]: Lado de la posición ('long' o 'short')
/// [maxDistancePercent]: Distancia máxima permitida en porcentaje (opcional)
///
/// Para LONG: SL debe ser menor que entry
/// Para SHORT: SL debe ser mayor que entry
///
/// Ejemplo:
/// ```dart
/// validateStopLoss(95, 100, 'long'); // Valid (SL < entry)
/// validateStopLoss(105, 100, 'long'); // Invalid: "Stop loss must be below entry price for long positions"
/// validateStopLoss(105, 100, 'short'); // Valid (SL > entry)
/// ```
ValidationResult validateStopLoss(
  double? stopLoss,
  double entryPrice,
  String side, {
  double? maxDistancePercent,
}) {
  if (stopLoss == null) {
    return ValidationResult.failure('Stop loss is required');
  }

  if (stopLoss <= 0) {
    return ValidationResult.failure('Stop loss must be greater than 0');
  }

  final isLong = side.toLowerCase() == 'long';

  // Validar dirección según el tipo de posición
  if (isLong && stopLoss >= entryPrice) {
    return ValidationResult.failure(
      'Stop loss must be below entry price for long positions',
    );
  }

  if (!isLong && stopLoss <= entryPrice) {
    return ValidationResult.failure(
      'Stop loss must be above entry price for short positions',
    );
  }

  // Validar distancia máxima si se especifica
  if (maxDistancePercent != null) {
    final distance = ((stopLoss - entryPrice).abs() / entryPrice) * 100;

    if (distance > maxDistancePercent) {
      return ValidationResult.failure(
        'Stop loss is too far from entry (max ${maxDistancePercent.toStringAsFixed(0)}%)',
      );
    }
  }

  return ValidationResult.success();
}

/// Valida un precio de Take Profit
///
/// [takeProfit]: Precio de take profit
/// [entryPrice]: Precio de entrada
/// [side]: Lado de la posición ('long' o 'short')
/// [minDistancePercent]: Distancia mínima requerida en porcentaje (opcional)
///
/// Para LONG: TP debe ser mayor que entry
/// Para SHORT: TP debe ser menor que entry
///
/// Ejemplo:
/// ```dart
/// validateTakeProfit(110, 100, 'long'); // Valid (TP > entry)
/// validateTakeProfit(95, 100, 'long'); // Invalid: "Take profit must be above entry price for long positions"
/// validateTakeProfit(95, 100, 'short'); // Valid (TP < entry)
/// ```
ValidationResult validateTakeProfit(
  double? takeProfit,
  double entryPrice,
  String side, {
  double? minDistancePercent,
}) {
  if (takeProfit == null) {
    return ValidationResult.failure('Take profit is required');
  }

  if (takeProfit <= 0) {
    return ValidationResult.failure('Take profit must be greater than 0');
  }

  final isLong = side.toLowerCase() == 'long';

  // Validar dirección según el tipo de posición
  if (isLong && takeProfit <= entryPrice) {
    return ValidationResult.failure(
      'Take profit must be above entry price for long positions',
    );
  }

  if (!isLong && takeProfit >= entryPrice) {
    return ValidationResult.failure(
      'Take profit must be below entry price for short positions',
    );
  }

  // Validar distancia mínima si se especifica
  if (minDistancePercent != null) {
    final distance = ((takeProfit - entryPrice).abs() / entryPrice) * 100;

    if (distance < minDistancePercent) {
      return ValidationResult.failure(
        'Take profit must be at least ${minDistancePercent.toStringAsFixed(0)}% from entry',
      );
    }
  }

  return ValidationResult.success();
}

/// Valida que el ratio Risk/Reward sea aceptable
///
/// [stopLoss]: Precio de stop loss
/// [takeProfit]: Precio de take profit
/// [entryPrice]: Precio de entrada
/// [side]: Lado de la posición ('long' o 'short')
/// [minRatio]: Ratio mínimo aceptable (por defecto 1.5, es decir 1:1.5)
///
/// Ejemplo:
/// ```dart
/// // LONG: entry=100, SL=95, TP=110
/// // Risk=5, Reward=10, Ratio=2.0
/// validateRiskReward(95, 110, 100, 'long', minRatio: 1.5); // Valid (2.0 > 1.5)
/// ```
ValidationResult validateRiskReward(
  double? stopLoss,
  double? takeProfit,
  double entryPrice,
  String side, {
  double minRatio = 1.5,
}) {
  if (stopLoss == null || takeProfit == null) {
    return ValidationResult.failure('Stop loss and take profit are required');
  }

  final isLong = side.toLowerCase() == 'long';

  final risk = (entryPrice - stopLoss).abs();
  final reward = (takeProfit - entryPrice).abs();

  if (risk == 0) {
    return ValidationResult.failure('Risk cannot be zero');
  }

  final ratio = reward / risk;

  if (ratio < minRatio) {
    return ValidationResult.failure(
      'Risk/Reward ratio (${ratio.toStringAsFixed(2)}) must be at least ${minRatio.toStringAsFixed(2)}',
    );
  }

  return ValidationResult.success();
}

/// Valida un apalancamiento (leverage)
///
/// [leverage]: Apalancamiento a validar
/// [minLeverage]: Apalancamiento mínimo (por defecto 1)
/// [maxLeverage]: Apalancamiento máximo (por defecto 125)
///
/// Ejemplo:
/// ```dart
/// validateLeverage(10); // Valid
/// validateLeverage(0); // Invalid: "Leverage must be between 1 and 125"
/// validateLeverage(200); // Invalid: "Leverage must be between 1 and 125"
/// ```
ValidationResult validateLeverage(
  double? leverage, {
  double minLeverage = 1.0,
  double maxLeverage = 125.0,
}) {
  if (leverage == null) {
    return ValidationResult.failure('Leverage is required');
  }

  if (leverage < minLeverage || leverage > maxLeverage) {
    return ValidationResult.failure(
      'Leverage must be between ${minLeverage.toStringAsFixed(0)} and ${maxLeverage.toStringAsFixed(0)}',
    );
  }

  return ValidationResult.success();
}

// ============================================================================
// Validaciones de Fechas
// ============================================================================

/// Valida un rango de fechas
///
/// [from]: Fecha inicial
/// [to]: Fecha final
/// [maxRangeDays]: Número máximo de días permitidos en el rango (opcional)
/// [allowFuture]: Si permite fechas futuras (por defecto false)
///
/// Ejemplo:
/// ```dart
/// validateDateRange(
///   DateTime(2025, 1, 1),
///   DateTime(2025, 1, 31),
/// ); // Valid
///
/// validateDateRange(
///   DateTime(2025, 1, 31),
///   DateTime(2025, 1, 1),
/// ); // Invalid: "End date must be after start date"
/// ```
ValidationResult validateDateRange(
  DateTime? from,
  DateTime? to, {
  int? maxRangeDays,
  bool allowFuture = false,
}) {
  if (from == null) {
    return ValidationResult.failure('Start date is required');
  }

  if (to == null) {
    return ValidationResult.failure('End date is required');
  }

  // Validar que la fecha final sea después de la inicial
  if (to.isBefore(from)) {
    return ValidationResult.failure('End date must be after start date');
  }

  // Validar fechas futuras si no están permitidas
  if (!allowFuture) {
    final now = DateTime.now();

    if (from.isAfter(now)) {
      return ValidationResult.failure('Start date cannot be in the future');
    }

    if (to.isAfter(now)) {
      return ValidationResult.failure('End date cannot be in the future');
    }
  }

  // Validar rango máximo si se especifica
  if (maxRangeDays != null) {
    final rangeDays = to.difference(from).inDays;

    if (rangeDays > maxRangeDays) {
      return ValidationResult.failure(
        'Date range must not exceed $maxRangeDays days',
      );
    }
  }

  return ValidationResult.success();
}

/// Valida que una fecha no sea futura
///
/// [date]: Fecha a validar
/// [fieldName]: Nombre del campo para mensajes de error (por defecto 'Date')
///
/// Ejemplo:
/// ```dart
/// validateNotFuture(DateTime.now()); // Valid
/// validateNotFuture(DateTime.now().add(Duration(days: 1))); // Invalid
/// ```
ValidationResult validateNotFuture(
  DateTime? date, {
  String fieldName = 'Date',
}) {
  if (date == null) {
    return ValidationResult.failure('$fieldName is required');
  }

  if (date.isAfter(DateTime.now())) {
    return ValidationResult.failure('$fieldName cannot be in the future');
  }

  return ValidationResult.success();
}

// ============================================================================
// Validaciones de Texto
// ============================================================================

/// Valida un email
///
/// [email]: Email a validar
///
/// Ejemplo:
/// ```dart
/// validateEmail('user@example.com'); // Valid
/// validateEmail('invalid-email'); // Invalid: "Invalid email format"
/// validateEmail(''); // Invalid: "Email is required"
/// ```
ValidationResult validateEmail(String? email) {
  if (email == null || email.isEmpty) {
    return ValidationResult.failure('Email is required');
  }

  // Expresión regular para validar email
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  if (!emailRegex.hasMatch(email)) {
    return ValidationResult.failure('Invalid email format');
  }

  return ValidationResult.success();
}

/// Valida que un texto no esté vacío
///
/// [text]: Texto a validar
/// [fieldName]: Nombre del campo para mensajes de error (por defecto 'Field')
/// [minLength]: Longitud mínima (opcional)
/// [maxLength]: Longitud máxima (opcional)
///
/// Ejemplo:
/// ```dart
/// validateRequired('Hello'); // Valid
/// validateRequired(''); // Invalid: "Field is required"
/// validateRequired('Hi', minLength: 5); // Invalid: "Field must be at least 5 characters"
/// ```
ValidationResult validateRequired(
  String? text, {
  String fieldName = 'Field',
  int? minLength,
  int? maxLength,
}) {
  if (text == null || text.trim().isEmpty) {
    return ValidationResult.failure('$fieldName is required');
  }

  final trimmedText = text.trim();

  if (minLength != null && trimmedText.length < minLength) {
    return ValidationResult.failure(
      '$fieldName must be at least $minLength characters',
    );
  }

  if (maxLength != null && trimmedText.length > maxLength) {
    return ValidationResult.failure(
      '$fieldName must not exceed $maxLength characters',
    );
  }

  return ValidationResult.success();
}

/// Valida un símbolo de trading (e.g., BTC-USDT, ETH-USDT)
///
/// [symbol]: Símbolo a validar
///
/// Ejemplo:
/// ```dart
/// validateSymbol('BTC-USDT'); // Valid
/// validateSymbol('BTCUSDT'); // Valid
/// validateSymbol(''); // Invalid: "Symbol is required"
/// validateSymbol('BTC'); // Invalid: "Invalid symbol format"
/// ```
ValidationResult validateSymbol(String? symbol) {
  if (symbol == null || symbol.isEmpty) {
    return ValidationResult.failure('Symbol is required');
  }

  // Permitir formatos: BTC-USDT, BTCUSDT, BTC/USDT
  final symbolRegex = RegExp(r'^[A-Z0-9]{2,10}[-/]?[A-Z]{3,6}$');

  if (!symbolRegex.hasMatch(symbol.toUpperCase())) {
    return ValidationResult.failure('Invalid symbol format');
  }

  return ValidationResult.success();
}

/// Valida una contraseña
///
/// [password]: Contraseña a validar
/// [minLength]: Longitud mínima (por defecto 8)
/// [requireUppercase]: Requiere mayúsculas (por defecto true)
/// [requireLowercase]: Requiere minúsculas (por defecto true)
/// [requireNumbers]: Requiere números (por defecto true)
/// [requireSpecialChars]: Requiere caracteres especiales (por defecto false)
///
/// Ejemplo:
/// ```dart
/// validatePassword('Pass123'); // Valid
/// validatePassword('pass'); // Invalid: "Password must be at least 8 characters"
/// validatePassword('password'); // Invalid: "Password must contain uppercase letters"
/// ```
ValidationResult validatePassword(
  String? password, {
  int minLength = 8,
  bool requireUppercase = true,
  bool requireLowercase = true,
  bool requireNumbers = true,
  bool requireSpecialChars = false,
}) {
  if (password == null || password.isEmpty) {
    return ValidationResult.failure('Password is required');
  }

  if (password.length < minLength) {
    return ValidationResult.failure(
      'Password must be at least $minLength characters',
    );
  }

  if (requireUppercase && !password.contains(RegExp(r'[A-Z]'))) {
    return ValidationResult.failure(
      'Password must contain uppercase letters',
    );
  }

  if (requireLowercase && !password.contains(RegExp(r'[a-z]'))) {
    return ValidationResult.failure(
      'Password must contain lowercase letters',
    );
  }

  if (requireNumbers && !password.contains(RegExp(r'[0-9]'))) {
    return ValidationResult.failure('Password must contain numbers');
  }

  if (requireSpecialChars && !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    return ValidationResult.failure(
      'Password must contain special characters',
    );
  }

  return ValidationResult.success();
}

// ============================================================================
// Validaciones Compuestas
// ============================================================================

/// Valida múltiples validaciones a la vez
///
/// [validations]: Lista de resultados de validación
///
/// Retorna el primer error encontrado o success si todos son válidos
///
/// Ejemplo:
/// ```dart
/// final result = validateAll([
///   validatePrice(100),
///   validateAmount(10),
///   validateEmail('user@example.com'),
/// ]);
/// ```
ValidationResult validateAll(List<ValidationResult> validations) {
  for (final validation in validations) {
    if (!validation.isValid) {
      return validation;
    }
  }

  return ValidationResult.success();
}

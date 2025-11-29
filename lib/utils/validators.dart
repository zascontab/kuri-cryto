import '../services/api_exception.dart';

/// Input validators for trading operations
///
/// ⚠️ CRITICAL: This app handles real money. All inputs MUST be validated.
///
/// These validators ensure data integrity before sending to backend.
class InputValidators {
  InputValidators._(); // Private constructor to prevent instantiation

  /// Validates a trading symbol (e.g., "BTC-USDT")
  ///
  /// Rules:
  /// - Cannot be empty
  /// - Must match format: BASE-QUOTE (e.g., BTC-USDT)
  /// - Both parts must be uppercase letters
  ///
  /// Throws [ValidationException] if invalid
  static void validateSymbol(String symbol) {
    if (symbol.isEmpty) {
      throw ValidationException('Symbol cannot be empty');
    }

    // Must match format: BASE-QUOTE
    final regex = RegExp(r'^[A-Z0-9]+-[A-Z0-9]+$');
    if (!regex.hasMatch(symbol)) {
      throw ValidationException(
        'Invalid symbol format. Expected format: BASE-QUOTE (e.g., BTC-USDT)',
      );
    }

    // Check minimum length
    if (symbol.length < 5) {
      // Minimum: A-B
      throw ValidationException('Symbol is too short');
    }
  }

  /// Validates an exchange name
  ///
  /// Rules:
  /// - Cannot be empty
  /// - Must be lowercase alphanumeric
  ///
  /// Throws [ValidationException] if invalid
  static void validateExchange(String exchange) {
    if (exchange.isEmpty) {
      throw ValidationException('Exchange cannot be empty');
    }

    final regex = RegExp(r'^[a-z0-9]+$');
    if (!regex.hasMatch(exchange)) {
      throw ValidationException(
        'Invalid exchange format. Must be lowercase alphanumeric',
      );
    }
  }

  /// Validates a trading amount
  ///
  /// Rules:
  /// - Must be positive
  /// - Cannot be NaN or Infinite
  /// - Must be within reasonable bounds
  ///
  /// Throws [ValidationException] if invalid
  static void validateAmount(double amount) {
    if (amount.isNaN) {
      throw ValidationException('Amount is NaN (Not a Number)');
    }

    if (amount.isInfinite) {
      throw ValidationException('Amount is Infinite');
    }

    if (amount <= 0) {
      throw ValidationException('Amount must be positive');
    }

    // Sanity check: amount shouldn't be astronomically large
    if (amount > 1e15) {
      throw ValidationException('Amount is unreasonably large');
    }
  }

  /// Validates a price
  ///
  /// Rules:
  /// - Must be positive
  /// - Cannot be NaN or Infinite
  ///
  /// Throws [ValidationException] if invalid
  static void validatePrice(double price) {
    if (price.isNaN) {
      throw ValidationException('Price is NaN (Not a Number)');
    }

    if (price.isInfinite) {
      throw ValidationException('Price is Infinite');
    }

    if (price <= 0) {
      throw ValidationException('Price must be positive');
    }
  }

  /// Validates a percentage value
  ///
  /// Rules:
  /// - Cannot be NaN or Infinite
  /// - Must be within reasonable bounds (-100% to +10000%)
  ///
  /// Throws [ValidationException] if invalid
  static void validatePercentage(double percentage) {
    if (percentage.isNaN) {
      throw ValidationException('Percentage is NaN (Not a Number)');
    }

    if (percentage.isInfinite) {
      throw ValidationException('Percentage is Infinite');
    }

    // Sanity check: percentage shouldn't be too extreme
    if (percentage < -100 || percentage > 10000) {
      throw ValidationException('Percentage is out of reasonable bounds');
    }
  }

  /// Validates leverage value
  ///
  /// Rules:
  /// - Must be positive integer
  /// - Must be within exchange limits (typically 1-125)
  ///
  /// Throws [ValidationException] if invalid
  static void validateLeverage(int leverage) {
    if (leverage < 1) {
      throw ValidationException('Leverage must be at least 1');
    }

    if (leverage > 125) {
      throw ValidationException('Leverage cannot exceed 125');
    }
  }

  /// Validates confidence value (0.0 - 1.0)
  ///
  /// Rules:
  /// - Must be between 0.0 and 1.0
  /// - Cannot be NaN or Infinite
  ///
  /// Throws [ValidationException] if invalid
  static void validateConfidence(double confidence) {
    if (confidence.isNaN) {
      throw ValidationException('Confidence is NaN (Not a Number)');
    }

    if (confidence.isInfinite) {
      throw ValidationException('Confidence is Infinite');
    }

    if (confidence < 0.0 || confidence > 1.0) {
      throw ValidationException('Confidence must be between 0.0 and 1.0');
    }
  }
}

/// Output validators for backend responses
///
/// ⚠️ CRITICAL: Never trust backend data. Always validate.
///
/// These validators ensure data integrity from backend responses.
class OutputValidators {
  OutputValidators._(); // Private constructor

  /// Validates and parses a price from backend response
  ///
  /// Rules:
  /// - Cannot be null
  /// - Must be non-negative
  /// - Cannot be NaN or Infinite
  ///
  /// Throws [ParsingException] if invalid
  static double validatePrice(dynamic value, String fieldName) {
    if (value == null) {
      throw ParsingException('$fieldName is null');
    }

    try {
      final price = (value as num).toDouble();

      if (price.isNaN) {
        throw ParsingException('$fieldName is NaN');
      }

      if (price.isInfinite) {
        throw ParsingException('$fieldName is Infinite');
      }

      if (price < 0) {
        throw ParsingException('$fieldName cannot be negative: $price');
      }

      return price;
    } catch (e) {
      throw ParsingException('Failed to parse $fieldName: $e');
    }
  }

  /// Validates and parses a timestamp
  ///
  /// Rules:
  /// - If null, returns current time
  /// - Must be valid ISO 8601 format
  /// - Cannot be too far in the future (max 1 day)
  ///
  /// Throws [ParsingException] if invalid
  static DateTime validateTimestamp(String? value) {
    if (value == null || value.isEmpty) {
      return DateTime.now();
    }

    try {
      final timestamp = DateTime.parse(value);

      // Sanity check: timestamp shouldn't be too far in the future
      final maxFuture = DateTime.now().add(const Duration(days: 1));
      if (timestamp.isAfter(maxFuture)) {
        throw ParsingException(
          'Timestamp is too far in the future: $timestamp',
        );
      }

      return timestamp;
    } catch (e) {
      throw ParsingException('Failed to parse timestamp: $e');
    }
  }

  /// Validates and parses a percentage
  ///
  /// Rules:
  /// - Cannot be null
  /// - Cannot be NaN or Infinite
  /// - Must be within reasonable bounds
  ///
  /// Throws [ParsingException] if invalid
  static double validatePercentage(dynamic value, String fieldName) {
    if (value == null) {
      throw ParsingException('$fieldName is null');
    }

    try {
      final percentage = (value as num).toDouble();

      if (percentage.isNaN) {
        throw ParsingException('$fieldName is NaN');
      }

      if (percentage.isInfinite) {
        throw ParsingException('$fieldName is Infinite');
      }

      // Sanity check
      if (percentage < -100 || percentage > 10000) {
        throw ParsingException('$fieldName is out of bounds: $percentage');
      }

      return percentage;
    } catch (e) {
      throw ParsingException('Failed to parse $fieldName: $e');
    }
  }

  /// Validates and parses a confidence value (0.0 - 1.0)
  ///
  /// Rules:
  /// - Cannot be null
  /// - Must be between 0.0 and 1.0
  ///
  /// Throws [ParsingException] if invalid
  static double validateConfidence(dynamic value) {
    if (value == null) {
      throw ParsingException('Confidence is null');
    }

    try {
      final confidence = (value as num).toDouble();

      if (confidence.isNaN) {
        throw ParsingException('Confidence is NaN');
      }

      if (confidence.isInfinite) {
        throw ParsingException('Confidence is Infinite');
      }

      if (confidence < 0.0 || confidence > 1.0) {
        throw ParsingException('Confidence out of range: $confidence');
      }

      return confidence;
    } catch (e) {
      throw ParsingException('Failed to parse confidence: $e');
    }
  }

  /// Validates a string field
  ///
  /// Rules:
  /// - If required, cannot be null or empty
  /// - If optional, returns default value if null
  ///
  /// Throws [ParsingException] if invalid
  static String validateString(
    dynamic value,
    String fieldName, {
    bool required = true,
    String defaultValue = '',
  }) {
    if (value == null) {
      if (required) {
        throw ParsingException('$fieldName is null');
      }
      return defaultValue;
    }

    final str = value.toString();

    if (required && str.isEmpty) {
      throw ParsingException('$fieldName is empty');
    }

    return str;
  }

  /// Validates a list field
  ///
  /// Rules:
  /// - If required, cannot be null
  /// - Returns empty list if null and not required
  ///
  /// Throws [ParsingException] if invalid
  static List<T> validateList<T>(
    dynamic value,
    String fieldName, {
    bool required = true,
  }) {
    if (value == null) {
      if (required) {
        throw ParsingException('$fieldName is null');
      }
      return [];
    }

    if (value is! List) {
      throw ParsingException('$fieldName is not a list');
    }

    return List<T>.from(value);
  }
}

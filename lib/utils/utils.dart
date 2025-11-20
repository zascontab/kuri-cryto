/// Utilidades y helpers de la aplicación
///
/// Este archivo exporta todas las utilidades disponibles para facilitar
/// las importaciones en toda la aplicación.
///
/// Uso:
/// ```dart
/// import 'package:kuri_crypto/utils/utils.dart';
///
/// // Ahora puedes usar todas las utilidades
/// final formattedPrice = formatCurrency(1234.56);
/// final isValid = validatePrice(100);
/// final color = AppColors.profit;
/// ```
library;

// Formatters
export 'formatters.dart';

// Validators
export 'validators.dart';

// Constants
export 'constants.dart';

// Extensions
export 'extensions.dart';

// Error Handler
export 'error_handler.dart';

// Chart Helpers
export 'chart_helpers.dart';

// Preferences Helper
export 'preferences_helper.dart';

// Network Helper
export 'network_helper.dart';

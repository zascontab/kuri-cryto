import 'package:intl/intl.dart';
import '../models/position.dart';
import 'formatters.dart';

/// Extensiones para tipos nativos y modelos de la aplicación
///
/// Este archivo contiene extensiones útiles para DateTime, String, Double,
/// int, List, y Position que facilitan el trabajo con estos tipos.
///
/// Ejemplos de uso:
/// ```dart
/// // DateTime
/// final now = DateTime.now();
/// print(now.toFormattedString()); // "2025-11-16 14:30:45"
/// print(now.isToday()); // true
///
/// // String
/// print('2025-11-16'.toDateTime()); // DateTime(2025, 11, 16)
/// print('hello world'.capitalize()); // "Hello world"
///
/// // Double
/// print(0.1234.toPercent()); // "12.34%"
/// print(1234.56.toCurrency()); // "$1,234.56"
///
/// // Position
/// final position = Position(...);
/// print(position.isProfitable()); // true/false
/// print(position.getDuration()); // Duration
/// ```

// ============================================================================
// DateTime Extensions
// ============================================================================

/// Extensión para DateTime
extension DateTimeExtension on DateTime {
  /// Formatea la fecha en formato string
  ///
  /// [format]: Formato de fecha (por defecto 'yyyy-MM-dd HH:mm:ss')
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().toFormattedString(); // "2025-11-16 14:30:45"
  /// DateTime.now().toFormattedString('yyyy-MM-dd'); // "2025-11-16"
  /// ```
  String toFormattedString([String format = 'yyyy-MM-dd HH:mm:ss']) {
    return formatDate(this, format);
  }

  /// Verifica si es hoy
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().isToday(); // true
  /// DateTime.now().subtract(Duration(days: 1)).isToday(); // false
  /// ```
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Verifica si es ayer
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().subtract(Duration(days: 1)).isYesterday(); // true
  /// ```
  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Verifica si es mañana
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().add(Duration(days: 1)).isTomorrow(); // true
  /// ```
  bool isTomorrow() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Verifica si está en el pasado
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().subtract(Duration(hours: 1)).isPast(); // true
  /// ```
  bool isPast() {
    return isBefore(DateTime.now());
  }

  /// Verifica si está en el futuro
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().add(Duration(hours: 1)).isFuture(); // true
  /// ```
  bool isFuture() {
    return isAfter(DateTime.now());
  }

  /// Verifica si está en la misma semana
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().isThisWeek(); // true
  /// ```
  bool isThisWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return isAfter(weekStart) && isBefore(weekEnd);
  }

  /// Verifica si está en el mismo mes
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().isThisMonth(); // true
  /// ```
  bool isThisMonth() {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Verifica si está en el mismo año
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().isThisYear(); // true
  /// ```
  bool isThisYear() {
    return year == DateTime.now().year;
  }

  /// Obtiene el inicio del día (00:00:00)
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().startOfDay(); // 2025-11-16 00:00:00
  /// ```
  DateTime startOfDay() {
    return DateTime(year, month, day);
  }

  /// Obtiene el fin del día (23:59:59.999)
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().endOfDay(); // 2025-11-16 23:59:59.999
  /// ```
  DateTime endOfDay() {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Obtiene el inicio de la semana (lunes)
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().startOfWeek(); // Lunes de esta semana
  /// ```
  DateTime startOfWeek() {
    return subtract(Duration(days: weekday - 1)).startOfDay();
  }

  /// Obtiene el fin de la semana (domingo)
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().endOfWeek(); // Domingo de esta semana
  /// ```
  DateTime endOfWeek() {
    return add(Duration(days: 7 - weekday)).endOfDay();
  }

  /// Obtiene el inicio del mes
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().startOfMonth(); // 2025-11-01 00:00:00
  /// ```
  DateTime startOfMonth() {
    return DateTime(year, month, 1);
  }

  /// Obtiene el fin del mes
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().endOfMonth(); // 2025-11-30 23:59:59.999
  /// ```
  DateTime endOfMonth() {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }

  /// Formatea como tiempo relativo (hace 2 horas, etc.)
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().subtract(Duration(hours: 2)).timeAgo(); // "2 hours ago"
  /// ```
  String timeAgo() {
    return formatRelativeDate(this);
  }

  /// Obtiene el día de la semana en formato legible
  ///
  /// [short]: Si es true, devuelve abreviado (por defecto false)
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().weekdayName(); // "Saturday"
  /// DateTime.now().weekdayName(short: true); // "Sat"
  /// ```
  String weekdayName({bool short = false}) {
    final format = short ? 'EEE' : 'EEEE';
    return DateFormat(format).format(this);
  }

  /// Obtiene el mes en formato legible
  ///
  /// [short]: Si es true, devuelve abreviado (por defecto false)
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().monthName(); // "November"
  /// DateTime.now().monthName(short: true); // "Nov"
  /// ```
  String monthName({bool short = false}) {
    final format = short ? 'MMM' : 'MMMM';
    return DateFormat(format).format(this);
  }

  /// Añade días laborables (excluyendo fines de semana)
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().addBusinessDays(5); // Añade 5 días laborables
  /// ```
  DateTime addBusinessDays(int days) {
    var date = this;
    var addedDays = 0;

    while (addedDays < days) {
      date = date.add(const Duration(days: 1));
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday) {
        addedDays++;
      }
    }

    return date;
  }

  /// Verifica si es fin de semana
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().isWeekend(); // true si es sábado o domingo
  /// ```
  bool isWeekend() {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  /// Verifica si es día laborable
  ///
  /// Ejemplo:
  /// ```dart
  /// DateTime.now().isWeekday(); // true si es lunes a viernes
  /// ```
  bool isWeekday() {
    return !isWeekend();
  }
}

// ============================================================================
// String Extensions
// ============================================================================

/// Extensión para String
extension StringExtension on String {
  /// Convierte string a DateTime
  ///
  /// Ejemplo:
  /// ```dart
  /// '2025-11-16'.toDateTime(); // DateTime(2025, 11, 16)
  /// '2025-11-16 14:30:45'.toDateTime(); // DateTime(2025, 11, 16, 14, 30, 45)
  /// ```
  DateTime? toDateTime() {
    return DateTime.tryParse(this);
  }

  /// Capitaliza la primera letra
  ///
  /// Ejemplo:
  /// ```dart
  /// 'hello world'.capitalize(); // "Hello world"
  /// 'HELLO'.capitalize(); // "HELLO"
  /// ```
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Capitaliza cada palabra
  ///
  /// Ejemplo:
  /// ```dart
  /// 'hello world'.capitalizeWords(); // "Hello World"
  /// ```
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Convierte a título (Title Case)
  ///
  /// Ejemplo:
  /// ```dart
  /// 'HELLO WORLD'.toTitleCase(); // "Hello World"
  /// 'hello_world'.toTitleCase(); // "Hello World"
  /// ```
  String toTitleCase() {
    return replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word.capitalize())
        .join(' ');
  }

  /// Convierte a camelCase
  ///
  /// Ejemplo:
  /// ```dart
  /// 'hello world'.toCamelCase(); // "helloWorld"
  /// 'hello_world'.toCamelCase(); // "helloWorld"
  /// ```
  String toCamelCase() {
    final words = replaceAll('_', ' ').replaceAll('-', ' ').split(' ');
    if (words.isEmpty) return this;

    return words.first.toLowerCase() +
        words.skip(1).map((word) => word.capitalize()).join();
  }

  /// Convierte a snake_case
  ///
  /// Ejemplo:
  /// ```dart
  /// 'HelloWorld'.toSnakeCase(); // "hello_world"
  /// 'helloWorld'.toSnakeCase(); // "hello_world"
  /// ```
  String toSnakeCase() {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^_'), '');
  }

  /// Verifica si es un email válido
  ///
  /// Ejemplo:
  /// ```dart
  /// 'user@example.com'.isEmail(); // true
  /// 'invalid-email'.isEmail(); // false
  /// ```
  bool isEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Verifica si es un número
  ///
  /// Ejemplo:
  /// ```dart
  /// '123'.isNumeric(); // true
  /// '123.45'.isNumeric(); // true
  /// 'abc'.isNumeric(); // false
  /// ```
  bool isNumeric() {
    return double.tryParse(this) != null;
  }

  /// Convierte a double de forma segura
  ///
  /// Ejemplo:
  /// ```dart
  /// '123.45'.toDoubleOrNull(); // 123.45
  /// 'abc'.toDoubleOrNull(); // null
  /// ```
  double? toDoubleOrNull() {
    return double.tryParse(this);
  }

  /// Convierte a int de forma segura
  ///
  /// Ejemplo:
  /// ```dart
  /// '123'.toIntOrNull(); // 123
  /// 'abc'.toIntOrNull(); // null
  /// ```
  int? toIntOrNull() {
    return int.tryParse(this);
  }

  /// Trunca el string a una longitud máxima
  ///
  /// [maxLength]: Longitud máxima
  /// [ellipsis]: Texto a añadir al final (por defecto '...')
  ///
  /// Ejemplo:
  /// ```dart
  /// 'Hello World'.truncate(8); // "Hello..."
  /// 'Hello World'.truncate(8, ellipsis: ''); // "Hello Wo"
  /// ```
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Remueve espacios en blanco al inicio y final
  ///
  /// Ejemplo:
  /// ```dart
  /// '  hello  '.trimAll(); // "hello"
  /// ```
  String trimAll() {
    return trim();
  }

  /// Remueve todos los espacios en blanco
  ///
  /// Ejemplo:
  /// ```dart
  /// 'hello world'.removeWhitespace(); // "helloworld"
  /// ```
  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Verifica si contiene solo letras
  ///
  /// Ejemplo:
  /// ```dart
  /// 'hello'.isAlpha(); // true
  /// 'hello123'.isAlpha(); // false
  /// ```
  bool isAlpha() {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  /// Verifica si contiene solo letras y números
  ///
  /// Ejemplo:
  /// ```dart
  /// 'hello123'.isAlphanumeric(); // true
  /// 'hello_123'.isAlphanumeric(); // false
  /// ```
  bool isAlphanumeric() {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }
}

// ============================================================================
// Double Extensions
// ============================================================================

/// Extensión para double
extension DoubleExtension on double {
  /// Convierte a porcentaje
  ///
  /// [decimals]: Número de decimales (por defecto 2)
  /// [includeSign]: Incluir signo + para positivos (por defecto false)
  ///
  /// Ejemplo:
  /// ```dart
  /// 0.1234.toPercent(); // "12.34%"
  /// 0.1234.toPercent(decimals: 1); // "12.3%"
  /// 0.1234.toPercent(includeSign: true); // "+12.34%"
  /// ```
  String toPercent({int decimals = 2, bool includeSign = false}) {
    return formatPercent(this, decimals, includeSign);
  }

  /// Convierte a moneda
  ///
  /// [symbol]: Símbolo de moneda (por defecto '\$')
  /// [decimals]: Número de decimales (por defecto 2)
  ///
  /// Ejemplo:
  /// ```dart
  /// 1234.56.toCurrency(); // "$1,234.56"
  /// 1234.56.toCurrency(symbol: '€'); // "€1,234.56"
  /// ```
  String toCurrency({String symbol = '\$', int decimals = 2}) {
    return formatCurrency(this, symbol, decimals);
  }

  /// Formatea como número con separadores de miles
  ///
  /// [decimals]: Número de decimales (por defecto 2)
  ///
  /// Ejemplo:
  /// ```dart
  /// 1234567.89.toFormattedString(); // "1,234,567.89"
  /// 1234567.89.toFormattedString(decimals: 0); // "1,234,568"
  /// ```
  String toFormattedString({int decimals = 2}) {
    return formatNumber(this, decimals);
  }

  /// Formatea como número compacto (K, M, B, T)
  ///
  /// [decimals]: Número de decimales (por defecto 2)
  ///
  /// Ejemplo:
  /// ```dart
  /// 1234.0.toCompact(); // "1.23K"
  /// 1234567.0.toCompact(); // "1.23M"
  /// ```
  String toCompact({int decimals = 2}) {
    return formatCompactNumber(this, decimals);
  }

  /// Redondea a un número específico de decimales
  ///
  /// [decimals]: Número de decimales
  ///
  /// Ejemplo:
  /// ```dart
  /// 1.2345.roundToDecimals(2); // 1.23
  /// 1.2355.roundToDecimals(2); // 1.24
  /// ```
  double roundToDecimals(int decimals) {
    final factor = pow(10, decimals);
    return (this * factor).round() / factor;
  }

  /// Verifica si está en un rango
  ///
  /// [min]: Valor mínimo
  /// [max]: Valor máximo
  ///
  /// Ejemplo:
  /// ```dart
  /// 5.0.isInRange(1, 10); // true
  /// 15.0.isInRange(1, 10); // false
  /// ```
  bool isInRange(double min, double max) {
    return this >= min && this <= max;
  }

  /// Clampea el valor entre min y max
  ///
  /// [min]: Valor mínimo
  /// [max]: Valor máximo
  ///
  /// Ejemplo:
  /// ```dart
  /// 5.0.clampValue(1, 10); // 5.0
  /// 15.0.clampValue(1, 10); // 10.0
  /// (-5.0).clampValue(1, 10); // 1.0
  /// ```
  double clampValue(double min, double max) {
    return clamp(min, max);
  }

  /// Verifica si es aproximadamente igual a otro valor
  ///
  /// [other]: Otro valor
  /// [epsilon]: Tolerancia (por defecto 0.0001)
  ///
  /// Ejemplo:
  /// ```dart
  /// 1.0000001.isApproximately(1.0); // true
  /// 1.1.isApproximately(1.0); // false
  /// ```
  bool isApproximately(double other, {double epsilon = 0.0001}) {
    return (this - other).abs() < epsilon;
  }
}

// ============================================================================
// int Extensions
// ============================================================================

/// Extensión para int
extension IntExtension on int {
  /// Convierte bytes a tamaño legible
  ///
  /// [decimals]: Número de decimales (por defecto 2)
  ///
  /// Ejemplo:
  /// ```dart
  /// 1024.toSize(); // "1.00 KB"
  /// 1048576.toSize(); // "1.00 MB"
  /// ```
  String toSize({int decimals = 2}) {
    return formatSize(this, decimals);
  }

  /// Convierte milisegundos a latencia formateada
  ///
  /// [decimals]: Número de decimales (por defecto 2)
  ///
  /// Ejemplo:
  /// ```dart
  /// 50.toLatency(); // "50ms"
  /// 1234.toLatency(); // "1.23s"
  /// ```
  String toLatency({int decimals = 2}) {
    return formatLatency(this, decimals);
  }

  /// Verifica si es par
  ///
  /// Ejemplo:
  /// ```dart
  /// 4.isEven(); // true
  /// 5.isEven(); // false
  /// ```
  bool isEvenNumber() {
    return this % 2 == 0;
  }

  /// Verifica si es impar
  ///
  /// Ejemplo:
  /// ```dart
  /// 5.isOdd(); // true
  /// 4.isOdd(); // false
  /// ```
  bool isOddNumber() {
    return this % 2 != 0;
  }

  /// Verifica si es positivo
  ///
  /// Ejemplo:
  /// ```dart
  /// 5.isPositive(); // true
  /// (-5).isPositive(); // false
  /// ```
  bool isPositive() {
    return this > 0;
  }

  /// Verifica si es negativo
  ///
  /// Ejemplo:
  /// ```dart
  /// (-5).isNegative(); // true
  /// 5.isNegative(); // false
  /// ```
  bool isNegative() {
    return this < 0;
  }
}

// ============================================================================
// List Extensions
// ============================================================================

/// Extensión para List
extension ListExtension<T> on List<T> {
  /// Obtiene el primer elemento o null si está vacío
  ///
  /// Ejemplo:
  /// ```dart
  /// [1, 2, 3].firstOrNull(); // 1
  /// [].firstOrNull(); // null
  /// ```
  T? firstOrNull() {
    return isEmpty ? null : first;
  }

  /// Obtiene el último elemento o null si está vacío
  ///
  /// Ejemplo:
  /// ```dart
  /// [1, 2, 3].lastOrNull(); // 3
  /// [].lastOrNull(); // null
  /// ```
  T? lastOrNull() {
    return isEmpty ? null : last;
  }

  /// Divide la lista en chunks de tamaño específico
  ///
  /// [size]: Tamaño de cada chunk
  ///
  /// Ejemplo:
  /// ```dart
  /// [1, 2, 3, 4, 5].chunk(2); // [[1, 2], [3, 4], [5]]
  /// ```
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}

// ============================================================================
// Position Extensions
// ============================================================================

/// Extensión para Position
extension PositionExtension on Position {
  /// Verifica si la posición es rentable
  ///
  /// Ejemplo:
  /// ```dart
  /// position.isProfitable(); // true si unrealizedPnl > 0
  /// ```
  bool isProfitablePosition() {
    return unrealizedPnl > 0;
  }

  /// Obtiene la duración de la posición
  ///
  /// Ejemplo:
  /// ```dart
  /// position.getDuration(); // Duration desde openTime hasta ahora/closeTime
  /// ```
  Duration getDuration() {
    final endTime = closeTime ?? DateTime.now();
    return endTime.difference(openTime);
  }

  /// Obtiene la duración formateada
  ///
  /// [compact]: Si es true, usa formato compacto (por defecto false)
  ///
  /// Ejemplo:
  /// ```dart
  /// position.getFormattedDuration(); // "2h 30m"
  /// position.getFormattedDuration(compact: true); // "2h30m"
  /// ```
  String getFormattedDuration({bool compact = false}) {
    return formatDuration(getDuration(), compact: compact);
  }

  /// Calcula el ROI (Return on Investment)
  ///
  /// Ejemplo:
  /// ```dart
  /// position.getRoi(); // Porcentaje de retorno
  /// ```
  double getRoi() {
    final investment = entryPrice * size;
    if (investment == 0) return 0.0;
    return (unrealizedPnl / investment) * 100;
  }

  /// Obtiene el ROI formateado
  ///
  /// [decimals]: Número de decimales (por defecto 2)
  ///
  /// Ejemplo:
  /// ```dart
  /// position.getFormattedRoi(); // "+12.34%"
  /// ```
  String getFormattedRoi({int decimals = 2}) {
    return formatPercent(getRoi() / 100, decimals, true);
  }

  /// Verifica si el stop loss está cerca de ser alcanzado
  ///
  /// [threshold]: Porcentaje de proximidad (por defecto 5%)
  ///
  /// Ejemplo:
  /// ```dart
  /// position.isNearStopLoss(5); // true si está a menos del 5% del SL
  /// ```
  bool isNearStopLoss({double threshold = 5.0}) {
    if (stopLoss == null) return false;

    final distancePercent = ((currentPrice - stopLoss!).abs() / entryPrice) * 100;
    return distancePercent <= threshold;
  }

  /// Verifica si el take profit está cerca de ser alcanzado
  ///
  /// [threshold]: Porcentaje de proximidad (por defecto 5%)
  ///
  /// Ejemplo:
  /// ```dart
  /// position.isNearTakeProfit(5); // true si está a menos del 5% del TP
  /// ```
  bool isNearTakeProfit({double threshold = 5.0}) {
    if (takeProfit == null) return false;

    final distancePercent = ((currentPrice - takeProfit!).abs() / entryPrice) * 100;
    return distancePercent <= threshold;
  }

  /// Obtiene el ratio Risk/Reward
  ///
  /// Ejemplo:
  /// ```dart
  /// position.getRiskRewardRatio(); // 2.0 (risk:reward de 1:2)
  /// ```
  double? getRiskRewardRatio() {
    if (stopLoss == null || takeProfit == null) return null;

    final risk = (entryPrice - stopLoss!).abs();
    final reward = (takeProfit! - entryPrice).abs();

    if (risk == 0) return null;
    return reward / risk;
  }

  /// Obtiene el ratio Risk/Reward formateado
  ///
  /// Ejemplo:
  /// ```dart
  /// position.getFormattedRiskReward(); // "1:2.0"
  /// ```
  String getFormattedRiskReward() {
    final ratio = getRiskRewardRatio();
    if (ratio == null) return 'N/A';
    return '1:${ratio.toStringAsFixed(2)}';
  }
}

// Importación necesaria para pow
import 'dart:math';

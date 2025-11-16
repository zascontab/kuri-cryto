import 'package:intl/intl.dart';

/// Utilidades de formateo para la aplicación
///
/// Este archivo contiene funciones de formateo para monedas, porcentajes,
/// números, fechas, duraciones, latencia y tamaños de archivos.
///
/// Ejemplos de uso:
/// ```dart
/// print(formatCurrency(1234.56, '\$')); // "$1,234.56"
/// print(formatPercent(0.1234, 2)); // "12.34%"
/// print(formatDate(DateTime.now(), 'yyyy-MM-dd')); // "2025-11-16"
/// print(formatDuration(Duration(hours: 2, minutes: 30))); // "2h 30m"
/// print(formatLatency(1234)); // "1.23s"
/// print(formatSize(1024000)); // "1.00 MB"
/// ```

// ============================================================================
// Formateo de Moneda
// ============================================================================

/// Formatea un número como moneda con símbolo
///
/// [amount]: Cantidad a formatear
/// [symbol]: Símbolo de la moneda (por defecto '\$')
/// [decimals]: Número de decimales (por defecto 2)
/// [locale]: Localización para el formato (por defecto 'en_US')
///
/// Ejemplo:
/// ```dart
/// formatCurrency(1234.56, '\$'); // "$1,234.56"
/// formatCurrency(1234.567, 'BTC', decimals: 8); // "BTC 1,234.56700000"
/// formatCurrency(1234.5, '€', locale: 'es_ES'); // "€1.234,50"
/// ```
String formatCurrency(
  double amount, [
  String symbol = '\$',
  int decimals = 2,
  String locale = 'en_US',
]) {
  final formatter = NumberFormat.currency(
    symbol: '',
    decimalDigits: decimals,
    locale: locale,
  );

  final formattedAmount = formatter.format(amount).trim();

  // Para símbolos como $ o €, colocar antes del número
  if (symbol == '\$' || symbol == '€' || symbol == '£' || symbol == '¥') {
    return '$symbol$formattedAmount';
  }

  // Para símbolos como BTC, USDT, etc., colocar después con espacio
  return '$symbol $formattedAmount';
}

/// Formatea un número como moneda compacta (K, M, B)
///
/// [amount]: Cantidad a formatear
/// [symbol]: Símbolo de la moneda (por defecto '\$')
/// [decimals]: Número de decimales (por defecto 2)
///
/// Ejemplo:
/// ```dart
/// formatCompactCurrency(1234); // "$1.23K"
/// formatCompactCurrency(1234567); // "$1.23M"
/// formatCompactCurrency(1234567890); // "$1.23B"
/// ```
String formatCompactCurrency(
  double amount, [
  String symbol = '\$',
  int decimals = 2,
]) {
  final formatter = NumberFormat.compact();
  final formattedAmount = formatter.format(amount);

  if (symbol == '\$' || symbol == '€' || symbol == '£' || symbol == '¥') {
    return '$symbol$formattedAmount';
  }

  return '$symbol $formattedAmount';
}

// ============================================================================
// Formateo de Porcentajes
// ============================================================================

/// Formatea un número como porcentaje
///
/// [value]: Valor a formatear (0.1234 = 12.34%)
/// [decimals]: Número de decimales (por defecto 2)
/// [includeSign]: Incluir signo + para valores positivos (por defecto false)
///
/// Ejemplo:
/// ```dart
/// formatPercent(0.1234, 2); // "12.34%"
/// formatPercent(-0.05, 1); // "-5.0%"
/// formatPercent(0.1234, 2, includeSign: true); // "+12.34%"
/// ```
String formatPercent(
  double value, [
  int decimals = 2,
  bool includeSign = false,
]) {
  final percentage = value * 100;
  final sign = includeSign && percentage > 0 ? '+' : '';
  return '$sign${percentage.toStringAsFixed(decimals)}%';
}

/// Formatea un cambio de porcentaje con color coding
///
/// [value]: Valor a formatear (0.1234 = 12.34%)
/// [decimals]: Número de decimals (por defecto 2)
///
/// Retorna un Map con 'text' y 'isPositive'
///
/// Ejemplo:
/// ```dart
/// final result = formatPercentChange(0.1234);
/// print(result['text']); // "+12.34%"
/// print(result['isPositive']); // true
/// ```
Map<String, dynamic> formatPercentChange(
  double value, [
  int decimals = 2,
]) {
  final percentage = value * 100;
  final isPositive = percentage >= 0;
  final sign = isPositive ? '+' : '';

  return {
    'text': '$sign${percentage.toStringAsFixed(decimals)}%',
    'isPositive': isPositive,
    'value': percentage,
  };
}

// ============================================================================
// Formateo de Números
// ============================================================================

/// Formatea un número con separadores de miles
///
/// [value]: Número a formatear
/// [decimals]: Número de decimales (por defecto 2)
/// [locale]: Localización para el formato (por defecto 'en_US')
///
/// Ejemplo:
/// ```dart
/// formatNumber(1234567.89); // "1,234,567.89"
/// formatNumber(1234567.89, 0); // "1,234,568"
/// formatNumber(1234567.89, 4); // "1,234,567.8900"
/// ```
String formatNumber(
  double value, [
  int decimals = 2,
  String locale = 'en_US',
]) {
  final formatter = NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: decimals,
  );
  return formatter.format(value);
}

/// Formatea un número de forma compacta (K, M, B, T)
///
/// [value]: Número a formatear
/// [decimals]: Número de decimales (por defecto 2)
///
/// Ejemplo:
/// ```dart
/// formatCompactNumber(1234); // "1.23K"
/// formatCompactNumber(1234567); // "1.23M"
/// formatCompactNumber(1234567890); // "1.23B"
/// ```
String formatCompactNumber(
  double value, [
  int decimals = 2,
]) {
  if (value.abs() < 1000) {
    return value.toStringAsFixed(decimals);
  }

  final suffixes = ['', 'K', 'M', 'B', 'T'];
  var suffixIndex = 0;
  var compactValue = value;

  while (compactValue.abs() >= 1000 && suffixIndex < suffixes.length - 1) {
    compactValue /= 1000;
    suffixIndex++;
  }

  return '${compactValue.toStringAsFixed(decimals)}${suffixes[suffixIndex]}';
}

// ============================================================================
// Formateo de Fechas
// ============================================================================

/// Formatea una fecha según el formato especificado
///
/// [date]: Fecha a formatear
/// [format]: Formato de fecha (por defecto 'yyyy-MM-dd HH:mm:ss')
/// [locale]: Localización (por defecto 'en_US')
///
/// Formatos comunes:
/// - 'yyyy-MM-dd': 2025-11-16
/// - 'dd/MM/yyyy': 16/11/2025
/// - 'MMM dd, yyyy': Nov 16, 2025
/// - 'HH:mm:ss': 14:30:45
/// - 'yyyy-MM-dd HH:mm': 2025-11-16 14:30
///
/// Ejemplo:
/// ```dart
/// formatDate(DateTime.now(), 'yyyy-MM-dd'); // "2025-11-16"
/// formatDate(DateTime.now(), 'MMM dd, yyyy'); // "Nov 16, 2025"
/// formatDate(DateTime.now(), 'HH:mm:ss'); // "14:30:45"
/// ```
String formatDate(
  DateTime date, [
  String format = 'yyyy-MM-dd HH:mm:ss',
  String locale = 'en_US',
]) {
  final formatter = DateFormat(format, locale);
  return formatter.format(date);
}

/// Formatea una fecha de forma relativa (hace 2 horas, ayer, etc.)
///
/// [date]: Fecha a formatear
///
/// Ejemplo:
/// ```dart
/// formatRelativeDate(DateTime.now().subtract(Duration(hours: 2))); // "2 hours ago"
/// formatRelativeDate(DateTime.now().subtract(Duration(days: 1))); // "Yesterday"
/// ```
String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months ${months == 1 ? 'month' : 'months'} ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  }
}

/// Formatea un rango de fechas
///
/// [from]: Fecha inicial
/// [to]: Fecha final
/// [format]: Formato de fecha (por defecto 'MMM dd, yyyy')
///
/// Ejemplo:
/// ```dart
/// formatDateRange(
///   DateTime(2025, 11, 1),
///   DateTime(2025, 11, 16),
/// ); // "Nov 01, 2025 - Nov 16, 2025"
/// ```
String formatDateRange(
  DateTime from,
  DateTime to, [
  String format = 'MMM dd, yyyy',
]) {
  final fromStr = formatDate(from, format);
  final toStr = formatDate(to, format);
  return '$fromStr - $toStr';
}

// ============================================================================
// Formateo de Duración
// ============================================================================

/// Formatea una duración en formato legible (2h 30m 45s)
///
/// [duration]: Duración a formatear
/// [compact]: Si es true, usa formato compacto (2h30m), por defecto false
///
/// Ejemplo:
/// ```dart
/// formatDuration(Duration(hours: 2, minutes: 30)); // "2h 30m"
/// formatDuration(Duration(minutes: 90)); // "1h 30m"
/// formatDuration(Duration(seconds: 90)); // "1m 30s"
/// formatDuration(Duration(hours: 2, minutes: 30), compact: true); // "2h30m"
/// ```
String formatDuration(Duration duration, {bool compact = false}) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  final separator = compact ? '' : ' ';
  final parts = <String>[];

  if (hours > 0) {
    parts.add('${hours}h');
  }

  if (minutes > 0) {
    parts.add('${minutes}m');
  }

  // Solo mostrar segundos si no hay horas
  if (seconds > 0 && hours == 0) {
    parts.add('${seconds}s');
  }

  if (parts.isEmpty) {
    return '0s';
  }

  return parts.join(separator);
}

/// Formatea una duración en formato HH:MM:SS
///
/// [duration]: Duración a formatear
///
/// Ejemplo:
/// ```dart
/// formatDurationClock(Duration(hours: 2, minutes: 30, seconds: 45)); // "02:30:45"
/// formatDurationClock(Duration(minutes: 5, seconds: 30)); // "00:05:30"
/// ```
String formatDurationClock(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

  return '$hours:$minutes:$seconds';
}

// ============================================================================
// Formateo de Latencia
// ============================================================================

/// Formatea latencia en milisegundos a formato legible
///
/// [ms]: Latencia en milisegundos
/// [decimals]: Número de decimales (por defecto 2)
///
/// Automáticamente selecciona la unidad apropiada (ms, s, m)
///
/// Ejemplo:
/// ```dart
/// formatLatency(50); // "50ms"
/// formatLatency(1234); // "1.23s"
/// formatLatency(65000); // "1.08m"
/// ```
String formatLatency(int ms, [int decimals = 2]) {
  if (ms < 1000) {
    return '${ms}ms';
  } else if (ms < 60000) {
    final seconds = ms / 1000;
    return '${seconds.toStringAsFixed(decimals)}s';
  } else {
    final minutes = ms / 60000;
    return '${minutes.toStringAsFixed(decimals)}m';
  }
}

/// Formatea latencia con color coding (verde/amarillo/rojo)
///
/// [ms]: Latencia en milisegundos
///
/// Retorna un Map con 'text', 'status' ('good', 'warning', 'bad')
///
/// Ejemplo:
/// ```dart
/// final result = formatLatencyWithStatus(50);
/// print(result['text']); // "50ms"
/// print(result['status']); // "good"
/// ```
Map<String, dynamic> formatLatencyWithStatus(int ms) {
  String status;

  if (ms < 100) {
    status = 'good';
  } else if (ms < 500) {
    status = 'warning';
  } else {
    status = 'bad';
  }

  return {
    'text': formatLatency(ms),
    'status': status,
    'value': ms,
  };
}

// ============================================================================
// Formateo de Tamaño de Archivos
// ============================================================================

/// Formatea bytes a tamaño de archivo legible (KB, MB, GB, TB)
///
/// [bytes]: Tamaño en bytes
/// [decimals]: Número de decimales (por defecto 2)
///
/// Ejemplo:
/// ```dart
/// formatSize(1024); // "1.00 KB"
/// formatSize(1048576); // "1.00 MB"
/// formatSize(1073741824); // "1.00 GB"
/// ```
String formatSize(int bytes, [int decimals = 2]) {
  if (bytes < 1024) {
    return '$bytes B';
  }

  final units = ['KB', 'MB', 'GB', 'TB', 'PB'];
  var unitIndex = -1;
  var size = bytes.toDouble();

  do {
    size /= 1024;
    unitIndex++;
  } while (size >= 1024 && unitIndex < units.length - 1);

  return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
}

/// Formatea velocidad de transferencia (bytes/segundo)
///
/// [bytesPerSecond]: Velocidad en bytes por segundo
/// [decimals]: Número de decimales (por defecto 2)
///
/// Ejemplo:
/// ```dart
/// formatSpeed(1024000); // "1.00 MB/s"
/// formatSpeed(512000); // "500.00 KB/s"
/// ```
String formatSpeed(int bytesPerSecond, [int decimals = 2]) {
  return '${formatSize(bytesPerSecond, decimals)}/s';
}

// ============================================================================
// Formateo de Trading
// ============================================================================

/// Formatea un precio de criptomoneda con precisión dinámica
///
/// [price]: Precio a formatear
/// [symbol]: Símbolo de la moneda (por defecto '')
///
/// Automáticamente ajusta los decimales según el precio:
/// - Precios > 100: 2 decimales
/// - Precios > 1: 4 decimales
/// - Precios > 0.01: 6 decimales
/// - Precios < 0.01: 8 decimales
///
/// Ejemplo:
/// ```dart
/// formatCryptoPrice(45678.90, 'BTC'); // "BTC 45,678.90"
/// formatCryptoPrice(1.2345, 'ETH'); // "ETH 1.2345"
/// formatCryptoPrice(0.000123, 'DOGE'); // "DOGE 0.00012300"
/// ```
String formatCryptoPrice(double price, [String symbol = '']) {
  int decimals;

  if (price >= 100) {
    decimals = 2;
  } else if (price >= 1) {
    decimals = 4;
  } else if (price >= 0.01) {
    decimals = 6;
  } else {
    decimals = 8;
  }

  final formattedPrice = formatNumber(price, decimals);

  if (symbol.isEmpty) {
    return formattedPrice;
  }

  return '$symbol $formattedPrice';
}

/// Formatea el profit/loss con signo y color
///
/// [pnl]: Profit/Loss value
/// [asCurrency]: Si es true, formatea como moneda, sino como número
/// [symbol]: Símbolo de moneda (por defecto '\$')
///
/// Ejemplo:
/// ```dart
/// final result = formatPnL(123.45);
/// print(result['text']); // "+$123.45"
/// print(result['isProfit']); // true
/// ```
Map<String, dynamic> formatPnL(
  double pnl, {
  bool asCurrency = true,
  String symbol = '\$',
}) {
  final isProfit = pnl >= 0;
  final sign = isProfit ? '+' : '';
  final absValue = pnl.abs();

  String text;
  if (asCurrency) {
    final formatted = formatCurrency(absValue, symbol);
    text = '$sign$formatted';
  } else {
    final formatted = formatNumber(absValue);
    text = '$sign$formatted';
  }

  return {
    'text': text,
    'isProfit': isProfit,
    'value': pnl,
  };
}

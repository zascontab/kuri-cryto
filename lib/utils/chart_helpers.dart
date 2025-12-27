import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'formatters.dart';

/// Helpers para gráficos con fl_chart
///
/// Este archivo proporciona funciones auxiliares para trabajar con fl_chart,
/// incluyendo preparación de datos, colores, formato de labels, y configuración
/// de grid y ejes.
///
/// Ejemplos de uso:
/// ```dart
/// // Preparar datos para line chart
/// final spots = prepareLineChartData(priceData);
///
/// // Obtener colores consistentes
/// final color = getChartColor(0);
///
/// // Formatear labels
/// final label = formatChartLabel(1234.56, type: ChartLabelType.currency);
///
/// // Calcular intervalo de grid
/// final interval = getGridInterval(0, 100);
/// ```

// ============================================================================
// Tipos de Labels para Charts
// ============================================================================

/// Tipos de labels para formateo en charts
enum ChartLabelType {
  number,
  currency,
  percent,
  date,
  time,
  compact,
}

// ============================================================================
// Preparación de Datos
// ============================================================================

/// Prepara datos para LineChart (fl_chart)
///
/// [data]: Lista de valores (pueden ser Map, List o double)
/// [xKey]: Clave para obtener el valor X del mapa (opcional)
/// [yKey]: Clave para obtener el valor Y del mapa (opcional)
///
/// Retorna una lista de FlSpot para usar en LineChart
///
/// Ejemplo:
/// ```dart
/// // Desde lista de valores
/// final spots = prepareLineChartData([10.0, 20.0, 15.0, 30.0]);
///
/// // Desde lista de mapas
/// final data = [
///   {'timestamp': 1.0, 'price': 100.0},
///   {'timestamp': 2.0, 'price': 110.0},
/// ];
/// final spots = prepareLineChartData(data, xKey: 'timestamp', yKey: 'price');
/// ```
List<FlSpot> prepareLineChartData(
  List<dynamic> data, {
  String? xKey,
  String? yKey,
}) {
  final spots = <FlSpot>[];

  for (var i = 0; i < data.length; i++) {
    final item = data[i];

    double x, y;

    if (item is Map<String, dynamic>) {
      // Extraer de mapa
      x = xKey != null
          ? _parseDouble(item[xKey], defaultValue: i.toDouble())
          : i.toDouble();

      y = yKey != null ? _parseDouble(item[yKey]) : 0.0;
    } else if (item is List && item.length >= 2) {
      // Extraer de lista [x, y]
      x = _parseDouble(item[0], defaultValue: i.toDouble());
      y = _parseDouble(item[1]);
    } else {
      // Valor simple, usar índice como X
      x = i.toDouble();
      y = _parseDouble(item);
    }

    spots.add(FlSpot(x, y));
  }

  return spots;
}

/// Prepara datos para BarChart (fl_chart)
///
/// [data]: Lista de valores
/// [startX]: Valor inicial de X (por defecto 0)
///
/// Retorna una lista de BarChartGroupData
///
/// Ejemplo:
/// ```dart
/// final barGroups = prepareBarChartData([10.0, 20.0, 15.0, 30.0]);
/// ```
List<BarChartGroupData> prepareBarChartData(
  List<double> data, {
  double startX = 0,
  Color? color,
  double barWidth = 22,
}) {
  final groups = <BarChartGroupData>[];

  for (var i = 0; i < data.length; i++) {
    groups.add(
      BarChartGroupData(
        x: (startX + i).toInt(),
        barRods: [
          BarChartRodData(
            toY: data[i],
            color: color ?? getChartColor(i),
            width: barWidth,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  return groups;
}

/// Prepara datos para PieChart (fl_chart)
///
/// [data]: Mapa de labels y valores
/// [showPercentage]: Si mostrar porcentaje en lugar de valor (por defecto true)
///
/// Retorna una lista de PieChartSectionData
///
/// Ejemplo:
/// ```dart
/// final sections = preparePieChartData({
///   'BTC': 50.0,
///   'ETH': 30.0,
///   'Others': 20.0,
/// });
/// ```
List<PieChartSectionData> preparePieChartData(
  Map<String, double> data, {
  bool showPercentage = true,
}) {
  final total = data.values.fold(0.0, (sum, value) => sum + value);
  final sections = <PieChartSectionData>[];

  var colorIndex = 0;
  data.forEach((label, value) {
    final percentage = total > 0 ? (value / total) * 100 : 0.0;

    sections.add(
      PieChartSectionData(
        value: value,
        title: showPercentage
            ? '${percentage.toStringAsFixed(1)}%'
            : value.toStringAsFixed(0),
        color: getChartColor(colorIndex),
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );

    colorIndex++;
  });

  return sections;
}

/// Convierte datos de velas (OHLC) para CandlestickChart
///
/// [data]: Lista de mapas con datos OHLC
///
/// Cada mapa debe contener: timestamp, open, high, low, close
///
/// Ejemplo:
/// ```dart
/// final candles = prepareCandlestickData([
///   {
///     'timestamp': 1637000000000,
///     'open': 100.0,
///     'high': 110.0,
///     'low': 95.0,
///     'close': 105.0,
///   },
/// ]);
/// ```
List<Map<String, dynamic>> prepareCandlestickData(
  List<Map<String, dynamic>> data,
) {
  return data.map((candle) {
    return {
      'timestamp': candle['timestamp'],
      'open': _parseDouble(candle['open']),
      'high': _parseDouble(candle['high']),
      'low': _parseDouble(candle['low']),
      'close': _parseDouble(candle['close']),
      'volume': _parseDouble(candle['volume'], defaultValue: 0.0),
    };
  }).toList();
}

// ============================================================================
// Colores
// ============================================================================

/// Obtiene un color consistente para charts según el índice
///
/// [index]: Índice del elemento
///
/// Retorna un color de la paleta predefinida
///
/// Ejemplo:
/// ```dart
/// final color = getChartColor(0); // Color(0xFF2196F3) - Blue
/// final color2 = getChartColor(1); // Color(0xFF4CAF50) - Green
/// ```
Color getChartColor(int index) {
  return AppColors.chartColors[index % AppColors.chartColors.length];
}

/// Obtiene un gradiente para charts
///
/// [index]: Índice del elemento (opcional)
/// [color]: Color base para el gradiente (opcional)
///
/// Retorna un gradiente LinearGradient
///
/// Ejemplo:
/// ```dart
/// final gradient = getChartGradient(index: 0);
/// final customGradient = getChartGradient(color: Colors.blue);
/// ```
LinearGradient getChartGradient({
  int? index,
  Color? color,
}) {
  final baseColor = color ?? (index != null ? getChartColor(index) : AppColors.primary);

  return LinearGradient(
    colors: [
      baseColor.withOpacity(0.5),
      baseColor.withOpacity(0.0),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Obtiene color según si es profit o loss
///
/// [value]: Valor a evaluar
/// [neutralColor]: Color para valores neutros (opcional)
///
/// Ejemplo:
/// ```dart
/// final color = getProfitLossColor(123.45); // Green
/// final color2 = getProfitLossColor(-50.0); // Red
/// ```
Color getProfitLossColor(
  double value, {
  Color? neutralColor,
}) {
  if (value > 0) return AppColors.profit;
  if (value < 0) return AppColors.loss;
  return neutralColor ?? AppColors.neutral;
}

// ============================================================================
// Formato de Labels
// ============================================================================

/// Formatea un label para mostrar en charts
///
/// [value]: Valor a formatear
/// [type]: Tipo de formateo (por defecto number)
/// [decimals]: Número de decimales (por defecto 2)
///
/// Ejemplo:
/// ```dart
/// formatChartLabel(1234.56); // "1,234.56"
/// formatChartLabel(1234.56, type: ChartLabelType.currency); // "$1,234.56"
/// formatChartLabel(0.1234, type: ChartLabelType.percent); // "12.34%"
/// formatChartLabel(1234567, type: ChartLabelType.compact); // "1.23M"
/// ```
String formatChartLabel(
  double value, {
  ChartLabelType type = ChartLabelType.number,
  int decimals = 2,
}) {
  switch (type) {
    case ChartLabelType.currency:
      return formatCurrency(value, '\$', decimals);

    case ChartLabelType.percent:
      return formatPercent(value, decimals);

    case ChartLabelType.compact:
      return formatCompactNumber(value, decimals);

    case ChartLabelType.date:
      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
      return formatDate(date, 'MMM dd');

    case ChartLabelType.time:
      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
      return formatDate(date, 'HH:mm');

    case ChartLabelType.number:
    default:
      return formatNumber(value, decimals);
  }
}

/// Crea un widget de label para el eje X
///
/// [value]: Valor del eje X
/// [meta]: Metadata del eje
/// [type]: Tipo de formateo (por defecto number)
///
/// Retorna un SideTitleWidget para usar en fl_chart
///
/// Ejemplo:
/// ```dart
/// bottomTitles: AxisTitles(
///   sideTitles: SideTitles(
///     showTitles: true,
///     getTitlesWidget: (value, meta) => getBottomTitleWidget(
///       value,
///       meta,
///       type: ChartLabelType.date,
///     ),
///   ),
/// ),
/// ```
Widget getBottomTitleWidget(
  double value,
  TitleMeta meta, {
  ChartLabelType type = ChartLabelType.number,
  int decimals = 0,
  TextStyle? style,
}) {
  final text = formatChartLabel(value, type: type, decimals: decimals);

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(
      text,
      style: style ??
          const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
    ),
  );
}

/// Crea un widget de label para el eje Y
///
/// [value]: Valor del eje Y
/// [meta]: Metadata del eje
/// [type]: Tipo de formateo (por defecto number)
///
/// Retorna un SideTitleWidget para usar en fl_chart
///
/// Ejemplo:
/// ```dart
/// leftTitles: AxisTitles(
///   sideTitles: SideTitles(
///     showTitles: true,
///     getTitlesWidget: (value, meta) => getLeftTitleWidget(
///       value,
///       meta,
///       type: ChartLabelType.currency,
///     ),
///   ),
/// ),
/// ```
Widget getLeftTitleWidget(
  double value,
  TitleMeta meta, {
  ChartLabelType type = ChartLabelType.number,
  int decimals = 2,
  TextStyle? style,
}) {
  final text = formatChartLabel(value, type: type, decimals: decimals);

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(
      text,
      style: style ??
          const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
    ),
  );
}

// ============================================================================
// Grid y Intervalos
// ============================================================================

/// Calcula un intervalo apropiado para el grid
///
/// [min]: Valor mínimo
/// [max]: Valor máximo
/// [divisions]: Número aproximado de divisiones (por defecto 5)
///
/// Retorna un intervalo apropiado para mostrar en el grid
///
/// Ejemplo:
/// ```dart
/// final interval = getGridInterval(0, 100); // 20.0
/// final interval2 = getGridInterval(0, 1000); // 200.0
/// ```
double getGridInterval(
  double min,
  double max, {
  int divisions = 5,
}) {
  if (max == min) return 1.0;

  final range = max - min;
  final roughInterval = range / divisions;

  // Encontrar la potencia de 10 más cercana
  final magnitude = math.pow(10, (math.log(roughInterval) / math.ln10).floor());

  // Normalizar a 1, 2, 5, o 10
  final normalized = roughInterval / magnitude;

  double niceInterval;
  if (normalized < 1.5) {
    niceInterval = 1.0;
  } else if (normalized < 3) {
    niceInterval = 2.0;
  } else if (normalized < 7) {
    niceInterval = 5.0;
  } else {
    niceInterval = 10.0;
  }

  return niceInterval * magnitude;
}

/// Calcula los límites apropiados para el gráfico con padding
///
/// [values]: Lista de valores a mostrar
/// [paddingPercent]: Porcentaje de padding (por defecto 10%)
///
/// Retorna un mapa con 'min' y 'max'
///
/// Ejemplo:
/// ```dart
/// final limits = getChartLimits([10, 20, 30, 40, 50]);
/// print(limits['min']); // ~9 (10% menos que el mínimo)
/// print(limits['max']); // ~55 (10% más que el máximo)
/// ```
Map<String, double> getChartLimits(
  List<double> values, {
  double paddingPercent = 10.0,
}) {
  if (values.isEmpty) {
    return {'min': 0.0, 'max': 1.0};
  }

  final min = values.reduce(math.min);
  final max = values.reduce(math.max);

  final range = max - min;
  final padding = range * (paddingPercent / 100);

  return {
    'min': min - padding,
    'max': max + padding,
  };
}

// ============================================================================
// Configuración de Grid
// ============================================================================

/// Obtiene configuración de FlGridData para charts
///
/// [showHorizontal]: Mostrar líneas horizontales (por defecto true)
/// [showVertical]: Mostrar líneas verticales (por defecto true)
/// [color]: Color de las líneas (opcional)
///
/// Ejemplo:
/// ```dart
/// gridData: getGridData(showVertical: false),
/// ```
FlGridData getGridData({
  bool showHorizontal = true,
  bool showVertical = true,
  Color? color,
}) {
  return FlGridData(
    show: true,
    drawHorizontalLine: showHorizontal,
    drawVerticalLine: showVertical,
    horizontalInterval: null, // Auto-calculate
    verticalInterval: null, // Auto-calculate
    getDrawingHorizontalLine: (value) {
      return FlLine(
        color: color ?? AppColors.chartGrid,
        strokeWidth: 0.5,
      );
    },
    getDrawingVerticalLine: (value) {
      return FlLine(
        color: color ?? AppColors.chartGrid,
        strokeWidth: 0.5,
      );
    },
  );
}

/// Obtiene configuración de FlBorderData para charts
///
/// [show]: Mostrar borde (por defecto true)
/// [color]: Color del borde (opcional)
///
/// Ejemplo:
/// ```dart
/// borderData: getBorderData(color: Colors.grey),
/// ```
FlBorderData getBorderData({
  bool show = true,
  Color? color,
}) {
  return FlBorderData(
    show: show,
    border: Border.all(
      color: color ?? AppColors.chartGrid,
      width: 1,
    ),
  );
}

/// Obtiene configuración de FlTitlesData para charts
///
/// [showLeft]: Mostrar títulos izquierda (por defecto true)
/// [showRight]: Mostrar títulos derecha (por defecto false)
/// [showTop]: Mostrar títulos arriba (por defecto false)
/// [showBottom]: Mostrar títulos abajo (por defecto true)
/// [leftType]: Tipo de formateo para eje izquierdo
/// [bottomType]: Tipo de formateo para eje inferior
///
/// Ejemplo:
/// ```dart
/// titlesData: getTitlesData(
///   leftType: ChartLabelType.currency,
///   bottomType: ChartLabelType.date,
/// ),
/// ```
FlTitlesData getTitlesData({
  bool showLeft = true,
  bool showRight = false,
  bool showTop = false,
  bool showBottom = true,
  ChartLabelType leftType = ChartLabelType.number,
  ChartLabelType bottomType = ChartLabelType.number,
}) {
  return FlTitlesData(
    show: true,
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: showLeft,
        getTitlesWidget: (value, meta) => getLeftTitleWidget(
          value,
          meta,
          type: leftType,
        ),
        reservedSize: 40,
      ),
    ),
    rightTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: showRight),
    ),
    topTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: showTop),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: showBottom,
        getTitlesWidget: (value, meta) => getBottomTitleWidget(
          value,
          meta,
          type: bottomType,
        ),
        reservedSize: 30,
      ),
    ),
  );
}

// ============================================================================
// Utilidades
// ============================================================================

/// Parse double de forma segura
double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

/// Calcula estadísticas básicas de una lista de valores
///
/// [values]: Lista de valores
///
/// Retorna un mapa con min, max, average, median
///
/// Ejemplo:
/// ```dart
/// final stats = getChartStats([10, 20, 30, 40, 50]);
/// print(stats['average']); // 30.0
/// ```
Map<String, double> getChartStats(List<double> values) {
  if (values.isEmpty) {
    return {
      'min': 0.0,
      'max': 0.0,
      'average': 0.0,
      'median': 0.0,
    };
  }

  final sorted = List<double>.from(values)..sort();

  final min = sorted.first;
  final max = sorted.last;
  final average = values.reduce((a, b) => a + b) / values.length;

  double median;
  final middleIndex = sorted.length ~/ 2;
  if (sorted.length % 2 == 0) {
    median = (sorted[middleIndex - 1] + sorted[middleIndex]) / 2;
  } else {
    median = sorted[middleIndex];
  }

  return {
    'min': min,
    'max': max,
    'average': average,
    'median': median,
  };
}

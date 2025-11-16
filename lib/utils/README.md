# Utils - Utilidades y Helpers

Este directorio contiene todas las utilidades y funciones helpers para la aplicación Kuri Crypto.

## Archivos Disponibles

### 1. `formatters.dart`
Funciones de formateo para presentación de datos.

**Funciones principales:**
- `formatCurrency(amount, symbol, decimals)` - Formatea moneda con símbolo
- `formatPercent(value, decimals, includeSign)` - Formatea porcentajes
- `formatNumber(value, decimals)` - Formatea números con separadores
- `formatDate(date, format)` - Formatea fechas
- `formatDuration(duration)` - Formatea duración (2h 30m)
- `formatLatency(ms)` - Formatea latencia con unidades
- `formatSize(bytes)` - Formatea tamaño de archivos (KB, MB, GB)
- `formatCryptoPrice(price, symbol)` - Formatea precio de crypto con precisión dinámica
- `formatPnL(pnl)` - Formatea profit/loss con color

**Ejemplo de uso:**
```dart
import 'package:kuri_crypto/utils/formatters.dart';

final price = formatCurrency(1234.56); // "$1,234.56"
final percent = formatPercent(0.1234, 2); // "12.34%"
final size = formatSize(1048576); // "1.00 MB"
```

---

### 2. `validators.dart`
Funciones de validación para entradas de usuario y datos de trading.

**Clases:**
- `ValidationResult` - Resultado de una validación con `isValid` y `error`

**Funciones principales:**
- `validatePrice(price)` - Valida precio > 0
- `validateAmount(amount)` - Valida cantidad > 0
- `validatePercentage(value)` - Valida rango 0-100
- `validateStopLoss(sl, entry, side)` - Valida SL según posición
- `validateTakeProfit(tp, entry, side)` - Valida TP según posición
- `validateRiskReward(sl, tp, entry, side)` - Valida ratio R/R
- `validateDateRange(from, to)` - Valida rango de fechas
- `validateEmail(email)` - Valida formato de email
- `validateSymbol(symbol)` - Valida símbolo de trading

**Ejemplo de uso:**
```dart
import 'package:kuri_crypto/utils/validators.dart';

final result = validatePrice(100.50);
if (!result.isValid) {
  print(result.error); // "Price must be greater than 0"
}

final emailResult = validateEmail('user@example.com');
if (emailResult.isValid) {
  print('Email válido');
}
```

---

### 3. `constants.dart`
Constantes de la aplicación organizadas en clases.

**Clases de constantes:**
- `ApiEndpoints` - Endpoints de la API REST y WebSocket
- `Timeframes` - Intervalos de tiempo (1m, 5m, 1h, 4h, 1d, etc.)
- `StrategyNames` - Nombres de estrategias de trading
- `RiskModes` - Modos de riesgo (conservative, moderate, aggressive)
- `PositionSides` - Lados de posición (long, short)
- `OrderTypes` - Tipos de órdenes (market, limit, stop, etc.)
- `OrderStatus` - Estados de órdenes
- `PositionStatus` - Estados de posiciones
- `AppColors` - Colores de la UI (profit, loss, primary, etc.)
- `AppConstants` - Constantes generales de la app

**Ejemplo de uso:**
```dart
import 'package:kuri_crypto/utils/constants.dart';

final endpoint = ApiEndpoints.tradingPositions;
final timeframe = Timeframes.fourHours;
final color = AppColors.profit;
final maxLeverage = AppConstants.maxLeverage;
```

---

### 4. `extensions.dart`
Extensiones para tipos nativos y modelos.

**Extensiones disponibles:**
- `DateTimeExtension` - Para DateTime
  - `toFormattedString(format)`
  - `isToday()`, `isYesterday()`, `isTomorrow()`
  - `isPast()`, `isFuture()`
  - `startOfDay()`, `endOfDay()`
  - `timeAgo()`

- `StringExtension` - Para String
  - `toDateTime()`
  - `capitalize()`, `capitalizeWords()`
  - `toCamelCase()`, `toSnakeCase()`
  - `isEmail()`, `isNumeric()`
  - `truncate(maxLength)`

- `DoubleExtension` - Para double
  - `toPercent(decimals, includeSign)`
  - `toCurrency(symbol, decimals)`
  - `toFormattedString(decimals)`
  - `toCompact(decimals)`
  - `roundToDecimals(decimals)`

- `IntExtension` - Para int
  - `toSize(decimals)` - Convierte bytes a KB/MB/GB
  - `toLatency(decimals)` - Formatea milisegundos

- `PositionExtension` - Para Position
  - `isProfitablePosition()`
  - `getDuration()`, `getFormattedDuration()`
  - `getRoi()`, `getFormattedRoi()`
  - `isNearStopLoss()`, `isNearTakeProfit()`
  - `getRiskRewardRatio()`

**Ejemplo de uso:**
```dart
import 'package:kuri_crypto/utils/extensions.dart';

// DateTime
final formattedDate = DateTime.now().toFormattedString();
final isToday = DateTime.now().isToday(); // true

// String
final email = 'user@example.com';
final isValid = email.isEmail(); // true
final capitalized = 'hello world'.capitalizeWords(); // "Hello World"

// Double
final percent = 0.1234.toPercent(); // "12.34%"
final currency = 1234.56.toCurrency(); // "$1,234.56"

// Position
final duration = position.getDuration();
final roi = position.getFormattedRoi(); // "+12.34%"
```

---

### 5. `error_handler.dart`
Manejo centralizado de errores de la aplicación.

**Funciones principales:**
- `handleApiError(error)` - Maneja errores de API
- `getErrorMessage(error)` - Obtiene mensaje amigable
- `showErrorSnackbar(context, error)` - Muestra error en UI
- `showSuccessSnackbar(context, message)` - Muestra éxito
- `showWarningSnackbar(context, message)` - Muestra advertencia
- `showErrorDialog(context, error)` - Muestra diálogo de error
- `logError(error, stackTrace)` - Registra error en logs
- `withErrorHandling(fn)` - Ejecuta función con manejo automático
- `withRetry(fn, maxRetries)` - Ejecuta con reintentos automáticos

**Ejemplo de uso:**
```dart
import 'package:kuri_crypto/utils/error_handler.dart';

try {
  await apiService.getData();
} catch (e, stackTrace) {
  // Mostrar error al usuario
  showErrorSnackbar(context, e);

  // Registrar en logs
  logError(e, stackTrace);
}

// Con manejo automático
await withErrorHandling(
  () => apiService.getData(),
  onError: () => print('Error occurred'),
  showSnackbar: true,
  context: context,
);
```

---

### 6. `chart_helpers.dart`
Helpers para trabajar con fl_chart.

**Funciones principales:**
- `prepareLineChartData(data)` - Prepara datos para LineChart
- `prepareBarChartData(data)` - Prepara datos para BarChart
- `preparePieChartData(data)` - Prepara datos para PieChart
- `getChartColor(index)` - Obtiene color consistente
- `getChartGradient(index)` - Obtiene gradiente
- `formatChartLabel(value, type)` - Formatea labels
- `getGridInterval(min, max)` - Calcula intervalo de grid
- `getChartLimits(values)` - Calcula límites con padding
- `getGridData()` - Configuración de grid
- `getTitlesData()` - Configuración de títulos

**Ejemplo de uso:**
```dart
import 'package:kuri_crypto/utils/chart_helpers.dart';

// Preparar datos
final spots = prepareLineChartData([10.0, 20.0, 15.0, 30.0]);

// Obtener colores
final color = getChartColor(0); // Blue

// Formatear labels
final label = formatChartLabel(1234.56, type: ChartLabelType.currency); // "$1,234.56"

// Configuración de chart
LineChart(
  LineChartData(
    gridData: getGridData(),
    borderData: getBorderData(),
    titlesData: getTitlesData(
      leftType: ChartLabelType.currency,
      bottomType: ChartLabelType.date,
    ),
  ),
);
```

---

### 7. `preferences_helper.dart`
Wrapper para SharedPreferences con funciones específicas.

**Funciones principales:**
- `init()` - Inicializar (llamar en main)
- `saveThemeMode(mode)`, `getThemeMode()` - Tema
- `saveLocale(locale)`, `getLocale()` - Idioma
- `saveLastSymbol(symbol)`, `getLastSymbol()` - Trading
- `saveNotificationsEnabled(enabled)` - Notificaciones
- `saveFavoriteSymbols(symbols)`, `getFavoriteSymbols()` - Favoritos
- `saveAuthToken(token)`, `getAuthToken()` - Autenticación
- `saveCachedData(key, data)`, `getCachedData(key)` - Cache
- `clearAll()` - Limpiar todo

**Ejemplo de uso:**
```dart
import 'package:kuri_crypto/utils/preferences_helper.dart';

// En main()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesHelper.init();
  runApp(MyApp());
}

// Usar en la app
await PreferencesHelper.saveThemeMode(ThemeMode.dark);
final theme = PreferencesHelper.getThemeMode();

await PreferencesHelper.saveLastSymbol('BTC-USDT');
final symbol = PreferencesHelper.getLastSymbol();

// Favoritos
await PreferencesHelper.addFavoriteSymbol('BTC-USDT');
final favorites = PreferencesHelper.getFavoriteSymbols();
```

---

### 8. `network_helper.dart`
Utilidades de red y conectividad.

**Funciones principales:**
- `isOnline()` - Verifica conexión a internet
- `canConnectToApi()` - Verifica conexión al servidor
- `getDeviceIP()` - Obtiene IP del dispositivo
- `configureApiUrl(isProduction)` - Configura URL según ambiente
- `configureWsUrl(isProduction)` - Configura URL WebSocket
- `detectEnvironment()` - Detecta ambiente actual
- `measureLatency(url)` - Mide latencia al servidor
- `checkServerStatus(url)` - Verifica estado del servidor
- `runNetworkDiagnostics()` - Ejecuta diagnóstico completo

**Ejemplo de uso:**
```dart
import 'package:kuri_crypto/utils/network_helper.dart';

// Verificar conexión
if (await NetworkHelper.isOnline()) {
  print('Connected to internet');
}

// Configurar URL
final apiUrl = NetworkHelper.configureApiUrl(
  isProduction: true,
  productionUrl: 'https://api.production.com',
);

// Medir latencia
final latency = await NetworkHelper.measureLatency(apiUrl);
print('Latency: ${latency}ms');

// Diagnóstico completo
final report = await NetworkHelper.runNetworkDiagnostics();
NetworkHelper.printDiagnosticReport(report);
```

---

## Importación Simplificada

Para importar todas las utilidades de una vez:

```dart
import 'package:kuri_crypto/utils/utils.dart';

// Ahora tienes acceso a todas las funciones y clases
```

O importa solo lo que necesites:

```dart
import 'package:kuri_crypto/utils/formatters.dart';
import 'package:kuri_crypto/utils/validators.dart';
```

## Ejemplos de Uso Completos

### Ejemplo 1: Validar y formatear precio

```dart
import 'package:kuri_crypto/utils/utils.dart';

void processPrice(double? price) {
  // Validar
  final validation = validatePrice(price);
  if (!validation.isValid) {
    print('Error: ${validation.error}');
    return;
  }

  // Formatear
  final formatted = formatCurrency(price!);
  print('Price: $formatted');
}
```

### Ejemplo 2: Mostrar error de API

```dart
import 'package:kuri_crypto/utils/utils.dart';

Future<void> loadData(BuildContext context) async {
  try {
    await apiService.getData();
    showSuccessSnackbar(context, 'Data loaded successfully');
  } catch (e, stackTrace) {
    showErrorSnackbar(context, e);
    logError(e, stackTrace);
  }
}
```

### Ejemplo 3: Trabajar con preferencias

```dart
import 'package:kuri_crypto/utils/utils.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Theme toggle
          SwitchListTile(
            title: Text('Dark Mode'),
            value: PreferencesHelper.getThemeMode() == ThemeMode.dark,
            onChanged: (value) async {
              await PreferencesHelper.saveThemeMode(
                value ? ThemeMode.dark : ThemeMode.light,
              );
            },
          ),
        ],
      ),
    );
  }
}
```

---

## Contribuir

Al añadir nuevas utilidades:

1. Añádelas al archivo apropiado o crea uno nuevo
2. Documenta con comentarios de documentación (///)
3. Incluye ejemplos de uso en los comentarios
4. Actualiza este README
5. Exporta en `utils.dart` si es necesario

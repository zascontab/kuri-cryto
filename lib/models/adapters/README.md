# Hive Adapters

Este directorio contiene los TypeAdapters de Hive para todos los modelos principales de la aplicación.

## Adapters Disponibles

| Adapter | Type ID | Modelo | Descripción |
|---------|---------|--------|-------------|
| `PositionAdapter` | 0 | Position | Posiciones de trading (abiertas/cerradas) |
| `TradeAdapter` | 1 | Trade | Historial de ejecuciones de trades |
| `StrategyAdapter` | 2 | Strategy | Estrategias de trading |
| `StrategyPerformanceAdapter` | 3 | StrategyPerformance | Métricas de rendimiento de estrategias |
| `RiskStateAdapter` | 4 | RiskState | Estado de gestión de riesgo |
| `MetricsAdapter` | 5 | Metrics | Métricas globales de rendimiento |
| `SystemStatusAdapter` | 6 | SystemStatus | Estado y salud del sistema |

## Type IDs

Los Type IDs son únicos para cada adapter y deben permanecer constantes entre versiones de la app. **NUNCA cambies un Type ID una vez asignado**, ya que esto causará errores de deserialización en dispositivos con datos en caché.

Rango reservado: 0-99 para modelos core.

## Uso

Los adapters se registran automáticamente en `main.dart`:

```dart
// Registrar adaptadores de Hive
Hive.registerAdapter(PositionAdapter());
Hive.registerAdapter(TradeAdapter());
Hive.registerAdapter(StrategyAdapter());
Hive.registerAdapter(StrategyPerformanceAdapter());
Hive.registerAdapter(RiskStateAdapter());
Hive.registerAdapter(MetricsAdapter());
Hive.registerAdapter(SystemStatusAdapter());
```

## Estructura de un Adapter

Cada adapter implementa `TypeAdapter<T>` y define:

1. **typeId**: Identificador único del adapter (0-223)
2. **read()**: Deserializa datos binarios a objeto
3. **write()**: Serializa objeto a datos binarios

### Ejemplo:

```dart
class PositionAdapter extends TypeAdapter<Position> {
  @override
  final int typeId = 0;

  @override
  Position read(BinaryReader reader) {
    // Leer campos del reader
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };

    // Construir objeto
    return Position(
      id: fields[0] as String,
      symbol: fields[1] as String,
      // ... más campos
    );
  }

  @override
  void write(BinaryWriter writer, Position obj) {
    // Escribir número de campos
    writer.writeByte(15);

    // Escribir cada campo con su índice
    writer
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.symbol);
      // ... más campos
  }
}
```

## Best Practices

### 1. Orden de Campos
Mantén el orden de los campos consistente. El índice del campo debe coincidir entre `read()` y `write()`.

### 2. Número de Campos
Actualiza el número en `writeByte(N)` cuando agregues o quites campos.

### 3. Campos Opcionales
Maneja campos opcionales (nullable) correctamente:

```dart
// Lectura
stopLoss: fields[7] as double?,

// Escritura
..writeByte(7)
..write(obj.stopLoss)  // Hive maneja null automáticamente
```

### 4. Tipos Complejos
Para Map y List, convierte al tipo correcto:

```dart
// Map<String, double>
Map<String, double> exposureBySymbol = {};
if (fields[4] != null) {
  final rawMap = fields[4];
  if (rawMap is Map) {
    exposureBySymbol = Map<String, double>.from(
      rawMap.map((key, value) => MapEntry(
        key.toString(),
        value is double ? value : (value as num).toDouble(),
      )),
    );
  }
}

// List<String>
List<String> errors = [];
if (fields[5] != null) {
  final rawList = fields[5];
  if (rawList is List) {
    errors = rawList.map((e) => e.toString()).toList();
  }
}
```

### 5. Nested Objects
Para objetos anidados (como `StrategyPerformance` dentro de `Strategy`), asegúrate de registrar ambos adapters:

```dart
// En main.dart
Hive.registerAdapter(StrategyPerformanceAdapter());  // Primero el nested
Hive.registerAdapter(StrategyAdapter());  // Luego el parent
```

### 6. Versionado
Si necesitas cambiar la estructura de un modelo:

1. **NO cambies el Type ID**
2. Agrega campos nuevos al final
3. Mantén compatibilidad con versiones anteriores
4. Usa valores por defecto para campos nuevos

```dart
// Versión 1
Position(
  id: fields[0] as String,
  symbol: fields[1] as String,
);

// Versión 2 - agrega campo al final
Position(
  id: fields[0] as String,
  symbol: fields[1] as String,
  newField: fields[15] ?? defaultValue,  // Campo nuevo al final
);
```

## Testing

Verifica que los adapters funcionen correctamente:

```dart
test('PositionAdapter serialization', () async {
  await Hive.initFlutter();
  Hive.registerAdapter(PositionAdapter());

  final box = await Hive.openBox<Position>('test');

  final position = Position(
    id: '123',
    symbol: 'BTC-USDT',
    // ... más campos
  );

  await box.put('key', position);
  final retrieved = box.get('key');

  expect(retrieved?.id, equals('123'));
  expect(retrieved?.symbol, equals('BTC-USDT'));

  await box.close();
});
```

## Debugging

Si encuentras errores de serialización:

1. Verifica que el Type ID sea único
2. Confirma que el número de campos en `write()` coincida con los campos escritos
3. Verifica que los índices en `read()` y `write()` coincidan
4. Asegúrate de que todos los adapters necesarios estén registrados
5. Revisa que los tipos sean compatibles (int/double conversions)

## Migración de Datos

Si necesitas migrar datos entre versiones:

```dart
// En CacheService
Future<void> migrateData() async {
  final oldBox = await Hive.openBox('old_positions');
  final newBox = await Hive.openBox<Position>('positions');

  for (final key in oldBox.keys) {
    final oldData = oldBox.get(key);
    final newPosition = Position.fromJson(oldData);
    await newBox.put(key, newPosition);
  }

  await oldBox.deleteFromDisk();
}
```

## Recursos

- [Hive Documentation](https://docs.hivedb.dev/)
- [TypeAdapter Guide](https://docs.hivedb.dev/#/custom-objects/type_adapters)
- [Best Practices](https://docs.hivedb.dev/#/best-practices/performance)
